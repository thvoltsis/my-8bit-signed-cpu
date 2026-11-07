`default_nettype none

module edge_detector (
    input  wire clk,
    input  wire rst_n,
    input  wire button_in,
    output wire pulse_out
);

    reg r1, r2;

    always @(posedge clk) begin
        if (!rst_n) begin
            r1 <= 1'b0;
            r2 <= 1'b0;
        end else begin
            r1 <= button_in;
            r2 <= r1;
        end
    end

    assign pulse_out = r1 && !r2;

endmodule
