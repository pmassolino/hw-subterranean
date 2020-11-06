/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module subterranean_stream_state_machine
#(parameter ASYNC_RSTN = 1)
(
    input wire clk,
    input wire arstn,
    // Data in bus
    input wire din_last,
    input wire int_din_valid_and_ready,
    output wire reg_buffer_rst,
    output wire [1:0] reg_buffer_oper,
    output wire reg_buffer_din_oper,
    input wire is_reg_buffer_size_equal_zero,
    input wire is_reg_buffer_size_equal_one,
    input wire is_reg_buffer_size_equal_four,
    input wire reg_buffer_last,
    input wire is_reg_ctr_data_equal_one,
    output wire [2:0] reg_ctr_data_oper,
    // Instruction bus
    input wire [3:0] inst,
    input wire inst_valid_and_ready,
    output wire inst_ready,
    input wire [3:0] reg_inst,
    // Permutation core
    output wire p_core_init,
    output wire [1:0] sm_p_core_oper,
    output wire [2:0] p_core_din_oper,
    // Tag compare register
    output wire reg_compare_tag_rst,
    output wire reg_compare_tag_enable,
    // Dout
    input wire dout_valid_and_ready,
    output wire [2:0] reg_dout_oper
);

reg reg_reg_buffer_rst, next_reg_buffer_rst;
reg [1:0] reg_reg_buffer_oper, next_reg_buffer_oper;
reg reg_reg_buffer_din_oper, next_reg_buffer_din_oper;
reg [2:0] reg_reg_ctr_data_oper, next_reg_ctr_data_oper;
reg reg_inst_ready, next_inst_ready;
reg reg_p_core_init, next_p_core_init;
reg [1:0] reg_sm_p_core_oper, next_sm_p_core_oper;
reg [2:0] reg_p_core_din_oper, next_p_core_din_oper;
reg reg_reg_compare_tag_rst, next_reg_compare_tag_rst;
reg reg_reg_compare_tag_enable, next_reg_compare_tag_enable;
reg [2:0] reg_reg_dout_oper, next_reg_dout_oper;


localparam s_reset = 8'h00, s_idle = 8'h01,
           s_key_0 = 8'h10, s_key_1 = 8'h11, s_key_2 = 8'h12,
           s_enc_dec_0 = 8'h20, s_enc_dec_1 = 8'h21, s_enc_dec_2 = 8'h22, s_enc_dec_3 = 8'h23, s_enc_dec_4 = 8'h24, s_enc_dec_5 = 8'h25, s_enc_dec_6 = 8'h26, s_enc_dec_7 = 8'h27, s_enc_dec_8 = 8'h28, s_enc_dec_9 = 8'h29, s_enc_dec_10 = 8'h2A, s_enc_dec_11 = 8'h2B, s_enc_dec_12 = 8'h2C, s_enc_dec_13 = 8'h2D,
           s_enc_14 = 8'h2E, s_enc_15 = 8'h2F,
           s_dec_13 = 8'h3D, s_dec_14 = 8'h3E, s_dec_15 = 8'h3F,
           s_hash_0 = 8'h40, s_hash_1 = 8'h41, s_hash_2 = 8'h42, s_hash_3 = 8'h43, s_hash_4 = 8'h44, s_hash_5 = 8'h45, s_hash_6 = 8'h46, s_hash_7 = 8'h47, s_hash_8 = 8'h48, s_hash_9 = 8'h49, s_hash_10 = 8'h4A, s_hash_11 = 8'h4B
           ;
reg[7:0] actual_state, next_state;

