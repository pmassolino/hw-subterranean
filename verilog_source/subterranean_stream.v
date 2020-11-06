/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module subterranean_stream
#(parameter ASYNC_RSTN = 1,   // 0 - Synchronous reset in high, 1 - Asynchrouns reset in low.
parameter G_HASH_SIZE_WORDS = 8,
parameter G_TAG_SIZE_WORDS = 4)
(
    input wire clk,
    input wire arstn,
    // Data in bus
    input wire [31:0] din,
    input wire [2:0] din_size,
    input wire din_last,
    input wire din_valid,
    output wire din_ready,
    // Instruction bus
    input wire [3:0] inst,
    input wire inst_valid,
    output wire inst_ready,
    // Data out bus
    output wire [31:0] dout,
    output wire [2:0] dout_size,
    output wire dout_last,
    output wire dout_valid,
    input wire dout_ready
);

reg [3:0] reg_inst, next_inst;
wire int_inst_ready;
wire sm_inst_ready;

reg int_din_ready;
reg int_din_valid;

wire int_din_valid_and_ready;
wire inst_valid_and_ready;
wire dout_valid_and_ready;

reg [31:0] int_dout;
reg [2:0] int_dout_size;
reg int_dout_last;
reg int_dout_valid;

reg [31:0] reg_buffer, next_buffer;
wire reg_buffer_rst;
wire reg_buffer_din_oper;
wire [1:0] reg_buffer_oper;
reg [2:0] reg_buffer_size, next_buffer_size;
reg is_reg_buffer_size_equal_zero, is_reg_buffer_size_equal_one, is_reg_buffer_size_equal_four;
reg reg_buffer_last, next_buffer_last;
reg reg_buffer_din_ready;
reg reg_buffer_dout_valid;
reg reg_buffer_dout_ready;
wire reg_buffer_dout_valid_and_ready;

reg [3:0] reg_ctr_data, next_ctr_data;
wire [2:0] reg_ctr_data_oper;
reg is_reg_ctr_data_equal_one;

wire p_core_din_valid_and_ready;

wire [2:0] p_core_din_oper;
wire [1:0] sm_p_core_oper;

wire p_core_init;
reg [1:0] p_core_oper;
reg [31:0] p_core_din;
reg [2:0] p_core_din_size;
reg p_core_din_valid;
wire p_core_din_ready;
wire [31:0] p_core_dout;
wire [2:0] p_core_dout_size;
wire p_core_dout_valid;
reg p_core_dout_ready;

wire [2:0] reg_dout_oper;

reg [31:0] reg_compare_tag, next_compare_tag;
wire reg_compare_tag_rst;
wire reg_compare_tag_enable;

reg is_reg_compare_tag_equal_zero;

// Instruction register

assign inst_valid_and_ready = int_inst_ready & inst_valid;

always @(posedge clk) begin
    reg_inst <= next_inst;
end

