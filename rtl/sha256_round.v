
`timescale 1ns/1ps

module sha256_round (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [31:0] c,
    input  wire [31:0] d,
    input  wire [31:0] e,
    input  wire [31:0] f,
    input  wire [31:0] g,
    input  wire [31:0] h,

    input  wire [31:0] K,
    input  wire [31:0] W,

    output wire [31:0] a_next,
    output wire [31:0] b_next,
    output wire [31:0] c_next,
    output wire [31:0] d_next,
    output wire [31:0] e_next,
    output wire [31:0] f_next,
    output wire [31:0] g_next,
    output wire [31:0] h_next
);

    // --------------------------------------------------
    // SHA-256 helper functions
    // --------------------------------------------------

    function [31:0] ROTR;
        input [31:0] x;
        input integer n;

        begin
            ROTR = (x >> n) | (x << (32 - n));
        end
    endfunction

    function [31:0] Ch;
        input [31:0] x;
        input [31:0] y;
        input [31:0] z;

        begin
            Ch = (x & y) ^ (~x & z);
        end
    endfunction

    function [31:0] Maj;
        input [31:0] x;
        input [31:0] y;
        input [31:0] z;

        begin
            Maj = (x & y) ^ (x & z) ^ (y & z);
        end
    endfunction

    function [31:0] Sigma0;
        input [31:0] x;

        begin
            Sigma0 = ROTR(x,2) ^ ROTR(x,13) ^ ROTR(x,22);
        end
    endfunction

    function [31:0] Sigma1;
        input [31:0] x;

        begin
            Sigma1 = ROTR(x,6) ^ ROTR(x,11) ^ ROTR(x,25);
        end
    endfunction

    // --------------------------------------------------
    // Intermediate values
    // --------------------------------------------------

    wire [31:0] T1;
    wire [31:0] T2;

    wire [31:0] x1, y1;
    wire [31:0] x2, y2;
    wire [31:0] x3, y3;

    // Additional carry-save signals for e_next.
    wire [31:0] e_csa_sum;
    wire [31:0] e_csa_carry;

    // --------------------------------------------------
    // Carry-save compression of T1 operands:
    // h + Sigma1(e) + Ch(e,f,g) + K + W
    // --------------------------------------------------

    assign x1 = h ^ Sigma1(e) ^ Ch(e,f,g);

    assign y1 = ((h & Sigma1(e)) |
                 (h & Ch(e,f,g)) |
                 (Sigma1(e) & Ch(e,f,g))) << 1;

    assign x2 = x1 ^ y1 ^ K;

    assign y2 = ((x1 & y1) |
                 (x1 & K) |
                 (y1 & K)) << 1;

    assign x3 = x2 ^ y2 ^ W;

    assign y3 = ((x2 & y2) |
                 (x2 & W) |
                 (y2 & W)) << 1;

    // Final carry-propagate addition for T1.
    assign T1 = x3 + y3;

    // --------------------------------------------------
    // T2 calculation
    // --------------------------------------------------

    assign T2 = Sigma0(a)
              + Maj(a,b,c);

    // --------------------------------------------------
    // Next working-state values
    // --------------------------------------------------

    assign a_next = T1 + T2;

    assign b_next = a;
    assign c_next = b;
    assign d_next = c;

    // --------------------------------------------------
    // Optimized e_next:
    // e_next = x3 + y3 + d (modulo 2^32)
    //
    // Compress the three operands into sum and carry,
    // followed by one carry-propagate addition.
    // --------------------------------------------------

    assign e_csa_sum = x3 ^ y3 ^ d;

    assign e_csa_carry =
        ((x3 & y3) |
         (x3 & d)  |
         (y3 & d)) << 1;

    assign e_next = e_csa_sum + e_csa_carry;

    assign f_next = e;
    assign g_next = f;
    assign h_next = g;

endmodule

