/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module subterranean_rounds_simple_1
#(parameter ASYNC_RSTN = 1// 0 - Synchronous reset in high, 1 - Asynchrouns reset in low.
)
(
    input wire clk,
    input wire arstn,
    input wire enable,
    input wire init,
    input wire encrypt,
    input wire decrypt,
    input wire [31:0] din,
    input wire [2:0] din_size,
    input wire din_valid,
    output wire din_ready,
    output wire [31:0] dout,
    output wire dout_valid,
    input wire dout_ready,
    output wire free,
    output wire finish
);

wire int_din_ready;
wire int_dout_valid;

wire [31:0] temp_din_1;
wire [31:0] temp_din_1_xor_dout;
reg [31:0] duplex_din_1;
reg [4:0] duplex_din_1_padding;
wire [32:0] duplex_din_1_padded;

wire [256:0] round_1_a;
wire [32:0]  round_1_din;
wire [256:0] round_1_o;
wire [31:0]  round_1_dout;

reg [31:0] round_1_dout_mask;

reg [256:0] reg_state;
reg [256:0] next_state;

reg reg_finish;
reg next_finish;

wire din_valid_dout_ready;

assign int_din_ready = (enable == 1'b1) ? dout_ready : 1'b0;

assign din_valid_dout_ready = din_valid & int_din_ready;

always @(posedge clk) begin
    reg_state <= next_state;
end

always @(*) begin
    if(init == 1'b1) begin
        next_state = 257'h0;
    end else if (din_valid_dout_ready == 1'b1) begin
        next_state = round_1_o;
    end else begin
        next_state = reg_state;
    end
end

generate
    if (ASYNC_RSTN != 0) begin : use_asynchrnous_reset_zero_enable
        always @(posedge clk or negedge arstn) begin
            if (arstn == 1'b0) begin
                reg_finish <= 1'b0;
            end else begin
                reg_finish <= next_finish;
            end
        end
    end else begin
        always @(posedge clk) begin
            if (arstn == 1'b1) begin
                reg_finish <= 1'b0;
            end else begin
                reg_finish <= next_finish;
            end
        end
    end
endgenerate

always @(*) begin
    if(din_valid_dout_ready == 1'b1) begin
        next_finish = 1'b1;
    end else begin
        next_finish = 1'b0;
    end
end

assign temp_din_1 = din[31:0];

always @(*) begin
    if(((encrypt == 1'b1) || (decrypt == 1'b1)) && (din_size[2] != 1'b1)) begin
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

assign temp_din_1_xor_dout = (round_1_dout & round_1_dout_mask) ^ temp_din_1;

always @(*) begin
    if(decrypt == 1'b1) begin
        duplex_din_1 = temp_din_1_xor_dout;
    end else begin
        duplex_din_1 = temp_din_1;
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

assign duplex_din_1_padded[0]     = duplex_din_1[0]   ^ duplex_din_1_padding[0];
assign duplex_din_1_padded[7:1]   = duplex_din_1[7:1];
assign duplex_din_1_padded[8]     = duplex_din_1[8]   ^ duplex_din_1_padding[1];
assign duplex_din_1_padded[15:9]  = duplex_din_1[15:9];
assign duplex_din_1_padded[16]    = duplex_din_1[16]  ^ duplex_din_1_padding[2];
assign duplex_din_1_padded[23:17] = duplex_din_1[23:17];
assign duplex_din_1_padded[24]    = duplex_din_1[24]  ^ duplex_din_1_padding[3];
assign duplex_din_1_padded[31:25] = duplex_din_1[31:25];
assign duplex_din_1_padded[32]    = duplex_din_1_padding[4];

assign round_1_a = reg_state;
assign round_1_din = duplex_din_1_padded;

subterranean_round
round_1 (
    .a(round_1_a),
    .din(round_1_din),
    .o(round_1_o),
    .dout(round_1_dout)
);

assign int_dout_valid = (enable == 1'b1) ? din_valid : 1'b0;

assign din_ready = int_din_ready;
assign dout[31:0]  = temp_din_1_xor_dout;
assign dout_valid = int_dout_valid;
assign free = 1'b1;
assign finish = reg_finish;

endmodule