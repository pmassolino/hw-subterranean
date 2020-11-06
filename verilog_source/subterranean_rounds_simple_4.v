/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module subterranean_rounds_simple_4
#(parameter ASYNC_RSTN = 1// 0 - Synchronous reset in high, 1 - Asynchrouns reset in low.
)
(
    input wire clk,
    input wire arstn,
    input wire init,
    input wire [1:0] oper,
    input wire [1:0] enable_round,
    input wire [127:0] din,
    input wire din_valid,
    output wire din_ready,
    input wire [11:0] din_size,
    output wire [127:0] dout,
    output wire [11:0] dout_size,
    output wire dout_valid,
    input wire dout_ready
);

reg int_din_ready;
reg int_dout_valid;

wire [31:0] temp_din_1;
wire [31:0] temp_din_1_xor_dout;
reg [31:0] duplex_din_1;
reg [4:0] duplex_din_1_padding;
wire [32:0] duplex_din_1_padded;

wire [31:0] temp_din_2;
wire [31:0] temp_din_2_xor_dout;
reg [31:0] duplex_din_2;
reg [4:0] duplex_din_2_padding;
wire [32:0] duplex_din_2_padded;

wire [31:0] temp_din_3;
wire [31:0] temp_din_3_xor_dout;
reg [31:0] duplex_din_3;
reg [4:0] duplex_din_3_padding;
wire [32:0] duplex_din_3_padded;

wire [31:0] temp_din_4;
wire [31:0] temp_din_4_xor_dout;
reg [31:0] duplex_din_4;
reg [4:0] duplex_din_4_padding;
wire [32:0] duplex_din_4_padded;

wire [256:0] round_1_a;
wire [32:0]  round_1_din;
wire [256:0] round_1_o;
wire [31:0]  round_1_dout;

reg [31:0] round_1_dout_mask;

wire [256:0] round_2_a;
wire [32:0]  round_2_din;
wire [256:0] round_2_o;
wire [31:0]  round_2_dout;

reg [31:0] round_2_dout_mask;

wire [256:0] round_3_a;
wire [32:0]  round_3_din;
wire [256:0] round_3_o;
wire [31:0]  round_3_dout;

reg [31:0] round_3_dout_mask;

wire [256:0] round_4_a;
wire [32:0]  round_4_din;
wire [256:0] round_4_o;
wire [31:0]  round_4_dout;

reg [31:0] round_4_dout_mask;

reg [256:0] reg_state, next_state;

reg [127:0] reg_dout, next_dout;
reg [11:0] reg_dout_size, next_dout_size;

wire din_valid_and_ready;
wire dout_valid_and_ready;

assign din_valid_and_ready = din_valid & int_din_ready;
assign dout_valid_and_ready = int_dout_valid & dout_ready;

always @(posedge clk) begin
    reg_state <= next_state;
    reg_dout <= next_dout;
end

