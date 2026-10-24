
`timescale 1ns/1ps

module sha256_core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         start,

    input  wire [511:0] block_in,

    output reg  [255:0] hash_out,
    output reg          busy,
    output reg          done
);

    // ============================================================
    // SHA-256 initial hash values
    // ============================================================

    localparam [31:0] H0_INIT = 32'h6A09E667;
    localparam [31:0] H1_INIT = 32'hBB67AE85;
    localparam [31:0] H2_INIT = 32'h3C6EF372;
    localparam [31:0] H3_INIT = 32'hA54FF53A;
    localparam [31:0] H4_INIT = 32'h510E527F;
    localparam [31:0] H5_INIT = 32'h9B05688C;
    localparam [31:0] H6_INIT = 32'h1F83D9AB;
    localparam [31:0] H7_INIT = 32'h5BE0CD19;

    // ============================================================
    // Working state registers
    // ============================================================

    reg [31:0] a;
    reg [31:0] b;
    reg [31:0] c;
    reg [31:0] d;
    reg [31:0] e;
    reg [31:0] f;
    reg [31:0] g;
    reg [31:0] h;

    // ============================================================
    // 16-word rolling message schedule
    // ============================================================

    reg [31:0] w_mem [0:15];

    reg [5:0] round;

    // Asserted after round 63; final hash accumulation occurs
    // on the following clock edge.
    reg finalize;

    // ============================================================
    // SHA-256 message schedule functions
    // ============================================================

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
            sigma0 = ROTR(x, 7) ^
                     ROTR(x, 18) ^
                     SHR(x, 3);
        end
    endfunction

    function [31:0] sigma1;
        input [31:0] x;
        begin
            sigma1 = ROTR(x, 17) ^
                     ROTR(x, 19) ^
                     SHR(x, 10);
        end
    endfunction

    // ============================================================
    // Rolling schedule indices
    // ============================================================

    wire [3:0] idx;
    wire [3:0] idx_m2;
    wire [3:0] idx_m7;
    wire [3:0] idx_m15;

    assign idx     = round[3:0];
    assign idx_m2  = idx - 4'd2;
    assign idx_m7  = idx - 4'd7;
    assign idx_m15 = idx + 4'd1;

    wire [31:0] w_current;
    wire [31:0] w_next;

    assign w_next =
          sigma1(w_mem[idx_m2])
        + w_mem[idx_m7]
        + sigma0(w_mem[idx_m15])
        + w_mem[idx];

    assign w_current =
        (round < 6'd16) ? w_mem[round[3:0]] : w_next;

    // ============================================================
    // SHA-256 round constants
    // ============================================================

    wire [31:0] K;

    sha256_constants constants_inst (
        .t(round),
        .K(K)
    );

    // ============================================================
    // SHA-256 round datapath
    // ============================================================

    wire [31:0] a_next;
    wire [31:0] b_next;
    wire [31:0] c_next;
    wire [31:0] d_next;
    wire [31:0] e_next;
    wire [31:0] f_next;
    wire [31:0] g_next;
    wire [31:0] h_next;

    sha256_round round_inst (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .K(K),
        .W(w_current),

        .a_next(a_next),
        .b_next(b_next),
        .c_next(c_next),
        .d_next(d_next),
        .e_next(e_next),
        .f_next(f_next),
        .g_next(g_next),
        .h_next(h_next)
    );

    // ============================================================
    // Sequential controller
    // ============================================================

    integer i;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            a        <= 32'h0;
            b        <= 32'h0;
            c        <= 32'h0;
            d        <= 32'h0;
            e        <= 32'h0;
            f        <= 32'h0;
            g        <= 32'h0;
            h        <= 32'h0;

            round    <= 6'd0;
            finalize <= 1'b0;

            hash_out <= 256'h0;

            busy     <= 1'b0;
            done     <= 1'b0;

            for (i = 0; i < 16; i = i + 1)
                w_mem[i] <= 32'h0;

        end

        else begin

            // done is a one-clock pulse
            done <= 1'b0;

            // ----------------------------------------------------
            // Final hash accumulation stage
            // ----------------------------------------------------
            // The final round has already updated a through h.
            // Nonblocking assignments from the previous edge have
            // taken effect, so these are the updated working values.

            if (finalize) begin

                hash_out <= {
                    H0_INIT + a,
                    H1_INIT + b,
                    H2_INIT + c,
                    H3_INIT + d,
                    H4_INIT + e,
                    H5_INIT + f,
                    H6_INIT + g,
                    H7_INIT + h
                };

                finalize <= 1'b0;
                busy     <= 1'b0;
                done     <= 1'b1;
                round    <= 6'd0;

            end

            // ----------------------------------------------------
            // Start a new SHA-256 block
            // ----------------------------------------------------

            else if (start && !busy) begin

                a <= H0_INIT;
                b <= H1_INIT;
                c <= H2_INIT;
                d <= H3_INIT;
                e <= H4_INIT;
                f <= H5_INIT;
                g <= H6_INIT;
                h <= H7_INIT;

                // Load the first 16 message words
                w_mem[0]  <= block_in[511:480];
                w_mem[1]  <= block_in[479:448];
                w_mem[2]  <= block_in[447:416];
                w_mem[3]  <= block_in[415:384];
                w_mem[4]  <= block_in[383:352];
                w_mem[5]  <= block_in[351:320];
                w_mem[6]  <= block_in[319:288];
                w_mem[7]  <= block_in[287:256];
                w_mem[8]  <= block_in[255:224];
                w_mem[9]  <= block_in[223:192];
                w_mem[10] <= block_in[191:160];
                w_mem[11] <= block_in[159:128];
                w_mem[12] <= block_in[127:96];
                w_mem[13] <= block_in[95:64];
                w_mem[14] <= block_in[63:32];
                w_mem[15] <= block_in[31:0];

                round    <= 6'd0;
                finalize <= 1'b0;

                busy     <= 1'b1;
                done     <= 1'b0;

            end

            // ----------------------------------------------------
            // Perform one SHA-256 round per clock
            // ----------------------------------------------------

            else if (busy) begin

                // Update the working state
                a <= a_next;
                b <= b_next;
                c <= c_next;
                d <= d_next;
                e <= e_next;
                f <= f_next;
                g <= g_next;
                h <= h_next;

                // Update the rolling message schedule for rounds
                // 16 through 63.
                if (round >= 6'd16)
                    w_mem[idx] <= w_next;

                // ------------------------------------------------
                // Final round: defer hash accumulation by one cycle
                // ------------------------------------------------

                if (round == 6'd63) begin

                    // Keep busy asserted until hash_out is ready.
                    finalize <= 1'b1;
                    round    <= 6'd0;

                end

                else begin
                    round <= round + 6'd1;
                end

            end

        end

    end

endmodule

