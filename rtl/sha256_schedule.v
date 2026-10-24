`timescale 1ns/1ps

module sha256_schedule (
    input  wire [511:0] block_in,
    output reg  [31:0]  W [0:63]
);

    integer i;

    // SHA-256 small sigma functions
    function [31:0] ROTR;
        input [31:0] x;
        input integer n;

        begin
            ROTR = (x >> n) | (x << (32 - n));
        end
    endfunction

    function [31:0] SHR;
        input [31:0] x;
        input integer n;

        begin
            SHR = x >> n;
        end
    endfunction

    function [31:0] sigma0;
        input [31:0] x;

        begin
            sigma0 = ROTR(x,7) ^ ROTR(x,18) ^ SHR(x,3);
        end
    endfunction

    function [31:0] sigma1;
        input [31:0] x;

        begin
            sigma1 = ROTR(x,17) ^ ROTR(x,19) ^ SHR(x,10);
        end
    endfunction

    always @(*) begin

        // First 16 words come directly from the 512-bit block
        W[0]  = block_in[511:480];
        W[1]  = block_in[479:448];
        W[2]  = block_in[447:416];
        W[3]  = block_in[415:384];
        W[4]  = block_in[383:352];
        W[5]  = block_in[351:320];
        W[6]  = block_in[319:288];
        W[7]  = block_in[287:256];
        W[8]  = block_in[255:224];
        W[9]  = block_in[223:192];
        W[10] = block_in[191:160];
        W[11] = block_in[159:128];
        W[12] = block_in[127:96];
        W[13] = block_in[95:64];
        W[14] = block_in[63:32];
        W[15] = block_in[31:0];

        // Expand W[16] through W[63]
        for (i = 16; i < 64; i = i + 1) begin
            W[i] = sigma1(W[i-2])
                 + W[i-7]
                 + sigma0(W[i-15])
                 + W[i-16];
        end

    end

endmodule

