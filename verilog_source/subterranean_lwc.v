/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module subterranean_lwc
#(parameter ASYNC_RSTN = 0,  // 0 - Synchronous reset in high, 1 - Asynchrouns reset in low.
parameter G_PWIDTH = 32,
parameter G_SWIDTH = 32,
parameter G_SEGMENT_SIZE_BITS = 16,
parameter G_HASH_SIZE_WORDS = 8,
parameter G_TAG_SIZE_WORDS = 4
)
(
    input wire clk,
    input wire rst,
    // PDI data bus
    input wire [(G_PWIDTH-1):0] pdi_data,
    input wire pdi_valid,
    output wire pdi_ready,
    // SDI data bus
    input wire [(G_SWIDTH-1):0] sdi_data,
    input wire sdi_valid,
    output wire sdi_ready,
    // DO data bus
    output wire [(G_PWIDTH-1):0] do_data,
    output wire do_valid,
    input wire do_ready,
    output wire do_last
);

wire pdi_valid_and_ready;
wire sdi_valid_and_ready;

wire [(G_PWIDTH-1):0] pdi_buffer_din;
wire pdi_buffer_din_valid;
wire pdi_buffer_din_ready;
wire [(G_PWIDTH-1):0] pdi_buffer_dout;
wire pdi_buffer_dout_valid;
reg  pdi_buffer_dout_ready;
wire pdi_buffer_in_enable;
wire pdi_buffer_out_enable;
wire pdi_buffer_rst;
reg [2:0] reg_pdi_buffer_dout_size, next_pdi_buffer_dout_size;
reg reg_pdi_buffer_dout_last, next_pdi_buffer_dout_last;

wire sm_pdi_ready;
wire int_pdi_ready;

wire [(G_PWIDTH-1):0] sdi_buffer_din;
wire sdi_buffer_din_valid;
wire sdi_buffer_din_ready;
wire [(G_PWIDTH-1):0] sdi_buffer_dout;
wire sdi_buffer_dout_valid;
reg  sdi_buffer_dout_ready;
wire sdi_buffer_in_enable;
wire sdi_buffer_out_enable;
wire sdi_buffer_rst;
reg [2:0] reg_sdi_buffer_dout_size, next_sdi_buffer_dout_size;
reg reg_sdi_buffer_dout_last, next_sdi_buffer_dout_last;

wire reg_buffer_dout_size_enable;

wire sm_sdi_ready;
wire int_sdi_ready;

reg [31:0] temp_data;
reg [2:0] temp_data_size;
reg temp_data_last;
reg temp_valid;
wire temp_ready;
wire sm_temp_ready;
wire [1:0] temp_data_oper;

wire temp_valid_and_ready;

wire [31:0] cipher_din;
wire [2:0] cipher_din_size;
wire cipher_din_last;
wire cipher_din_valid;
wire cipher_din_ready;
wire cipher_din_enable;
wire [3:0] cipher_inst;
reg cipher_inst_valid;
wire cipher_inst_ready;
wire cipher_inst_enable;
wire [31:0] cipher_dout;
wire [2:0] cipher_dout_size;
wire cipher_dout_last;
wire cipher_dout_valid;
wire cipher_dout_ready;
wire cipher_dout_enable;

reg [(G_SEGMENT_SIZE_BITS-1):0] reg_data_size, next_data_size;
wire [1:0] reg_data_size_oper;
reg is_reg_data_size_less_equal_four;
reg is_reg_data_size_load_zero;

reg [3:0] reg_inst, next_inst;
wire reg_inst_enable;

reg reg_segment_end_of_type, next_segment_end_of_type;
wire reg_segment_end_of_type_enable;

reg [(G_PWIDTH-1):0] do_buffer_din;
reg do_buffer_din_last;
reg do_buffer_din_valid;
wire do_buffer_din_ready;
wire [(G_PWIDTH-1):0] do_buffer_dout;
wire do_buffer_dout_last;
wire do_buffer_dout_valid;
wire do_buffer_dout_ready;
wire do_buffer_in_enable;
wire do_buffer_out_enable;
wire do_buffer_rst;