generate
    if (ASYNC_RSTN != 0) begin : use_asynchrnous_reset_zero_enable
        always @(posedge clk or negedge arstn) begin
            if (arstn == 1'b0) begin
                actual_state <= s_reset;
                reg_reg_buffer_rst <= 1'b1;
                reg_reg_buffer_oper <= 2'b00;
                reg_reg_buffer_din_oper <= 1'b0;
                reg_reg_ctr_data_oper <= 3'b000;
                reg_inst_ready <= 1'b0;
                reg_p_core_init <= 1'b1;
                reg_sm_p_core_oper <= 2'b00;
                reg_p_core_din_oper <= 3'b000;
                reg_reg_compare_tag_rst <= 1'b0;
                reg_reg_compare_tag_enable <= 1'b0;
                reg_reg_dout_oper <= 3'b000;
            end else begin
                actual_state <= next_state;
                reg_reg_buffer_rst <= next_reg_buffer_rst;
                reg_reg_buffer_oper <= next_reg_buffer_oper;
                reg_reg_buffer_din_oper <= next_reg_buffer_din_oper;
                reg_reg_ctr_data_oper <= next_reg_ctr_data_oper;
                reg_inst_ready <= next_inst_ready;
                reg_p_core_init <= next_p_core_init;
                reg_sm_p_core_oper <= next_sm_p_core_oper;
                reg_p_core_din_oper <= next_p_core_din_oper;
                reg_reg_compare_tag_rst <= next_reg_compare_tag_rst;
                reg_reg_compare_tag_enable <= next_reg_compare_tag_enable;
                reg_reg_dout_oper <= next_reg_dout_oper;
            end
        end
    end else begin : use_synchrnous_reset
        always @(posedge clk) begin
            if (arstn == 1'b1) begin
                actual_state <= s_reset;
                reg_reg_buffer_rst <= 1'b1;
                reg_reg_buffer_oper <= 2'b00;
                reg_reg_buffer_din_oper <= 1'b0;
                reg_reg_ctr_data_oper <= 3'b000;
                reg_inst_ready <= 1'b0;
                reg_p_core_init <= 1'b1;
                reg_sm_p_core_oper <= 2'b00;
                reg_p_core_din_oper <= 3'b000;
                reg_reg_compare_tag_rst <= 1'b0;
                reg_reg_compare_tag_enable <= 1'b0;
                reg_reg_dout_oper <= 3'b000;
            end else begin
                actual_state <= next_state;
                reg_reg_buffer_rst <= next_reg_buffer_rst;
                reg_reg_buffer_oper <= next_reg_buffer_oper;
                reg_reg_buffer_din_oper <= next_reg_buffer_din_oper;
                reg_reg_ctr_data_oper <= next_reg_ctr_data_oper;
                reg_inst_ready <= next_inst_ready;
                reg_p_core_init <= next_p_core_init;
                reg_sm_p_core_oper <= next_sm_p_core_oper;
                reg_p_core_din_oper <= next_p_core_din_oper;
                reg_reg_compare_tag_rst <= next_reg_compare_tag_rst;
                reg_reg_compare_tag_enable <= next_reg_compare_tag_enable;
                reg_reg_dout_oper <= next_reg_dout_oper;
            end
        end
    end
endgenerate


always @(*) begin
    next_reg_buffer_rst = 1'b0;
    next_reg_buffer_oper = 2'b00;
    next_reg_buffer_din_oper = 1'b0;
    next_reg_ctr_data_oper = 3'b000;
    next_inst_ready = 1'b0;
    next_p_core_init = 1'b0;
    next_sm_p_core_oper = 2'b00;
    next_p_core_din_oper = 3'b000;
    next_reg_compare_tag_rst = 1'b0;
    next_reg_compare_tag_enable = 1'b0;
    next_reg_dout_oper = 3'b000;
    case(next_state)
        s_reset : begin
            next_reg_buffer_rst = 1'b1;
            next_p_core_init = 1'b1;
        end
        s_idle : begin
            next_inst_ready = 1'b1;
            next_reg_buffer_rst = 1'b1;
        end
        // Store din in buffer and initialize the state
        s_hash_0 : begin
            next_p_core_init = 1'b1;
            next_p_core_din_oper = 3'b011;
            next_reg_buffer_oper = 2'b10;
            next_reg_buffer_din_oper = 1'b1;
        end
        // Absorb 1 byte din buffer - Special case for the empty hash string.
        s_hash_1 : begin
            next_reg_buffer_oper = 2'b01;
            next_p_core_din_oper = 3'b010;
        end
        // Absorb 1 byte din buffer
        s_hash_2 : begin
            next_reg_buffer_oper = 2'b01;
            next_p_core_din_oper = 3'b010;
        end
        // Absorb null - (din buffer not empty)
        s_hash_3 : begin
            next_reg_buffer_oper = 2'b10;
            next_p_core_din_oper = 3'b001;
        end
        // Absorb null - (din buffer empty)
        s_hash_4 : begin
            next_reg_buffer_oper = 2'b10;
            next_reg_buffer_din_oper = 1'b1;
            next_p_core_din_oper = 3'b001;
        end
        // Store din in buffer
        s_hash_5 : begin
            next_reg_buffer_oper = 2'b10;
            next_reg_buffer_din_oper = 1'b1;
            next_p_core_din_oper = 3'b011;
        end
        // Absorb null last
        s_hash_6 : begin
            next_reg_buffer_oper = 2'b10;
            next_p_core_din_oper = 3'b001;
        end
        // Absorb second null last
        s_hash_7 : begin
            next_reg_buffer_oper = 2'b10;
            next_p_core_din_oper = 3'b001;
        end
        // Initialize the counter and perform 1 blank permutation
        s_hash_8 : begin
            next_reg_ctr_data_oper = 3'b001;
            next_p_core_din_oper = 3'b001;
        end
        // Perform all 6 blank permutations
        s_hash_9 : begin
            next_reg_ctr_data_oper = 3'b100;
            next_p_core_din_oper = 3'b001;
        end
        // Perform last blank permutation and initialize counter to generate hash
        s_hash_10 : begin
            next_reg_ctr_data_oper = 3'b010;
            next_p_core_din_oper = 3'b001;
        end
        // Perform all hash steps
        s_hash_11 : begin
            next_reg_ctr_data_oper = 3'b101;
            next_p_core_din_oper = 3'b001;
            next_sm_p_core_oper = 2'b01;
            next_reg_dout_oper = 3'b010;
        end
        // Stream key mode
        s_key_0 : begin
            next_reg_buffer_oper = 2'b11;
            next_reg_buffer_din_oper = 1'b1;
            next_p_core_din_oper = 3'b011;
        end
        // Last key processed
        s_key_1 : begin
            next_reg_buffer_rst = 1'b1;
            next_p_core_din_oper = 3'b011;
        end
        // Add null data
        s_key_2 : begin
            next_p_core_din_oper = 3'b001;
        end
        // Stream nonce
        s_enc_dec_0 : begin
            next_reg_buffer_oper = 2'b11;
            next_reg_buffer_din_oper = 1'b1;
            next_p_core_din_oper = 3'b011;
        end
        // Last nonce processed
        s_enc_dec_1 : begin
            next_reg_buffer_rst = 1'b1;
            next_p_core_din_oper = 3'b011;
        end
        // Add null data
        s_enc_dec_2 : begin
            next_p_core_din_oper = 3'b001;
        end
        // Initialize the counter and perform 1 blank permutation
        s_enc_dec_3 : begin
            next_reg_ctr_data_oper = 3'b001;
            next_p_core_din_oper = 3'b001;
        end
        // Perform all 6 blank permutations
        s_enc_dec_4 : begin
            next_reg_ctr_data_oper = 3'b100;
            next_p_core_din_oper = 3'b001;
        end
        // Perform last blank permutation
        s_enc_dec_5 : begin
            next_reg_buffer_rst = 1'b1;
            next_p_core_din_oper = 3'b001;
        end
        // Stream associated data mode
        s_enc_dec_6 : begin
            next_reg_buffer_oper = 2'b11;
            next_reg_buffer_din_oper = 1'b1;
            next_p_core_din_oper = 3'b011;
        end
        // Last associated data processed
        s_enc_dec_7 : begin
            next_reg_buffer_rst = 1'b1;
            next_p_core_din_oper = 3'b011;
        end
        // Add null data
        s_enc_dec_8 : begin
            next_p_core_din_oper = 3'b001;
        end
        // Stream plaintext/ciphertext mode
        s_enc_dec_9 : begin
            next_reg_buffer_oper = 2'b11;
            next_reg_buffer_din_oper = 1'b1;
            next_reg_dout_oper = 3'b001;
            next_p_core_din_oper = 3'b011;
            next_sm_p_core_oper = 2'b10;
        end
        // Last plaintext/ciphertext processed
        s_enc_dec_10 : begin
            next_reg_buffer_oper = 2'b11;
            next_reg_dout_oper = 3'b001;
            next_p_core_din_oper = 3'b011;
            next_sm_p_core_oper = 2'b10;
        end
        // Add null data
        s_enc_dec_11 : begin
            next_p_core_din_oper = 3'b001;
            next_reg_dout_oper = 3'b001;
        end
        // Initialize the counter and perform 1 blank permutation
        s_enc_dec_12 : begin
            next_reg_ctr_data_oper = 3'b001;
            next_p_core_din_oper = 3'b001;
            next_reg_dout_oper = 3'b001;
        end
        // Perform all 6 blank permutations
        s_enc_dec_13 : begin
            next_reg_ctr_data_oper = 3'b100;
            next_p_core_din_oper = 3'b001;
        end
        // Perform last blank permutation and prepare counter for tag
        s_enc_14 : begin
            next_p_core_din_oper = 3'b001;
            next_reg_buffer_rst = 1'b1;
            next_reg_ctr_data_oper = 3'b011;
        end
        // Send all tag blocks
        s_enc_15 : begin
            next_reg_ctr_data_oper = 3'b101;
            next_p_core_din_oper = 3'b001;
            next_sm_p_core_oper = 2'b01;
            next_reg_dout_oper = 3'b010;
        end
        // Perform last blank permutation and prepare to receive the tag
        s_dec_13 : begin
            next_p_core_din_oper = 3'b001;
            next_reg_buffer_rst = 1'b1;
            next_reg_compare_tag_rst = 1'b1;
        end
        // Receive tag
        s_dec_14 : begin
            next_reg_buffer_oper = 2'b11;
            next_reg_buffer_din_oper = 1'b1;
            next_p_core_din_oper = 3'b100;
            next_reg_compare_tag_enable = 1'b1;
            next_sm_p_core_oper = 2'b01;
            next_reg_dout_oper = 3'b100;
        end
        // Send tag status
        s_dec_15 : begin
            next_p_core_din_oper = 3'b011;
            next_reg_dout_oper = 3'b011;
        end
        default : begin
            ;
        end
    endcase
end

always @(*) begin
    case(actual_state)
        s_reset : begin
            next_state = s_idle;
        end
        s_idle : begin
            if(inst_valid_and_ready == 1'b1) begin
                case(inst)
                    4'b0010, 4'b0011: begin
                        next_state = s_enc_dec_0;
                    end
                    4'b0100, 4'b0111: begin
                        next_state = s_key_0;
                    end
                    4'b1000: begin
                        next_state = s_hash_0;
                    end
                    default : begin
                        next_state = s_reset;
                    end
                endcase
            end else begin
                next_state = s_idle;
            end
        end
        // Store din in buffer and initialize state
        s_hash_0 : begin
            if(int_din_valid_and_ready == 1'b1) begin
                next_state = s_hash_1;
            end else begin
                next_state = s_hash_0;
            end
        end
        // Absorb 1 byte din buffer (First case to differ empty hash strings)
        s_hash_1 : begin
            if((is_reg_buffer_size_equal_zero == 1'b1) && (reg_buffer_last == 1'b1)) begin
                next_state = s_hash_6;
            end else if((is_reg_buffer_size_equal_one == 1'b1) && (reg_buffer_last == 1'b0)) begin 
                next_state = s_hash_4;
            end else begin
                next_state = s_hash_3;
            end
        end
        // Absorb 1 byte din buffer
        s_hash_2 : begin
            if((is_reg_buffer_size_equal_zero == 1'b1) && (reg_buffer_last == 1'b1)) begin
                next_state = s_hash_7;
            end else if((is_reg_buffer_size_equal_one == 1'b1) && (reg_buffer_last == 1'b0)) begin 
                next_state = s_hash_4;
            end else begin
                next_state = s_hash_3;
            end
        end
        // Absorb null - (din buffer not empty)
        s_hash_3 : begin
            if((is_reg_buffer_size_equal_zero == 1'b1) && (reg_buffer_last == 1'b1)) begin
                next_state = s_hash_6;
            end else if((is_reg_buffer_size_equal_zero == 1'b1)) begin
                next_state = s_hash_5;
            end else begin
                next_state = s_hash_2;
            end
        end
        // Absorb null - (din buffer empty)
        s_hash_4 : begin
            if(int_din_valid_and_ready == 1'b1) begin
                next_state = s_hash_2;
            end else begin
                next_state = s_hash_5;
            end
        end
        // Store din in buffer
        s_hash_5 : begin
            if(int_din_valid_and_ready == 1'b1) begin
                next_state = s_hash_2;
            end else begin
                next_state = s_hash_5;
            end
        end
        // Absorb null last
        s_hash_6 : begin
            next_state = s_hash_7;
        end
        // Absorb null last
        s_hash_7 : begin
            next_state = s_hash_8;
        end
        // Initialize the counter and perform 1 blank permutation
        s_hash_8 : begin
            next_state = s_hash_9;
        end
        // Perform all 6 blank permutations
        s_hash_9 : begin
            if(is_reg_ctr_data_equal_one == 1'b1) begin
                next_state = s_hash_10;
            end else begin
                next_state = s_hash_9;
            end
        end
        // Perform last blank permutation and initialize counter to generate hash
        s_hash_10 : begin
            next_state = s_hash_11;
        end
        // Send all hash blocks
        s_hash_11 : begin
            if((is_reg_ctr_data_equal_one == 1'b1) && (dout_valid_and_ready == 1'b1)) begin
                next_state = s_reset;
            end else begin
                next_state = s_hash_11;
            end
        end
        // Stream key mode
        s_key_0 : begin
            if((din_last == 1'b1) && (int_din_valid_and_ready == 1'b1)) begin
                next_state = s_key_1;
            end else begin
                next_state = s_key_0;
            end
        end
        // Last key processed
        s_key_1 : begin
            if((is_reg_buffer_size_equal_four == 1'b1) || (is_reg_buffer_size_equal_zero == 1'b1)) begin
                next_state = s_key_2;
            end else begin
                next_state = s_idle;
            end
        end
        // Add null data
        s_key_2 : begin
            next_state = s_idle;
        end
        // Stream nonce mode
        s_enc_dec_0 : begin
            if((din_last == 1'b1) && (int_din_valid_and_ready == 1'b1)) begin
                next_state = s_enc_dec_1;
            end else begin
                next_state = s_enc_dec_0;
            end
        end
        // Last nonce processed
        s_enc_dec_1 : begin
            if((is_reg_buffer_size_equal_four == 1'b1) || (is_reg_buffer_size_equal_zero == 1'b1)) begin
                next_state = s_enc_dec_2;
            end else begin
                next_state = s_enc_dec_3;
            end
        end
        // Add null data
        s_enc_dec_2 : begin
            next_state = s_enc_dec_3;
        end
        // Initialize the counter and perform 1 blank permutation
        s_enc_dec_3 : begin
            next_state = s_enc_dec_4;
        end
        // Perform all 6 blank permutations
        s_enc_dec_4 : begin
            if(is_reg_ctr_data_equal_one == 1'b1) begin
                next_state = s_enc_dec_5;
            end else begin
                next_state = s_enc_dec_4;
            end
        end
        // Perform last blank permutation
        s_enc_dec_5 : begin
            next_state = s_enc_dec_6;
        end
        // Stream associated data mode
        s_enc_dec_6 : begin
            if((din_last == 1'b1) && (int_din_valid_and_ready == 1'b1)) begin
                next_state = s_enc_dec_7;
            end else begin
                next_state = s_enc_dec_6;
            end
        end
        // Last associated data processed
        s_enc_dec_7 : begin
            if((is_reg_buffer_size_equal_four == 1'b1) || (is_reg_buffer_size_equal_zero == 1'b1)) begin
                next_state = s_enc_dec_8;
            end else begin
                next_state = s_enc_dec_9;
            end
        end
        // Add null data
        s_enc_dec_8 : begin
            next_state = s_enc_dec_9;
        end
        // Stream plaintext/ciphertext mode
        s_enc_dec_9 : begin
            if((din_last == 1'b1) && (int_din_valid_and_ready == 1'b1)) begin
                next_state = s_enc_dec_10;
            end else begin
                next_state = s_enc_dec_9;
            end
        end
        // Last plaintext/ciphertext processed
        s_enc_dec_10 : begin
            if((is_reg_buffer_size_equal_four == 1'b1) || (is_reg_buffer_size_equal_zero == 1'b1)) begin
                next_state = s_enc_dec_11;
            end else begin
                next_state = s_enc_dec_12;
            end
        end
        // Add null data
        s_enc_dec_11 : begin
            next_state = s_enc_dec_12;
        end
        // Initialize the counter and perform 1 blank permutation
        s_enc_dec_12 : begin
            next_state = s_enc_dec_13;
        end
        // Perform all 6 blank permutations
        s_enc_dec_13 : begin
            if(is_reg_ctr_data_equal_one == 1'b1) begin
                if(reg_inst == 4'b0010) begin
                    next_state = s_enc_14;
                end else begin
                    next_state = s_dec_13;
                end
            end else begin
                next_state = s_enc_dec_13;
            end
        end
        // Perform last blank permutation
        s_enc_14 : begin
            next_state = s_enc_15;
        end
        // Send all tag blocks
        s_enc_15 : begin
            if((is_reg_ctr_data_equal_one == 1'b1) && (dout_valid_and_ready == 1'b1)) begin
                next_state = s_reset;
            end else begin
                next_state = s_enc_15;
            end
        end
        // Perform last blank permutation and prepare to receive the tag
        s_dec_13 : begin
            next_state = s_dec_14;
        end
        // Receive tag
        s_dec_14 : begin
            if((din_last == 1'b1) && (int_din_valid_and_ready == 1'b1)) begin
                next_state = s_dec_15;
            end else begin
                next_state = s_dec_14;
            end
        end
        // Send tag status
        s_dec_15 : begin
            next_state = s_reset;
        end
        default : begin
            next_state = s_reset;
        end
    endcase
end

assign reg_buffer_rst = reg_reg_buffer_rst;
assign reg_buffer_oper = reg_reg_buffer_oper;
assign reg_buffer_din_oper = reg_reg_buffer_din_oper;
assign reg_ctr_data_oper = reg_reg_ctr_data_oper;
assign inst_ready = reg_inst_ready;
assign p_core_init = reg_p_core_init;
assign sm_p_core_oper = reg_sm_p_core_oper;
assign p_core_din_oper = reg_p_core_din_oper;
assign reg_compare_tag_rst = reg_reg_compare_tag_rst;
assign reg_compare_tag_enable = reg_reg_compare_tag_enable;
assign reg_dout_oper = reg_reg_dout_oper;

endmodule