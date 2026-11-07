`default_nettype none

module tt_um_top (
    input  wire [7:0] ui_in,
    ...
 (
    input  wire [7:0] ui_in,    // ui_in[7:0]: LIVE 8-bit Signed Δεδομένα (Διακόπτες SW7-SW0)
    output wire [7:0] uo_out,   // uo_out[7:0]: Έξοδος Accumulator (8 κεντρικά LED)
    input  wire [7:0] uio_in,   // uio_in[3:0]=Opcode, uio_in[4]=clk_source, uio_in[5]=clk_select, uio_in[6]=button
    output wire [7:0] uio_out,  // uio_out[7]: Έξοδος Overflow Flag σε LED
    output wire [7:0] uio_oe,   // Direction control των Bidirectional pins
    input  wire       ena,      
    input  wire       clk,      // Εσωτερικό γρήγορο ρολόι
    input  wire       rst_n     
);

    // Αντιστοίχηση των αμφίδρομων pins εισόδου (uio_in)
    wire [3:0] live_opcode = uio_in[3:0]; // 4 pins για τις 16 εντολές LIVE
    wire clk_source        = uio_in[4];   // 0 = Auto CLK, 1 = Χειροκίνητο Κουμπί
    wire clk_select        = uio_in[5];   // 0 = RAM Program, 1 = LIVE Mode
    wire manual_button     = uio_in[6];   // Push button για manual clock step

    // Ρύθμιση κατεύθυνσης: uio[6:0] είναι Είσοδοι (0), uio[7] είναι Έξοδος (1) για το Overflow
    assign uio_oe = 8'b10000000; 

    // Διαχείριση Ρολογιού (Clock Mux)
    wire button_pulse;
    wire internal_cpu_clk;

    edge_detector my_edge_det (
        .clk(clk),
        .rst_n(rst_n),
        .button_in(manual_button),
        .pulse_out(button_pulse)
    );

    // Επιλογή ρολογιού: Αυτόματο ή από το Push Button
    assign internal_cpu_clk = clk_source ? button_pulse : clk;

    // Εσωτερικά Wires Διασύνδεσης
    wire [7:0] data_bus;
    wire [3:0] pc;
    wire signed [7:0] accum;
    wire [7:0] inst_reg;
    wire [3:0] alu_op;
    wire       ram_we;
    wire [1:0] cpu_state;
    wire       of_flag;
    
    wire [7:0] ram_out;
    wire signed [7:0] alu_out;
    wire       alu_of;

    // --- INSTANTIATION: RAM ---
    ram my_ram (
        .clk(internal_cpu_clk),
        .write_enable(ram_we),
        .address(clk_select ? live_opcode : (cpu_state == 2'b00 ? pc : inst_reg[3:0])),
        .data_in(data_bus),
        .data_out(ram_out)
    );

    // --- INSTANTIATION: ALU ---
    alu my_alu (
        .a(accum),
        .b(clk_select ? ui_in : data_bus), // Αν είμαστε LIVE παίρνει κατευθείαν το 8-bit ui_in
        .alu_op(clk_select ? live_opcode : alu_op),
        .alu_out(alu_out),
        .overflow(alu_of)
    );

    // --- INSTANTIATION: CONTROL UNIT ---
    control my_control (
        .clk(internal_cpu_clk),
        .rst_n(rst_n),
        .ram_data_in(data_bus),
        .alu_result_in(alu_out),
        .alu_overflow_in(alu_of),
        .clk_select(clk_select),
        .program_counter(pc),
        .accumulator(accum),
        .instruction_register(inst_reg),
        .alu_op_out(alu_op),
        .ram_we_out(ram_we),
        .current_state_out(cpu_state),
        .overflow_flag(of_flag)
    );

    // Διαχείριση του Data Bus για το STORE
    assign data_bus = ram_we ? accum : ram_out;

    // Έξοδοι στα Pins του Chip
    assign uo_out  = accum;                            // Τα 8 dedicated outputs δείχνουν τον αριθμό
    assign uio_out = {of_flag, 7'b0000000};            // Το Overflow flag βγαίνει στο uio[7] (LED)

endmodule
