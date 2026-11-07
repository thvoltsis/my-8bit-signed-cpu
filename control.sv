`default_nettype none

module control (
    input  wire              clk,
    input  wire              rst_n,
    input  wire        [7:0] ram_data_in,      
    input  wire signed [7:0] alu_result_in,    
    input  wire              alu_overflow_in,  
    input  wire              clk_select,       // 0=RAM/Auto, 1=LIVE Mode
    output reg         [3:0] program_counter,
    output reg  signed [7:0] accumulator,
    output reg         [7:0] instruction_register,
    output reg         [3:0] alu_op_out,
    output reg               ram_we_out,
    output reg         [1:0] current_state_out,
    output reg               overflow_flag
);

    reg [1:0] state;
    localparam STATE_FETCH   = 2'b00;
    localparam STATE_DECODE  = 2'b01;
    localparam STATE_EXECUTE = 2'b10;

    wire [3:0] opcode = instruction_register[7:4];
    wire [3:0] addr   = instruction_register[3:0];

    always @(posedge clk) begin
        if (!rst_n) begin
            program_counter      <= 4'b0000;
            accumulator          <= 8'sh00;
            instruction_register <= 8'b00000000;
            overflow_flag        <= 1'b0;
            state                <= STATE_FETCH;
            ram_we_out           <= 1'b0;
            alu_op_out           <= 4'b0000;
        end else begin
            if (clk_select) begin
                // --- LIVE MODE (Άμεση εκτέλεση με 1 πάτημα) ---
                accumulator   <= alu_result_in;
                overflow_flag <= alu_overflow_in;
            end else begin
                // --- AUTO / STEP MODE (RAM Πρόγραμμα) ---
                case (state)
                    STATE_FETCH: begin
                        ram_we_out           <= 1'b0;
                        instruction_register <= ram_data_in;
                        state                <= STATE_DECODE;
                    end
                    STATE_DECODE: begin
                        alu_op_out <= opcode;
                        if (opcode == 4'b0110) ram_we_out <= 1'b1; // STORE
                        state      <= STATE_EXECUTE;
                    end
                    STATE_EXECUTE: begin
                        if (opcode != 4'b1111 && opcode != 4'b0110) begin
                            accumulator   <= alu_result_in;
                            overflow_flag <= alu_overflow_in;
                        end
                        else if (opcode == 4'b1111) begin
                            program_counter <= addr; // JUMP
                        end

                        if (opcode == 4'b0110) ram_we_out <= 1'b0; // Κλείσιμο εγγραφής

                        if (opcode != 4'b1111) begin
                            program_counter <= program_counter + 1;
                        end
                        state <= STATE_FETCH;
                    end
                endcase
            end
        end
    end

    assign current_state_out = state;

endmodule
