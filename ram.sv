`default_nettype none

module ram (
    input  wire       clk,
    input  wire       write_enable, 
    input  wire [3:0] address,      
    input  wire [7:0] data_in,      
    output wire [7:0] data_out      
);

    reg [7:0] memory [0:15];

    initial begin
        // --- ΠΡΟΓΡΑΜΜΑ AUTO/STEP MODE ---
        memory[0] = 8'h54; // LOAD από τη θέση 4 (Φορτώνει το +10)
        memory[1] = 8'h15; // ADD με τη θέση 5 (Προσθέτει το +5)
        memory[2] = 8'h6F; // STORE στη θέση 15 (F)
        memory[3] = 8'hF0; // JUMP πίσω στη θέση 0 (Loop)
        
        // --- ΔΕΔΟΜΕΝΑ ---
        memory[4] = 8'h0A; // Το δεδομένο +10
        memory[5] = 8'h05; // Το δεδομένο +5
        
        // Μηδενισμός υπόλοιπων θέσεων
        memory[6] = 8'h00; memory[7] = 8'h00; memory[8] = 8'h00; memory[9] = 8'h00;
        memory[10]= 8'h00; memory[11]= 8'h00; memory[12]= 8'h00; memory[13]= 8'h00;
        memory[14]= 8'h00; memory[15]= 8'h00; 
    end

    always @(posedge clk) begin
        if (write_enable)
            memory[address] <= data_in;
    end

    assign data_out = memory[address];

endmodule