wire [2:0] do_buffer_din_type;

assign pdi_valid_and_ready = pdi_valid & int_pdi_ready;
assign sdi_valid_and_ready = sdi_valid & int_sdi_ready;

assign int_pdi_ready = sm_pdi_ready | pdi_buffer_din_ready | cipher_inst_ready;

assign pdi_buffer_din = pdi_data;
assign pdi_buffer_din_valid = pdi_valid;

subterranean_lwc_buffer_in
#(.G_WIDTH(G_PWIDTH)
)
pdi_buffer
(
    .clk(clk),
    .din(pdi_buffer_din),
    .din_valid(pdi_buffer_din_valid),
    .din_ready(pdi_buffer_din_ready),
    .dout(pdi_buffer_dout),
    .dout_valid(pdi_buffer_dout_valid),
    .dout_ready(pdi_buffer_dout_ready),
    .buffer_in_enable(pdi_buffer_in_enable),
    .buffer_out_enable(pdi_buffer_out_enable),
    .buffer_rst(pdi_buffer_rst)
);

assign int_sdi_ready = sm_sdi_ready | sdi_buffer_din_ready;

assign sdi_buffer_din = sdi_data;
assign sdi_buffer_din_valid = sdi_valid;

subterranean_lwc_buffer_in
#(.G_WIDTH(G_SWIDTH)
)
sdi_buffer
(
    .clk(clk),
    .din(sdi_buffer_din),
    .din_valid(sdi_buffer_din_valid),
    .din_ready(sdi_buffer_din_ready),
    .dout(sdi_buffer_dout),
    .dout_valid(sdi_buffer_dout_valid),
    .dout_ready(sdi_buffer_dout_ready),
    .buffer_in_enable(sdi_buffer_in_enable),
    .buffer_out_enable(sdi_buffer_out_enable),
    .buffer_rst(sdi_buffer_rst)
);

always @(posedge clk) begin
    reg_pdi_buffer_dout_size <= next_pdi_buffer_dout_size;
    reg_pdi_buffer_dout_last <= next_pdi_buffer_dout_last;
    reg_sdi_buffer_dout_size <= next_sdi_buffer_dout_size;
    reg_sdi_buffer_dout_last <= next_sdi_buffer_dout_last;
end

