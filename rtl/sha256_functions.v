module sha256_functions;

    // ------------------------------------------------------------
    // SHA-256 Choose function
    // Ch(x,y,z) = (x & y) ^ (~x & z)
    // ------------------------------------------------------------
    function [31:0] Ch;
        input [31:0] x;
        input [31:0] y;
        input [31:0] z;
        begin
            Ch = (x & y) ^ (~x & z);
        end
    endfunction

    // ------------------------------------------------------------
    // SHA-256 Majority function
    // Maj(x,y,z) = (x & y) ^ (x & z) ^ (y & z)
    // ------------------------------------------------------------
    function [31:0] Maj;
        input [31:0] x;
        input [31:0] y;
        input [31:0] z;
        begin
            Maj = (x & y) ^ (x & z) ^ (y & z);
        end
    endfunction

    // ------------------------------------------------------------
    // Rotate right
    // ------------------------------------------------------------
    function [31:0] ROTR;
        input [31:0] x;
        input integer n;
        begin
            ROTR = (x >> n) | (x << (32 - n));
        end
    endfunction

    // ------------------------------------------------------------
    // Shift right
    // ------------------------------------------------------------
    function [31:0] SHR;
        input [31:0] x;
        input integer n;
        begin
            SHR = x >> n;
        end
    endfunction

    // ------------------------------------------------------------
    // Big Sigma 0
    // Σ0(x) = ROTR2(x) ^ ROTR13(x) ^ ROTR22(x)
    // ------------------------------------------------------------
    function [31:0] Sigma0;
        input [31:0] x;
        begin
            Sigma0 = ROTR(x,2) ^ ROTR(x,13) ^ ROTR(x,22);
        end
    endfunction

    // ------------------------------------------------------------
    // Big Sigma 1
    // Σ1(x) = ROTR6(x) ^ ROTR11(x) ^ ROTR25(x)
    // ------------------------------------------------------------
    function [31:0] Sigma1;
        input [31:0] x;
        begin
            Sigma1 = ROTR(x,6) ^ ROTR(x,11) ^ ROTR(x,25);
        end
    endfunction

    // ------------------------------------------------------------
    // Small Sigma 0
    // σ0(x) = ROTR7(x) ^ ROTR18(x) ^ SHR3(x)
    // ------------------------------------------------------------
    function [31:0] sigma0;
        input [31:0] x;
        begin
            sigma0 = ROTR(x,7) ^ ROTR(x,18) ^ SHR(x,3);
        end
    endfunction

    // ------------------------------------------------------------
    // Small Sigma 1
    // σ1(x) = ROTR17(x) ^ ROTR19(x) ^ SHR10(x)
    // ------------------------------------------------------------
    function [31:0] sigma1;
        input [31:0] x;
        begin
            sigma1 = ROTR(x,17) ^ ROTR(x,19) ^ SHR(x,10);
        end
    endfunction

endmodule
