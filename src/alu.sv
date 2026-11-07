`default_nettype none

module alu (
    input  wire signed [7:0] a,           // Από τον Accumulator
    input  wire signed [7:0] b,           // Από τον Data Bus (ή Live Data)
    input  wire        [3:0] alu_op,      // 4-bit Opcode λειτουργίας
    output reg  signed [7:0] alu_out,     // Το αποτέλεσμα της πράξης
    output reg               overflow     // Overflow Flag για Signed λάθη
);

    always @(*) begin
        overflow = 1'b0; 
        case (alu_op)
            4'b0000: alu_out = a;         // No change (απλό πέρασμα)
            
            4'b0001: begin                // ADD (Πρόσθεση)
                alu_out = a + b;
                if ((a[7] == b[7]) && (alu_out[7] != a[7])) 
                    overflow = 1'b1;
            end
            
            4'b0010: begin                // SUB (Αφαίρεση)
                alu_out = a - b;
                if ((a[7] != b[7]) && (alu_out[7] != a[7])) 
                    overflow = 1'b1;
            end
            
            4'b0011: begin                // INC (Αύξηση κατά 1)
                alu_out = a + 1'b1;
                if (a == 8'sb01111111) overflow = 1'b1; 
            end
            
            4'b0100: begin                // DEC (Μείωση κατά 1)
                alu_out = a - 1'b1;
                if (a == 8'sb10000000) overflow = 1'b1; 
            end

            4'b0101: alu_out = b;         // LOAD: Περνάει το δεδομένο αυτούσιο
            4'b0110: alu_out = a;         // STORE: Περνάει τον Accumulator αυτούσιο
            
            4'b0111: alu_out = a & b;     // AND
            4'b1000: alu_out = a | b;     // OR  
            4'b1001: alu_out = a ^ b;     // XOR 
            4'b1010: alu_out = ~a;        // NOT 
            4'b1011: alu_out = a << 1;    // SHL 
            4'b1100: alu_out = a >>> 1;   // Arithmetic SHR (διατήρηση προσήμου)
            
            default: alu_out = 8'sh00;    // Ασφάλεια για Latches
        endcase
    end

endmodule