always @(*) begin
    if((pdi_buffer_din_valid == 1'b1) && (pdi_buffer_din_ready == 1'b1)) begin
        if((is_reg_data_size_less_equal_four == 1'b1) && (reg_buffer_dout_size_enable == 1'b1) && (reg_segment_end_of_type == 1'b1)) begin
            next_pdi_buffer_dout_size = reg_data_size[2:0];
            next_pdi_buffer_dout_last = 1'b1;
        end else begin
            next_pdi_buffer_dout_size = 3'b100;
            next_pdi_buffer_dout_last = 1'b0;
        end
    end else begin
        next_pdi_buffer_dout_size = reg_pdi_buffer_dout_size;
        next_pdi_buffer_dout_last = reg_pdi_buffer_dout_last;
    end
end

always @(*) begin
    if((sdi_buffer_din_valid == 1'b1) && (sdi_buffer_din_ready == 1'b1)) begin
        if((is_reg_data_size_less_equal_four == 1'b1) && (reg_buffer_dout_size_enable == 1'b1)) begin
            next_sdi_buffer_dout_size = reg_data_size[2:0];
            next_sdi_buffer_dout_last = 1'b1;
        end else begin
            next_sdi_buffer_dout_size = 3'b100;
            next_sdi_buffer_dout_last = 1'b0;
        end
    end else begin
        next_sdi_buffer_dout_size = reg_sdi_buffer_dout_size;
        next_sdi_buffer_dout_last = reg_sdi_buffer_dout_last;
    end
end

assign temp_valid_and_ready = temp_valid & temp_ready;

assign temp_ready = sm_temp_ready | cipher_din_ready;

always @(*) begin
    case(temp_data_oper)
        // SM <-> temp_data
        2'b01 : begin
            temp_data = 32'b0;
            temp_valid = 1'b1;
            temp_data_size = 3'b000; 
            temp_data_last = 1'b1;
            pdi_buffer_dout_ready = 1'b0;
            sdi_buffer_dout_ready = 1'b0;
        end
        // PDI <-> temp_data
        2'b10 : begin
            temp_data = pdi_buffer_dout;
            temp_valid = pdi_buffer_dout_valid;
            temp_data_size = reg_pdi_buffer_dout_size;
            temp_data_last = reg_pdi_buffer_dout_last;
            pdi_buffer_dout_ready = temp_ready;
            sdi_buffer_dout_ready = 1'b0;
        end
        // SDI <-> temp_data
        2'b11 : begin
            temp_data  = sdi_buffer_dout;
            temp_valid = sdi_buffer_dout_valid;
            temp_data_size = reg_sdi_buffer_dout_size; 
            temp_data_last = reg_sdi_buffer_dout_last;
            sdi_buffer_dout_ready = temp_ready;
            pdi_buffer_dout_ready = 1'b0;
        end
        // Empty <-> temp_data
        default : begin
            temp_data = 32'b0;
            temp_valid = 1'b0;
            temp_data_size = 3'b000; 
            temp_data_last = 1'b0;
            pdi_buffer_dout_ready = 1'b0;
            sdi_buffer_dout_ready = 1'b0;
        end
    endcase
end

always @(*) begin
    if(temp_data[(G_SEGMENT_SIZE_BITS-1):0] == 0) begin
        is_reg_data_size_load_zero = 1'b1;
    end else begin
        is_reg_data_size_load_zero = 1'b0;
    end
end

assign cipher_din[7:0]   = temp_data[31:24];
assign cipher_din[15:8]  = temp_data[23:16];
assign cipher_din[23:16] = temp_data[15:8];
assign cipher_din[31:24] = temp_data[7:0];

assign cipher_din_valid = temp_valid;
assign cipher_din_last = temp_data_last;
assign cipher_din_size = temp_data_size;

assign cipher_inst = pdi_data[(G_PWIDTH-1):(G_PWIDTH-4)];

always @(*) begin
    if((pdi_valid == 1'b1) && reg_inst_enable == 1'b1) begin
        cipher_inst_valid = 1'b1;
    end else begin
        cipher_inst_valid = 1'b0;
    end
end

assign cipher_dout_ready = do_buffer_din_ready;

subterranean_stream
#(.ASYNC_RSTN(ASYNC_RSTN),
.G_HASH_SIZE_WORDS(G_HASH_SIZE_WORDS),
.G_TAG_SIZE_WORDS(G_TAG_SIZE_WORDS))
cipher
(
    .clk(clk),
    .arstn(rst),
    // Data in bus
    .din(cipher_din),
    .din_size(cipher_din_size),
    .din_last(cipher_din_last),
    .din_valid(cipher_din_valid),
    .din_ready(cipher_din_ready),
    .din_enable(cipher_din_enable),
    // Instruction bus
    .inst(cipher_inst),
    .inst_valid(cipher_inst_valid),
    .inst_ready(cipher_inst_ready),
    .inst_enable(cipher_inst_enable),
    // Data out bus
    .dout(cipher_dout),
    .dout_size(cipher_dout_size),
    .dout_last(cipher_dout_last),
    .dout_valid(cipher_dout_valid),
    .dout_ready(cipher_dout_ready),
    .dout_enable(cipher_dout_enable)
);

always @(posedge clk) begin
    reg_data_size <= next_data_size;
end

always @(*) begin
    case(reg_data_size_oper)
        2'b01 : begin
            next_data_size = temp_data[(G_SEGMENT_SIZE_BITS-1):0];
        end
        2'b10 : begin
            if((pdi_valid_and_ready == 1'b1) || (sdi_valid_and_ready == 1'b1)) begin
                if(is_reg_data_size_less_equal_four == 1'b1) begin
                    next_data_size = 0;
                end else begin
                    next_data_size = reg_data_size - 4;
                end
            end else begin
                next_data_size = reg_data_size;
            end
        end
    default : begin
        next_data_size = reg_data_size;
    end
    endcase
end

always @(*) begin
    if(reg_data_size <= 4) begin
        is_reg_data_size_less_equal_four = 1'b1;
    end else begin
        is_reg_data_size_less_equal_four = 1'b0;
    end
end

always @(posedge clk) begin
    reg_inst <= next_inst;
end

always @(*) begin
    if((pdi_valid == 1'b1) && reg_inst_enable == 1'b1) begin
        next_inst = pdi_data[31:28];
    end else begin
        next_inst = reg_inst;
    end
end

always @(posedge clk) begin
    reg_segment_end_of_type <= next_segment_end_of_type;
end

always @(*) begin
    if((temp_valid == 1'b1) && reg_segment_end_of_type_enable == 1'b1) begin
        next_segment_end_of_type = temp_data[25];
    end else begin
        next_segment_end_of_type = reg_segment_end_of_type;
    end
end

always @(*) begin
    case(do_buffer_din_type)
        // Status header for hash instruction
        3'b001 : begin
            do_buffer_din[31:28] = 4'b1001;
            do_buffer_din[27:24] = 4'b0011;
            do_buffer_din[23:16] = 8'h00;
            do_buffer_din[15:0]  = G_HASH_SIZE_WORDS*4;
            do_buffer_din_valid  = 1'b1;
            do_buffer_din_last   = 1'b0;
        end
        // Status header for ciphertext/plaintext
        3'b010 : begin
            if(reg_inst[0] == 1'b0)begin
                do_buffer_din[31:28] = 4'b0101;
                do_buffer_din[27:24] = {2'b00, temp_data[25], 1'b0};
                do_buffer_din[23:G_SEGMENT_SIZE_BITS]  = {(23+1-G_SEGMENT_SIZE_BITS){1'b0}};
                do_buffer_din[G_SEGMENT_SIZE_BITS-1:0] = temp_data[G_SEGMENT_SIZE_BITS-1:0];
                do_buffer_din_valid  = 1'b1;
                do_buffer_din_last   = 1'b0;
            end else begin
                do_buffer_din[31:28] = 4'b0100;
                do_buffer_din[27:24] = {2'b00, temp_data[25], temp_data[25]};
                do_buffer_din[23:G_SEGMENT_SIZE_BITS]  = {(23+1-G_SEGMENT_SIZE_BITS){1'b0}};
                do_buffer_din[G_SEGMENT_SIZE_BITS-1:0] = temp_data[G_SEGMENT_SIZE_BITS-1:0];
                do_buffer_din_valid  = 1'b1;
                do_buffer_din_last   = 1'b0;
            end
        end
        // Status header for tag
        3'b100 : begin
            do_buffer_din[31:28] = 4'b1000;
            do_buffer_din[27:24] = 4'b0011;
            do_buffer_din[23:16] = 8'h00;
            do_buffer_din[15:0]  = G_TAG_SIZE_WORDS*4;
            do_buffer_din_valid  = 1'b1;
            do_buffer_din_last   = 1'b0;
        end
        // Status instruction for correct execution
        3'b101 : begin
            do_buffer_din[31:28] = 4'b1110;
            do_buffer_din[27:24] = 4'b0000;
            do_buffer_din[23:16] = 8'h00;
            do_buffer_din[15:0]  = 16'h0000;
            do_buffer_din_valid  = 1'b1;
            do_buffer_din_last   = 1'b1;
        end
        // Status instruction for tag verification
        3'b110 : begin
            do_buffer_din[31:28] = cipher_dout[3:0];
            do_buffer_din[27:24] = 4'b0000;
            do_buffer_din[23:16] = 8'h00;
            do_buffer_din[15:0]  = 16'h0000;
            do_buffer_din_valid  = cipher_dout_valid;
            do_buffer_din_last   = 1'b1;
        end
        3'b111 : begin
            do_buffer_din = {32{1'b0}};
            do_buffer_din_valid = 1'b0;
            do_buffer_din_last  = 1'b0;
        end
        // Value comes from the cipher core
        default : begin
            // Because of the notation of the LWC API the values have to changed positions.
            do_buffer_din[31:24] = cipher_dout[7:0];
            do_buffer_din[23:16] = cipher_dout[15:8];
            do_buffer_din[15:8]  = cipher_dout[23:16];
            do_buffer_din[7:0]   = cipher_dout[31:24];
            do_buffer_din_valid  = cipher_dout_valid;
            do_buffer_din_last   = cipher_dout_last;
        end
    endcase
end

assign do_buffer_dout_ready = do_ready;

subterranean_lwc_buffer_out
#(.G_WIDTH(G_PWIDTH)
)
do_buffer
(
    .clk(clk),
    .din(do_buffer_din),
    .din_last(do_buffer_din_last),
    .din_valid(do_buffer_din_valid),
    .din_ready(do_buffer_din_ready),
    .dout(do_buffer_dout),
    .dout_last(do_buffer_dout_last),
    .dout_valid(do_buffer_dout_valid),
    .dout_ready(do_buffer_dout_ready),
    .buffer_in_enable(do_buffer_in_enable),
    .buffer_out_enable(do_buffer_out_enable),
    .buffer_rst(do_buffer_rst)
);

subterranean_lwc_state_machine
#(.ASYNC_RSTN(ASYNC_RSTN),
.G_PWIDTH(G_PWIDTH),
.G_SWIDTH(G_SWIDTH))
state_machine
(
    .clk(clk),
    .rst(rst),
    .pdi_data(pdi_data),
    .pdi_valid_and_ready(pdi_valid_and_ready),
    .sm_pdi_ready(sm_pdi_ready),
    .pdi_buffer_in_enable(pdi_buffer_in_enable),
    .pdi_buffer_out_enable(pdi_buffer_out_enable),
    .pdi_buffer_rst(pdi_buffer_rst),
    .sdi_data(sdi_data),
    .sdi_valid_and_ready(sdi_valid_and_ready),
    .sm_sdi_ready(sm_sdi_ready),
    .sdi_buffer_in_enable(sdi_buffer_in_enable),
    .sdi_buffer_out_enable(sdi_buffer_out_enable),
    .sdi_buffer_rst(sdi_buffer_rst),
    .reg_buffer_dout_size_enable(reg_buffer_dout_size_enable),
    .temp_data(temp_data),
    .temp_valid_and_ready(temp_valid_and_ready),
    .temp_data_oper(temp_data_oper),
    .sm_temp_ready(sm_temp_ready),
    .cipher_din_ready(cipher_din_ready),
    .cipher_din_enable(cipher_din_enable),
    .cipher_inst_enable(cipher_inst_enable),
    .cipher_inst_ready(cipher_inst_ready),
    .cipher_dout_last(cipher_dout_last),
    .cipher_dout_valid(cipher_dout_valid),
    .cipher_dout_ready(cipher_dout_ready),
    .cipher_dout_enable(cipher_dout_enable),
    .reg_data_size_oper(reg_data_size_oper),
    .is_reg_data_size_less_equal_four(is_reg_data_size_less_equal_four),
    .is_reg_data_size_load_zero(is_reg_data_size_load_zero),
    .reg_inst(reg_inst),
    .reg_inst_enable(reg_inst_enable),
    .reg_segment_end_of_type(reg_segment_end_of_type),
    .reg_segment_end_of_type_enable(reg_segment_end_of_type_enable),
    .do_buffer_din_ready(do_buffer_din_ready),
    .do_buffer_in_enable(do_buffer_in_enable),
    .do_buffer_out_enable(do_buffer_out_enable),
    .do_buffer_rst(do_buffer_rst),
    .do_buffer_din_type(do_buffer_din_type)
);

assign pdi_ready = int_pdi_ready;
assign sdi_ready = int_sdi_ready;
assign do_data  = do_buffer_dout;
assign do_valid = do_buffer_dout_valid;
assign do_last  = do_buffer_dout_last;

endmodule