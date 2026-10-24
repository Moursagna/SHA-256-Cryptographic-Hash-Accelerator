`timescale 1ns/1ps

module sha256_constants (
    input  wire [5:0]  t,
    output reg  [31:0] K
);

    always @(*) begin
        case (t)
            6'd0:  K = 32'h428A2F98;
            6'd1:  K = 32'h71374491;
            6'd2:  K = 32'hB5C0FBCF;
            6'd3:  K = 32'hE9B5DBA5;
            6'd4:  K = 32'h3956C25B;
            6'd5:  K = 32'h59F111F1;
            6'd6:  K = 32'h923F82A4;
            6'd7:  K = 32'hAB1C5ED5;
            6'd8:  K = 32'hD807AA98;
            6'd9:  K = 32'h12835B01;
            6'd10: K = 32'h243185BE;
            6'd11: K = 32'h550C7DC3;
            6'd12: K = 32'h72BE5D74;
            6'd13: K = 32'h80DEB1FE;
            6'd14: K = 32'h9BDC06A7;
            6'd15: K = 32'hC19BF174;
            6'd16: K = 32'hE49B69C1;
            6'd17: K = 32'hEFBE4786;
            6'd18: K = 32'h0FC19DC6;
            6'd19: K = 32'h240CA1CC;
            6'd20: K = 32'h2DE92C6F;
            6'd21: K = 32'h4A7484AA;
            6'd22: K = 32'h5CB0A9DC;
            6'd23: K = 32'h76F988DA;
            6'd24: K = 32'h983E5152;
            6'd25: K = 32'hA831C66D;
            6'd26: K = 32'hB00327C8;
            6'd27: K = 32'hBF597FC7;
            6'd28: K = 32'hC6E00BF3;
            6'd29: K = 32'hD5A79147;
            6'd30: K = 32'h06CA6351;
            6'd31: K = 32'h14292967;
            6'd32: K = 32'h27B70A85;
            6'd33: K = 32'h2E1B2138;
            6'd34: K = 32'h4D2C6DFC;
            6'd35: K = 32'h53380D13;
            6'd36: K = 32'h650A7354;
            6'd37: K = 32'h766A0ABB;
            6'd38: K = 32'h81C2C92E;
            6'd39: K = 32'h92722C85;
            6'd40: K = 32'hA2BFE8A1;
            6'd41: K = 32'hA81A664B;
            6'd42: K = 32'hC24B8B70;
            6'd43: K = 32'hC76C51A3;
            6'd44: K = 32'hD192E819;
            6'd45: K = 32'hD6990624;
            6'd46: K = 32'hF40E3585;
            6'd47: K = 32'h106AA070;
            6'd48: K = 32'h19A4C116;
            6'd49: K = 32'h1E376C08;
            6'd50: K = 32'h2748774C;
            6'd51: K = 32'h34B0BCB5;
            6'd52: K = 32'h391C0CB3;
            6'd53: K = 32'h4ED8AA4A;
            6'd54: K = 32'h5B9CCA4F;
            6'd55: K = 32'h682E6FF3;
            6'd56: K = 32'h748F82EE;
            6'd57: K = 32'h78A5636F;
            6'd58: K = 32'h84C87814;
            6'd59: K = 32'h8CC70208;
            6'd60: K = 32'h90BEFFFA;
            6'd61: K = 32'hA4506CEB;
            6'd62: K = 32'hBEF9A3F7;
            6'd63: K = 32'hC67178F2;
            default: K = 32'h00000000;
        endcase
    end

endmodule