generate
    if (ASYNC_RSTN != 0) begin : use_asynchrnous_reset_zero_enable
        always @(posedge clk or negedge arstn) begin
            if (arstn == 1'b0) begin
                reg_dout_size <= 12'b000000000000;
            end else begin
                reg_dout_size <= next_dout_size;
            end
        end
    end else begin
        always @(posedge clk) begin
            if (arstn == 1'b1) begin
                reg_dout_size <= 12'b000000000000;
            end else begin
                reg_dout_size <= next_dout_size;
            end
        end
    end
endgenerate

always @(*) begin
    if(init == 1'b1) begin
        next_state = 257'h0;
    end else if (din_valid_and_ready == 1'b1) begin
        case(enable_round)
            2'b00 : begin
                next_state = round_1_o;
            end
            2'b01 : begin
                next_state = round_2_o;
            end
            2'b10 : begin
                next_state = round_3_o;
            end
            default : begin
                next_state = round_4_o;
            end
        endcase
    end else begin
        next_state = reg_state;
    end
end

assign temp_din_1 = din[31:0];
assign temp_din_2 = din[63:32];
assign temp_din_3 = din[95:64];
assign temp_din_4 = din[127:96];

always @(*) begin
    if(((oper == 2'b10) || (oper == 2'b11)) && (din_size[2] != 1'b1)) begin
        case(din_size[1:0])
            2'b00 : begin
                round_1_dout_mask = 32'h00000000;
            end
            2'b01 : begin
                round_1_dout_mask = 32'h000000FF;
            end
            2'b10 : begin
                round_1_dout_mask = 32'h0000FFFF;
            end
            default : begin
                round_1_dout_mask = 32'h00FFFFFF;
            end
        endcase
    end else begin
        round_1_dout_mask = 32'hFFFFFFFF;
    end
end

always @(*) begin
    if(((oper == 2'b10) || (oper == 2'b11)) && (din_size[5] != 1'b1)) begin
        case(din_size[4:3])
            2'b00 : begin
                round_2_dout_mask = 32'h00000000;
            end
            2'b01 : begin
                round_2_dout_mask = 32'h000000FF;
            end
            2'b10 : begin
                round_2_dout_mask = 32'h0000FFFF;
            end
            default : begin
                round_2_dout_mask = 32'h00FFFFFF;
            end
        endcase
    end else begin
        round_2_dout_mask = 32'hFFFFFFFF;
    end
end

always @(*) begin
    if(((oper == 2'b10) || (oper == 2'b11)) && (din_size[8] != 1'b1)) begin
        case(din_size[7:6])
            2'b00 : begin
                round_3_dout_mask = 32'h00000000;
            end
            2'b01 : begin
                round_3_dout_mask = 32'h000000FF;
            end
            2'b10 : begin
                round_3_dout_mask = 32'h0000FFFF;
            end
            default : begin
                round_3_dout_mask = 32'h00FFFFFF;
            end
        endcase
    end else begin
        round_3_dout_mask = 32'hFFFFFFFF;
    end
end

always @(*) begin
    if(((oper == 2'b10) || (oper == 2'b11)) && (din_size[11] != 1'b1)) begin
        case(din_size[10:9])
            2'b00 : begin
                round_4_dout_mask = 32'h00000000;
            end
            2'b01 : begin
                round_4_dout_mask = 32'h000000FF;
            end
            2'b10 : begin
                round_4_dout_mask = 32'h0000FFFF;
            end
            default : begin
                round_4_dout_mask = 32'h00FFFFFF;
            end
        endcase
    end else begin
        round_4_dout_mask = 32'hFFFFFFFF;
    end
end

assign temp_din_1_xor_dout = (round_1_dout ^ temp_din_1) & round_1_dout_mask;
assign temp_din_2_xor_dout = (round_2_dout ^ temp_din_2) & round_2_dout_mask;
assign temp_din_3_xor_dout = (round_3_dout ^ temp_din_3) & round_3_dout_mask;
assign temp_din_4_xor_dout = (round_4_dout ^ temp_din_4) & round_4_dout_mask;

always @(*) begin
    if(oper == 2'b11) begin
        duplex_din_1 = temp_din_1_xor_dout;
        duplex_din_2 = temp_din_2_xor_dout;
        duplex_din_3 = temp_din_3_xor_dout;
        duplex_din_4 = temp_din_4_xor_dout;
    end else begin
        duplex_din_1 = temp_din_1;
        duplex_din_2 = temp_din_2;
        duplex_din_3 = temp_din_3;
        duplex_din_4 = temp_din_4;
    end
end

always @(*) begin
    case(din_size[2:0])
        3'b000 : begin
            duplex_din_1_padding = 5'b00001;
        end
        3'b001 : begin
            duplex_din_1_padding = 5'b00010;
        end
        3'b010 : begin
            duplex_din_1_padding = 5'b00100;
        end
        3'b011 : begin
            duplex_din_1_padding = 5'b01000;
        end
        3'b100 : begin
            duplex_din_1_padding = 5'b10000;
        end
        default : begin
            duplex_din_1_padding = 5'b00000;
        end
    endcase
end

always @(*) begin
    case(din_size[5:3])
        3'b000 : begin
            duplex_din_2_padding = 5'b00001;
        end
        3'b001 : begin
            duplex_din_2_padding = 5'b00010;
        end
        3'b010 : begin
            duplex_din_2_padding = 5'b00100;
        end
        3'b011 : begin
            duplex_din_2_padding = 5'b01000;
        end
        3'b100 : begin
            duplex_din_2_padding = 5'b10000;
        end
        default : begin
            duplex_din_2_padding = 5'b00000;
        end
    endcase
end

always @(*) begin
    case(din_size[8:6])
        3'b000 : begin
            duplex_din_3_padding = 5'b00001;
        end
        3'b001 : begin
            duplex_din_3_padding = 5'b00010;
        end
        3'b010 : begin
            duplex_din_3_padding = 5'b00100;
        end
        3'b011 : begin
            duplex_din_3_padding = 5'b01000;
        end
        3'b100 : begin
            duplex_din_3_padding = 5'b10000;
        end
        default : begin
            duplex_din_3_padding = 5'b00000;
        end
    endcase
end

always @(*) begin
    case(din_size[11:9])
        3'b000 : begin
            duplex_din_4_padding = 5'b00001;
        end
        3'b001 : begin
            duplex_din_4_padding = 5'b00010;
        end
        3'b010 : begin
            duplex_din_4_padding = 5'b00100;
        end
        3'b011 : begin
            duplex_din_4_padding = 5'b01000;
        end
        3'b100 : begin
            duplex_din_4_padding = 5'b10000;
        end
        default : begin
            duplex_din_4_padding = 5'b00000;
        end
    endcase
end

assign duplex_din_1_padded[0]     = duplex_din_1[0]   ^ duplex_din_1_padding[0];
assign duplex_din_1_padded[7:1]   = duplex_din_1[7:1];
assign duplex_din_1_padded[8]     = duplex_din_1[8]   ^ duplex_din_1_padding[1];
assign duplex_din_1_padded[15:9]  = duplex_din_1[15:9];
assign duplex_din_1_padded[16]    = duplex_din_1[16]  ^ duplex_din_1_padding[2];
assign duplex_din_1_padded[23:17] = duplex_din_1[23:17];
assign duplex_din_1_padded[24]    = duplex_din_1[24]  ^ duplex_din_1_padding[3];
assign duplex_din_1_padded[31:25] = duplex_din_1[31:25];
assign duplex_din_1_padded[32]    = duplex_din_1_padding[4];

assign duplex_din_2_padded[0]     = duplex_din_2[0]   ^ duplex_din_2_padding[0];
assign duplex_din_2_padded[7:1]   = duplex_din_2[7:1];
assign duplex_din_2_padded[8]     = duplex_din_2[8]   ^ duplex_din_2_padding[1];
assign duplex_din_2_padded[15:9]  = duplex_din_2[15:9];
assign duplex_din_2_padded[16]    = duplex_din_2[16]  ^ duplex_din_2_padding[2];
assign duplex_din_2_padded[23:17] = duplex_din_2[23:17];
assign duplex_din_2_padded[24]    = duplex_din_2[24]  ^ duplex_din_2_padding[3];
assign duplex_din_2_padded[31:25] = duplex_din_2[31:25];
assign duplex_din_2_padded[32]    = duplex_din_2_padding[4];

assign duplex_din_3_padded[0]     = duplex_din_3[0]   ^ duplex_din_3_padding[0];
assign duplex_din_3_padded[7:1]   = duplex_din_3[7:1];
assign duplex_din_3_padded[8]     = duplex_din_3[8]   ^ duplex_din_3_padding[1];
assign duplex_din_3_padded[15:9]  = duplex_din_3[15:9];
assign duplex_din_3_padded[16]    = duplex_din_3[16]  ^ duplex_din_3_padding[2];
assign duplex_din_3_padded[23:17] = duplex_din_3[23:17];
assign duplex_din_3_padded[24]    = duplex_din_3[24]  ^ duplex_din_3_padding[3];
assign duplex_din_3_padded[31:25] = duplex_din_3[31:25];
assign duplex_din_3_padded[32]    = duplex_din_3_padding[4];

assign duplex_din_4_padded[0]     = duplex_din_4[0]   ^ duplex_din_4_padding[0];
assign duplex_din_4_padded[7:1]   = duplex_din_4[7:1];
assign duplex_din_4_padded[8]     = duplex_din_4[8]   ^ duplex_din_4_padding[1];
assign duplex_din_4_padded[15:9]  = duplex_din_4[15:9];
assign duplex_din_4_padded[16]    = duplex_din_4[16]  ^ duplex_din_4_padding[2];
assign duplex_din_4_padded[23:17] = duplex_din_4[23:17];
assign duplex_din_4_padded[24]    = duplex_din_4[24]  ^ duplex_din_4_padding[3];
assign duplex_din_4_padded[31:25] = duplex_din_4[31:25];
assign duplex_din_4_padded[32]    = duplex_din_4_padding[4];

assign round_1_a = reg_state;
assign round_1_din = duplex_din_1_padded;

subterranean_round
round_1 (
    .a(round_1_a),
    .din(round_1_din),
    .o(round_1_o),
    .dout(round_1_dout)
);

assign round_2_a = round_1_o;
assign round_2_din = duplex_din_2_padded;

subterranean_round
round_2 (
    .a(round_2_a),
    .din(round_2_din),
    .o(round_2_o),
    .dout(round_2_dout)
);

assign round_3_a = round_2_o;
assign round_3_din = duplex_din_3_padded;

subterranean_round
round_3 (
    .a(round_3_a),
    .din(round_3_din),
    .o(round_3_o),
    .dout(round_3_dout)
);

assign round_4_a = round_3_o;
assign round_4_din = duplex_din_4_padded;

subterranean_round
round_4 (
    .a(round_4_a),
    .din(round_4_din),
    .o(round_4_o),
    .dout(round_4_dout)
);

always @(*) begin
    if(reg_dout_size != 12'b000000000000) begin
        int_dout_valid = 1'b1;
    end else begin
        int_dout_valid = 1'b0;
    end
end

always @(*) begin
    if((reg_dout_size != 12'b000000000000) && (dout_valid_and_ready != 1'b1)) begin
        int_din_ready = 1'b0;
    end else begin
        int_din_ready = 1'b1;
    end
end

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        next_dout[31:0] = temp_din_1_xor_dout;
        case(enable_round)
            2'b00 : begin
                next_dout[63:32]  = reg_dout[63:32];
                next_dout[95:64]  = reg_dout[95:64];
                next_dout[127:96] = reg_dout[127:96];
            end
            2'b01 : begin
                next_dout[63:32]  = temp_din_2_xor_dout;
                next_dout[95:64]  = reg_dout[95:64];
                next_dout[127:96] = reg_dout[127:96];
            end
            2'b10 : begin
                next_dout[63:32]  = temp_din_2_xor_dout;
                next_dout[95:64]  = temp_din_3_xor_dout;
                next_dout[127:96] = reg_dout[127:96];
            end
            default : begin
                next_dout[63:32]  = temp_din_2_xor_dout;
                next_dout[95:64]  = temp_din_3_xor_dout;
                next_dout[127:96] = temp_din_4_xor_dout;
            end
        endcase
    end else begin
        next_dout = reg_dout;
    end
end

always @(*) begin
    if(din_valid_and_ready == 1'b1) begin
        case(oper)
            // Absorb with output
            2'b01 : begin
                case(enable_round)
                    2'b00 : begin
                        next_dout_size = 12'b000000000100;
                    end
                    2'b01 : begin
                        next_dout_size = 12'b000000100000;
                    end
                    2'b10 : begin
                        next_dout_size = 12'b000100000000;
                    end
                    default : begin
                        next_dout_size = 12'b100000000000;
                    end
                endcase
            end
            // Encrypt, Decrypt
            2'b10, 2'b11 : begin
                next_dout_size = din_size;
            end
            // Absorb no output
            default : begin
                next_dout_size = 12'b000000000000;
            end
        endcase
    end else if(dout_valid_and_ready == 1'b1) begin
        next_dout_size = 12'b000000000000;
    end else begin
        next_dout_size = reg_dout_size;
    end
end

assign din_ready = int_din_ready;
assign dout = reg_dout;
assign dout_valid = int_dout_valid;
assign dout_size = reg_dout_size;

endmodule