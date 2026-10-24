`timescale 1ns/1ps

module test_sha256_core;

    // Waveform dump for GTKWave
    initial begin
        $dumpfile("sim/sha256_core.vcd");
        $dumpvars(0, test_sha256_core);
    end

    reg         clk;
    reg         rst_n;
    reg         start;
    reg [511:0] block_in;

    wire [255:0] hash_out;
    wire         busy;
    wire         done;

    integer test_count;
    integer pass_count;

    sha256_core dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .start    (start),
        .block_in (block_in),
        .hash_out (hash_out),
        .busy     (busy),
        .done     (done)
    );

    // 100 MHz clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------
    // Test task
    // ------------------------------------------------------------
    task run_test;
        input [511:0] test_block;
        input [255:0] expected_hash;
        input [127:0] test_name;

        begin

            test_count = test_count + 1;

            // Reset DUT
            rst_n    = 1'b0;
            start    = 1'b0;
            block_in = 512'b0;

            repeat (2) @(posedge clk);

            rst_n = 1'b1;

            @(posedge clk);

            // Load block and start
            block_in = test_block;
            start    = 1'b1;

            @(posedge clk);

            start = 1'b0;

            // Wait for completion
            wait (done == 1'b1);

            #1;

            if (hash_out === expected_hash) begin
                $display("PASS: %s", test_name);
                pass_count = pass_count + 1;
            end
            else begin
                $display("FAIL: %s", test_name);
                $display("  Expected = %064h", expected_hash);
                $display("  Got      = %064h", hash_out);
            end

            // Give DUT one cycle before next reset
            @(posedge clk);

        end
    endtask


    // ------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------
    initial begin

        test_count = 0;
        pass_count = 0;

        rst_n    = 1'b0;
        start    = 1'b0;
        block_in = 512'b0;

        $display("");
        $display("==========================================");
        $display(" SHA-256 Sequential Core Regression Test");
        $display("==========================================");
        $display("");

        // --------------------------------------------------------
        // TEST 1: Empty string
        //
        // SHA-256("")
        //
        // Block:
        // 80000000 00000000 ... 00000000
        // Length = 0
        // --------------------------------------------------------
        run_test(
            {
                32'h80000000,
                {14{32'h00000000}},
                32'h00000000
            },
            256'he3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855,
            "empty"
        );


        // --------------------------------------------------------
        // TEST 2: "abc"
        //
        // 61 62 63
        // --------------------------------------------------------
        run_test(
            {
                32'h61626380,
                {14{32'h00000000}},
                32'h00000018
            },
            256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad,
            "abc"
        );


        // --------------------------------------------------------
        // TEST 3: "hello"
        //
        // 68 65 6c 6c 6f
        // --------------------------------------------------------
        run_test(
            {
                32'h68656c6c,
                32'h6f800000,
                {13{32'h00000000}},
                32'h00000028
            },
            256'h2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824,
            "hello"
        );


        // --------------------------------------------------------
        // TEST 4: "OpenAI"
        //
        // 4f 70 65 6e 41 49
        // --------------------------------------------------------
        run_test(
            {
                32'h4f70656e,
                32'h41498000,
                {13{32'h00000000}},
                32'h00000030
            },
            256'h8b7d1a3187ab355dc31bc683aaa71ab5ed217940c12196a9cd5f4ca984babfa4,
            "OpenAI"
        );


        // --------------------------------------------------------
        // TEST 5: "a"
        // --------------------------------------------------------
        run_test(
            {
                32'h61800000,
                {14{32'h00000000}},
                32'h00000008
            },
            256'hca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb,
            "a"
        );


        // --------------------------------------------------------
        // TEST 6: alphabet
        //
        // "abcdefghijklmnopqrstuvwxyz"
        // --------------------------------------------------------
        run_test(
            {
                32'h61626364,
                32'h65666768,
                32'h696a6b6c,
                32'h6d6e6f70,
                32'h71727374,
                32'h75767778,
                32'h797a8000,
                {8{32'h00000000}},
                32'h000000d0
            },
            256'h71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73,
            "alphabet"
        );


        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------
        $display("");
        $display("==========================================");
        $display(" Regression Summary");
        $display("==========================================");
        $display("Tests passed : %0d / %0d", pass_count, test_count);

        if (pass_count == test_count) begin
            $display("");
            $display("ALL TESTS PASSED");
        end
        else begin
            $display("");
            $display("REGRESSION FAILED");
        end

        $display("==========================================");
        $display("");

        $finish;
    end

endmodule