always @(*) begin
    if((inst_valid_and_ready == 1'b1)) begin
        next_inst = inst;
    end else begin
        next_inst = reg_inst;
    end
end

// Buffer din

assign int_din_valid_and_ready = int_din_valid & int_din_ready;
assign reg_buffer_dout_valid_and_ready = reg_buffer_dout_valid & reg_buffer_dout_ready;

always @(posedge clk) begin
    reg_buffer <= next_buffer;
    reg_buffer_size <= next_buffer_size;
    reg_buffer_last <= next_buffer_last;
end

always @(*) begin
    if(reg_buffer_din_oper == 1'b1) begin
        int_din_ready = reg_buffer_din_ready;
        int_din_valid = din_valid;
    end else begin
        int_din_ready = 1'b0;
        int_din_valid = 1'b0;
    end
end

always @(*) begin
    case(reg_buffer_oper)
        // Shift 8 bits data
        2'b01 : begin
            if((reg_buffer_dout_valid_and_ready == 1'b1)) begin
                next_buffer[23:0]  = reg_buffer[31:8];
                next_buffer[31:24] = 8'b0;
            end else begin
                next_buffer = reg_buffer;
            end
        end
        // Load data from outside
        2'b10, 2'b11 : begin
            if((int_din_valid_and_ready == 1'b1)) begin
                case(din_size)
                    3'b000 : begin
                        next_buffer = 32'b0;
                    end
                    3'b001 : begin
                        next_buffer[7:0] = din[7:0];
                        next_buffer[31:8] = 24'b0;
                    end
                    3'b010 : begin
                        next_buffer[15:0] = din[15:0];
                        next_buffer[31:16] = 16'b0;
                    end
                    3'b011 : begin
                        next_buffer[23:0] = din[23:0];
                        next_buffer[31:24] = 8'b0;
                    end
                    default : begin
                        next_buffer = din;
                    end
                endcase
            end else begin
                next_buffer = reg_buffer;
            end
        end
        default : begin
            next_buffer = reg_buffer;
        end
    endcase
end

always @(*) begin
    if(reg_buffer_size == 0) begin
        is_reg_buffer_size_equal_zero = 1'b1;
    end else begin
        is_reg_buffer_size_equal_zero = 1'b0;
    end
end

always @(*) begin
    if(reg_buffer_size == 1) begin
        is_reg_buffer_size_equal_one = 1'b1;
    end else begin
        is_reg_buffer_size_equal_one = 1'b0;
    end
end

always @(*) begin
    if(reg_buffer_size == 4) begin
        is_reg_buffer_size_equal_four = 1'b1;
    end else begin
        is_reg_buffer_size_equal_four = 1'b0;
    end
end

always @(*) begin
    if(reg_buffer_rst == 1'b1) begin
        next_buffer_size = 3'b000;
    end else begin
        case(reg_buffer_oper)
            // Shift 8 bits data
            2'b01 : begin
                if(is_reg_buffer_size_equal_zero == 1'b1) begin
                    next_buffer_size = reg_buffer_size;
                end else begin
                    next_buffer_size = reg_buffer_size - 1;
                end
            end
            // Load data from outside
            2'b10, 2'b11 : begin
                if((int_din_valid_and_ready == 1'b1)) begin
                    next_buffer_size = din_size;
                end else begin
                    if(reg_buffer_dout_valid_and_ready == 1'b1) begin
                        next_buffer_size = 0;
                    end else begin
                        next_buffer_size = reg_buffer_size;
                    end
                end
            end
            default : begin
                next_buffer_size = reg_buffer_size;
            end
        endcase
    end
end

always @(*) begin
    if(reg_buffer_rst == 1'b1) begin
        next_buffer_last = 1'b0;
    end else begin
        case(reg_buffer_oper)
            // Load data from outside
            2'b10,2'b11 : begin
                if((int_din_valid_and_ready == 1'b1)) begin
                    next_buffer_last = din_last;
                end else begin
                    next_buffer_last = reg_buffer_last;
                end
            end
            default : begin
                next_buffer_last = reg_buffer_last;
            end
        endcase
    end
end

always @(*) begin
    if((is_reg_buffer_size_equal_zero == 1'b0)) begin
        reg_buffer_dout_valid = 1'b1;
    end else begin
        reg_buffer_dout_valid = 1'b0;
    end
end

always @(*) begin
    case(reg_buffer_oper)
        // Shift 8 bits data
        2'b01 : begin
            if((is_reg_buffer_size_equal_zero == 1'b1)) begin
                reg_buffer_din_ready = 1'b1;
            end else begin
                reg_buffer_din_ready = 1'b0;
            end
        end
        default : begin
            if((is_reg_buffer_size_equal_zero == 1'b1)) begin
                reg_buffer_din_ready = 1'b1;
            end else begin
                if(reg_buffer_dout_valid_and_ready == 1'b1) begin
                    reg_buffer_din_ready = 1'b1;
                end else begin
                    reg_buffer_din_ready = 1'b0;
                end
            end
        end
    endcase
end

assign p_core_din_valid_and_ready = p_core_din_valid & p_core_din_ready;

// Permutation core

always @(*) begin
    case(p_core_din_oper)
        // Loads empty value
        3'b001 : begin
            p_core_din = 32'b0;
            p_core_din_size = 3'b000;
            p_core_din_valid = 1'b1;
            reg_buffer_dout_ready = 1'b0;
        end
        // Loads 8 bits of data
        3'b010 : begin
            p_core_din[7:0]  = reg_buffer[7:0];
            p_core_din[31:8] = 24'b0;
            p_core_din_valid = reg_buffer_dout_valid;
            reg_buffer_dout_ready = p_core_din_ready;
            if(is_reg_buffer_size_equal_zero == 1'b1) begin
                p_core_din_size  = 3'b000;
            end else begin
                p_core_din_size  = 3'b001;
            end
        end
        // Connected directly to the buffer
        3'b011 : begin
            p_core_din = reg_buffer;
            p_core_din_size = reg_buffer_size;
            p_core_din_valid = reg_buffer_dout_valid;
            reg_buffer_dout_ready = p_core_din_ready;
        end
        // Tag mode 
        3'b100 : begin
            p_core_din = 32'b0;
            p_core_din_size = 3'b000;
            p_core_din_valid = reg_buffer_dout_valid;
            reg_buffer_dout_ready = p_core_dout_valid;
        end
        // Unconnected
        default : begin
            p_core_din = 32'b0;
            p_core_din_size = 3'b000;
            p_core_din_valid = 1'b0;
            reg_buffer_dout_ready = 1'b0;
        end
    endcase
end

always @(*) begin
    if(sm_p_core_oper[1] == 1'b1) begin
        if(reg_inst[0] == 1'b0) begin
            p_core_oper = 2'b10;
        end else begin
            p_core_oper = 2'b11;
        end
    end else begin
        p_core_oper = sm_p_core_oper;
    end
end

subterranean_rounds_simple_1
#(.ASYNC_RSTN(ASYNC_RSTN))
p_core
(
    .clk(clk),
    .arstn(arstn),
    .init(p_core_init),
    .oper(p_core_oper),
    .din(p_core_din),
    .din_size(p_core_din_size),
    .din_valid(p_core_din_valid),
    .din_ready(p_core_din_ready),
    .dout(p_core_dout),
    .dout_size(p_core_dout_size),
    .dout_valid(p_core_dout_valid),
    .dout_ready(p_core_dout_ready)
);

always @(posedge clk) begin
    reg_ctr_data <= next_ctr_data;
end

always @(*) begin
    case(reg_ctr_data_oper)
        3'b001 : begin
            next_ctr_data = 6;
        end
        3'b010 : begin
            next_ctr_data = G_HASH_SIZE_WORDS;
        end
        3'b011 : begin
            next_ctr_data = G_TAG_SIZE_WORDS;
        end
        3'b100 : begin
            next_ctr_data = reg_ctr_data - 1;
        end
        3'b101 : begin
            if(dout_valid_and_ready == 1'b1) begin
                next_ctr_data = reg_ctr_data - 1;
            end else begin
                next_ctr_data = reg_ctr_data;
            end
        end
        default : begin
            next_ctr_data = reg_ctr_data;
        end
    endcase
end

always @(*) begin
    if(reg_ctr_data == 1) begin
        is_reg_ctr_data_equal_one = 1'b1;
    end else begin
        is_reg_ctr_data_equal_one = 1'b0;
    end
end

// Dout connection

assign dout_valid_and_ready = int_dout_valid & dout_ready;

always @(*) begin
    case(reg_dout_oper)
        // Ciphertext/Plaintext mode
        3'b001 : begin
            int_dout = p_core_dout;
            int_dout_size = p_core_dout_size;
            int_dout_last = reg_buffer_last;
            int_dout_valid = p_core_dout_valid;
            p_core_dout_ready = dout_ready;
        end
        // Hash/Tag generation
        3'b010 : begin
            int_dout = p_core_dout;
            int_dout_size = p_core_dout_size;
            int_dout_last = is_reg_ctr_data_equal_one;
            int_dout_valid = p_core_dout_valid;
            p_core_dout_ready = dout_ready;
        end
        // Valid tag received
        3'b011 : begin
            int_dout[31:4] = 28'b0;
            int_dout[3:1]  = 3'b111;
            int_dout[0]    = ~is_reg_compare_tag_equal_zero;
            int_dout_size = 3'b001;
            int_dout_last = 1'b1;
            int_dout_valid = 1'b1;
            p_core_dout_ready = 1'b0;
        end
        // Tag validation
        3'b100 : begin
            int_dout = p_core_dout;
            int_dout_size = p_core_dout_size;
            int_dout_last = is_reg_ctr_data_equal_one;
            int_dout_valid = 1'b0;
            p_core_dout_ready = reg_buffer_dout_valid;
        end
        // No connection
        default : begin
            int_dout = 32'b0;
            int_dout_size = 3'b000;
            int_dout_last = 1'b0;
            int_dout_valid = 1'b0;
            p_core_dout_ready = 1'b1;
        end
    endcase
end

always @(posedge clk) begin
    reg_compare_tag <= next_compare_tag;
end

always @(*) begin
    if(reg_compare_tag_rst == 1'b1) begin
        next_compare_tag = 32'b0;
    end else begin
        if((reg_compare_tag_enable == 1'b1) && (reg_buffer_dout_valid == 1'b1) && (p_core_dout_valid == 1'b1)) begin
            next_compare_tag = reg_compare_tag | (p_core_dout ^ reg_buffer);
        end else begin
            next_compare_tag = reg_compare_tag;
        end
    end
end

always @(*) begin
    if(reg_compare_tag == 32'b0) begin
        is_reg_compare_tag_equal_zero = 1'b1;
    end else begin
        is_reg_compare_tag_equal_zero = 1'b0;
    end
end

subterranean_stream_state_machine
#(.ASYNC_RSTN(ASYNC_RSTN))
state_machine
(
    .clk(clk),
    .arstn(arstn),
    // Data in bus
    .din_last(din_last),
    .int_din_valid_and_ready(int_din_valid_and_ready),
    .reg_buffer_rst(reg_buffer_rst),
    .reg_buffer_oper(reg_buffer_oper),
    .reg_buffer_din_oper(reg_buffer_din_oper),
    .is_reg_buffer_size_equal_zero(is_reg_buffer_size_equal_zero),
    .is_reg_buffer_size_equal_one(is_reg_buffer_size_equal_one),
    .is_reg_buffer_size_equal_four(is_reg_buffer_size_equal_four),
    .reg_buffer_last(reg_buffer_last),
    .is_reg_ctr_data_equal_one(is_reg_ctr_data_equal_one),
    .reg_ctr_data_oper(reg_ctr_data_oper),
    // Instruction bus
    .inst(inst),
    .inst_valid_and_ready(inst_valid_and_ready),
    .inst_ready(sm_inst_ready),
    .reg_inst(reg_inst),
    // Permutation core
    .p_core_init(p_core_init),
    .sm_p_core_oper(sm_p_core_oper),
    .p_core_din_oper(p_core_din_oper),
    // Tag compare register
    .reg_compare_tag_rst(reg_compare_tag_rst),
    .reg_compare_tag_enable(reg_compare_tag_enable),
    // Dout
    .dout_valid_and_ready(dout_valid_and_ready),
    .reg_dout_oper(reg_dout_oper)
);

assign dout = int_dout;
assign dout_size = int_dout_size;
assign dout_last = int_dout_last;
assign dout_valid = int_dout_valid;

assign din_ready = int_din_ready;

assign int_inst_ready = sm_inst_ready;
assign inst_ready = int_inst_ready;

endmodule