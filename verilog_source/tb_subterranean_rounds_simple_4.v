/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module tb_subterranean_rounds_simple_4
#(parameter PERIOD = 1000,
maximum_line_length = 10000,
MAXIMUM_BUFFER_SIZE = 8192,
skip_hash_test = 0, // 1 - True, 0 - False
skip_aead_test = 0, // 1 - True, 0 - False
test_memory_file_subterranean_hash = "../data_tests/LWC_HASH_KAT_256.txt",
test_memory_file_subterranean_aead = "../data_tests/LWC_AEAD_KAT_128_128.txt",
sim_enable_dump = 0 // 1 - True, 0 - False
);

reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_key_enc;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_nonce_enc;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_pt_enc;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_ad_enc;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_output_ct_enc;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_output_tag_enc;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] true_output_ct_enc;

reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_key_dec;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_nonce_dec;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_ct_dec;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_input_ad_dec;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_output_pt_dec;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] test_output_tag_dec;
reg [(MAXIMUM_BUFFER_SIZE - 1):0] true_output_pt_dec;

reg test_arstn;
reg test_init;
reg test_encrypt;
reg test_decrypt;
reg [1:0] test_enable_round;
reg [127:0] test_din;
reg [11:0] test_din_size;
reg test_din_valid;
wire test_din_ready;
wire [127:0] test_dout;
wire test_dout_valid;
reg test_dout_ready;
wire test_free;
wire test_finish;

reg clk;
reg test_error = 1'b0;
reg test_verification = 1'b0;

localparam tb_delay = PERIOD/2;
localparam tb_delay_read = 3*PERIOD/4;

subterranean_rounds_simple_4
test
(
    .clk(clk),
    .arstn(test_arstn),
    .init(test_init),
    .encrypt(test_encrypt),
    .decrypt(test_decrypt),
    .enable_round(test_enable_round),
    .din(test_din),
    .din_size(test_din_size),
    .din_valid(test_din_valid),
    .din_ready(test_din_ready),
    .dout(test_dout),
    .dout_valid(test_dout_valid),
    .dout_ready(test_dout_ready),
    .free(test_free),
    .finish(test_finish)
);


initial begin : clock_generator
    clk <= 1'b1;
    forever begin
        #(PERIOD/2);
        clk <= ~clk;
    end
end

task test_init_state;
    begin
        test_init <= 1'b1;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_encrypt <= 1'b0;
        test_decrypt <= 1'b0;
        test_enable_round <= 2'b00;
        test_din <= 128'b0;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        #PERIOD;
        test_init <= 1'b0;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_encrypt <= 1'b0;
        test_decrypt <= 1'b0;
        test_enable_round <= 2'b00;
        test_din <= 128'b0;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        #PERIOD;
    end
endtask

task test_absorb_unkeyed;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    integer iterator_buffer;
    integer last_block;
    begin
        test_init <= 1'b0;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_din <= 128'b0;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        test_encrypt <= 1'b0;
        test_decrypt <= 1'b0;
        test_enable_round <= 2'b00;
        #PERIOD;
        iterator_buffer = 0;
        if(buffer_size >= 2) begin
            while(iterator_buffer <= 8*(buffer_size - 2)) begin
                test_din[31:0]   <= {24'b0, buffer_in[iterator_buffer +: 8]};
                test_din[63:32]  <= 32'b0;
                test_din[95:64]  <= {24'b0, buffer_in[(iterator_buffer + 8) +: 8]};
                test_din[127:96] <= 32'b0;
                test_din_size <= {3'b000, 3'b001, 3'b000, 3'b001};
                test_enable_round <= 2'b11;
                #(PERIOD);
                test_din_valid <= 1'b1;
                test_dout_ready <= 1'b1;
                #(PERIOD);
                test_din_valid <= 1'b0;
                test_dout_ready <= 1'b0;
                while(test_free != 1'b1) begin
                    #(PERIOD);
                end
                iterator_buffer = iterator_buffer + 16;
            end
        end
        last_block = 8*buffer_size - iterator_buffer;
        if(last_block == 0) begin
            test_din[31:0]   <= 32'b0;
            test_din[63:32]  <= 32'b0;
            test_din[95:64]  <= 32'b0;
            test_din[127:96] <= 32'b0;
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
            test_enable_round <= 2'b01;
            #(PERIOD);
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end else begin
            test_din[31:0]   <= {24'b0, buffer_in[iterator_buffer +: 8]};
            test_din[63:32]  <= 32'b0;
            test_din[95:64]  <= 32'b0;
            test_din[127:96] <= 32'b0;
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b001};
            test_enable_round <= 2'b11;
            #(PERIOD);
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            test_enable_round <= 2'b00;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end
        #(PERIOD);
    end
endtask

task test_absorb_keyed;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    integer iterator_buffer;
    integer iterator_din;
    integer last_block;
    begin
        test_init <= 1'b0;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_encrypt <= 1'b0;
        test_decrypt <= 1'b0;
        test_enable_round <= 2'b00;
        test_din <= 128'b0;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        #PERIOD;
        iterator_buffer = 0;
        if(buffer_size >= 16) begin
            while(iterator_buffer <= 8*(buffer_size - 16)) begin
                test_din[31:0]   <= buffer_in[iterator_buffer +: 32];
                test_din[63:32]  <= buffer_in[(iterator_buffer + 32) +: 32];
                test_din[95:64]  <= buffer_in[(iterator_buffer + 64) +: 32];
                test_din[127:96] <= buffer_in[(iterator_buffer + 96) +: 32];
                test_din_size <= {3'b100, 3'b100, 3'b100, 3'b100};
                test_enable_round <= 2'b11;
                #(PERIOD);
                test_din_valid <= 1'b1;
                test_dout_ready <= 1'b1;
                #(PERIOD);
                test_din_valid <= 1'b0;
                test_dout_ready <= 1'b0;
                while(test_free != 1'b1) begin
                    #(PERIOD);
                end
                iterator_buffer = iterator_buffer + 128;
            end
        end
        last_block = 8*buffer_size - iterator_buffer;
        if(last_block == 0) begin
            test_din[31:0]   <= 32'b0;
            test_din[63:32]  <= 32'b0;
            test_din[95:64]  <= 32'b0;
            test_din[127:96] <= 32'b0;
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
            test_enable_round <= 2'b00;
            #(PERIOD);
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end else begin
            iterator_din = 0;
            while((iterator_buffer < 8*buffer_size)) begin
                test_din[iterator_din +: 8] <= buffer_in[iterator_buffer +: 8];
                iterator_din = iterator_din + 8;
                iterator_buffer = iterator_buffer + 8;
            end
            while((iterator_din < 128)) begin
                test_din[iterator_din +: 8] <= 8'b0;
                iterator_din = iterator_din + 8;
            end
            if(last_block >= 96) begin
                test_enable_round <= 2'b11;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= 3'b100;
                test_din_size[8:6]  <= 3'b100;
                test_din_size[11:9] <= (last_block/8-12);
            end else if(last_block >= 64) begin
                test_enable_round <= 2'b10;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= 3'b100;
                test_din_size[8:6]  <= (last_block/8-8);
                test_din_size[11:9] <= 3'b000;
            end else if(last_block >= 32) begin
                test_enable_round <= 2'b01;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= (last_block/8-4);
                test_din_size[8:6]  <= 3'b000;
                test_din_size[11:9] <= 3'b000;
            end else begin
                test_enable_round <= 2'b00;
                test_din_size[2:0]  <= last_block/8;
                test_din_size[5:3]  <= 3'b000;
                test_din_size[8:6]  <= 3'b000;
                test_din_size[11:9] <= 3'b000;
            end
            #(PERIOD);
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            test_enable_round <= 2'b00;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end
    end
endtask

task test_absorb_encrypt;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    output [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_out;
    integer iterator_buffer_in;
    integer iterator_buffer_out;
    integer iterator_din;
    integer iterator_dout;
    integer last_block;
    begin
        test_init <= 1'b0;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_encrypt <= 1'b1;
        test_decrypt <= 1'b0;
        test_enable_round <= 2'b00;
        test_din <= 128'b0;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        buffer_out <= {MAXIMUM_BUFFER_SIZE{1'b0}};
        #PERIOD;
        iterator_buffer_in = 0;
        iterator_buffer_out = 0;
        if(buffer_size >= 16) begin
            while(iterator_buffer_in <= 8*(buffer_size - 16)) begin
                test_din[31:0]   <= buffer_in[iterator_buffer_in +: 32];
                test_din[63:32]  <= buffer_in[(iterator_buffer_in + 32) +: 32];
                test_din[95:64]  <= buffer_in[(iterator_buffer_in + 64) +: 32];
                test_din[127:96] <= buffer_in[(iterator_buffer_in + 96) +: 32];
                test_din_size <= {3'b100, 3'b100, 3'b100, 3'b100};
                test_enable_round <= 2'b11;
                #(PERIOD);
                buffer_out[iterator_buffer_out +: 128] <= test_dout;
                #(PERIOD);
                test_din_valid <= 1'b1;
                test_dout_ready <= 1'b1;
                #(PERIOD);
                test_din_valid <= 1'b0;
                test_dout_ready <= 1'b0;
                while(test_free != 1'b1) begin
                    #(PERIOD);
                end
                iterator_buffer_in = iterator_buffer_in + 128;
                iterator_buffer_out = iterator_buffer_out + 128;
            end
        end
        last_block = 8*buffer_size - iterator_buffer_in;
        if(last_block == 0) begin
            test_din[31:0]   <= 32'b0;
            test_din[63:32]  <= 32'b0;
            test_din[95:64]  <= 32'b0;
            test_din[127:96] <= 32'b0;
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
            test_enable_round <= 2'b00;
            #(PERIOD);
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end else begin
            iterator_din = 0;
            while((iterator_buffer_in < 8*buffer_size)) begin
                test_din[iterator_din +: 8] <= buffer_in[iterator_buffer_in +: 8];
                iterator_din = iterator_din + 8;
                iterator_buffer_in = iterator_buffer_in + 8;
            end
            while(iterator_din < 128) begin
                test_din[iterator_din +: 8] <= 8'b0;
                iterator_din = iterator_din + 8;
            end
            if(last_block >= 96) begin
                test_enable_round <= 2'b11;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= 3'b100;
                test_din_size[8:6]  <= 3'b100;
                test_din_size[11:9] <= (last_block/8-12);
            end else if(last_block >= 64) begin
                test_enable_round <= 2'b10;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= 3'b100;
                test_din_size[8:6]  <= (last_block/8-8);
                test_din_size[11:9] <= 3'b000;
            end else if(last_block >= 32) begin
                test_enable_round <= 2'b01;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= (last_block/8-4);
                test_din_size[8:6]  <= 3'b000;
                test_din_size[11:9] <= 3'b000;
            end else begin
                test_enable_round <= 2'b00;
                test_din_size[2:0]  <= last_block/8;
                test_din_size[5:3]  <= 3'b000;
                test_din_size[8:6]  <= 3'b000;
                test_din_size[11:9] <= 3'b000;
            end
            #(PERIOD);
            iterator_dout = 0;
            while(iterator_buffer_out < 8*buffer_size) begin
                buffer_out[iterator_buffer_out +:8] <= test_dout[iterator_dout +: 8];
                iterator_dout = iterator_dout + 8;
                iterator_buffer_out = iterator_buffer_out + 8;
            end
            #(PERIOD)
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            test_enable_round <= 2'b00;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end
        test_encrypt <= 1'b0;
        #(PERIOD);
    end
endtask

task test_absorb_decrypt;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    output [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_out;
    integer iterator_buffer_in;
    integer iterator_buffer_out;
    integer iterator_din;
    integer iterator_dout;
    integer last_block;
    begin
        test_init <= 1'b0;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_encrypt <= 1'b0;
        test_decrypt <= 1'b1;
        test_din <= 128'b0;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        test_enable_round <= 2'b00;
        buffer_out <= {MAXIMUM_BUFFER_SIZE{1'b0}};
        #PERIOD;
        iterator_buffer_in = 0;
        iterator_buffer_out = 0;
        if(buffer_size >= 16) begin
            while(iterator_buffer_in <= 8*(buffer_size - 16)) begin
                test_din[31:0]   <= buffer_in[iterator_buffer_in +: 32];
                test_din[63:32]  <= buffer_in[(iterator_buffer_in + 32) +: 32];
                test_din[95:64]  <= buffer_in[(iterator_buffer_in + 64) +: 32];
                test_din[127:96] <= buffer_in[(iterator_buffer_in + 96) +: 32];
                test_din_size <= {3'b100, 3'b100, 3'b100, 3'b100};
                test_enable_round <= 2'b11;
                #(PERIOD);
                buffer_out[iterator_buffer_out +: 128] <= test_dout;
                #(PERIOD);
                test_din_valid <= 1'b1;
                test_dout_ready <= 1'b1;
                #(PERIOD);
                test_din_valid <= 1'b0;
                test_dout_ready <= 1'b0;
                while(test_free != 1'b1) begin
                    #(PERIOD);
                end
                iterator_buffer_in = iterator_buffer_in + 128;
                iterator_buffer_out = iterator_buffer_out + 128;
            end
        end
        last_block = 8*buffer_size - iterator_buffer_in;
        if(last_block == 0) begin
            test_din[31:0]   <= 32'b0;
            test_din[63:32]  <= 32'b0;
            test_din[95:64]  <= 32'b0;
            test_din[127:96] <= 32'b0;
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
            test_enable_round <= 2'b00;
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end else begin
            iterator_din = 0;
            while(iterator_buffer_in < 8*buffer_size) begin
                test_din[iterator_din +: 8] <= buffer_in[iterator_buffer_in +: 8];
                iterator_buffer_in = iterator_buffer_in + 8;
                iterator_din = iterator_din + 8;
            end
            while(iterator_din < 128) begin
                test_din[iterator_din +: 8] <= 8'b0;
                iterator_din = iterator_din + 8;
            end
            if(last_block >= 96) begin
                test_enable_round <= 2'b11;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= 3'b100;
                test_din_size[8:6]  <= 3'b100;
                test_din_size[11:9] <= (last_block/8-12);
            end else if(last_block >= 64) begin
                test_enable_round <= 2'b10;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= 3'b100;
                test_din_size[8:6]  <= (last_block/8-8);
                test_din_size[11:9] <= 3'b000;
            end else if(last_block >= 32) begin
                test_enable_round <= 2'b01;
                test_din_size[2:0]  <= 3'b100;
                test_din_size[5:3]  <= (last_block/8-4);
                test_din_size[8:6]  <= 3'b000;
                test_din_size[11:9] <= 3'b000;
            end else begin
                test_enable_round <= 2'b00;
                test_din_size[2:0]  <= last_block/8;
                test_din_size[5:3]  <= 3'b000;
                test_din_size[8:6]  <= 3'b000;
                test_din_size[11:9] <= 3'b000;
            end
            #(PERIOD);
            iterator_dout = 0;
            while(iterator_buffer_out < 8*buffer_size) begin
                buffer_out[iterator_buffer_out +:8] <= test_dout[iterator_dout +: 8];
                iterator_dout = iterator_dout + 8;
                iterator_buffer_out = iterator_buffer_out + 8;
            end
            #(PERIOD);
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end
        test_decrypt <= 1'b0;
        #(PERIOD);
    end
endtask

task test_squeeze;
    input integer buffer_size;
    output [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_out;
    integer iterator_buffer;
    integer iterator_dout;
    integer last_block;
    begin
        test_init <= 1'b0;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_encrypt <= 1'b0;
        test_decrypt <= 1'b0;
        test_din <= 128'b0;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        test_enable_round <= 2'b00;
        buffer_out <= {MAXIMUM_BUFFER_SIZE{1'b0}};
        #PERIOD;
        iterator_buffer = 0;
        if(buffer_size >= 16) begin
            test_din <= {32'b0,32'b0,32'b0,32'b0};
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
            test_enable_round <= 2'b11;
            #PERIOD;
            while(iterator_buffer <= 8*(buffer_size - 16)) begin
                buffer_out[iterator_buffer +: 128] <= test_dout;
                #(PERIOD);
                test_din_valid <= 1'b1; test_dout_ready <= 1'b1;
                #(PERIOD);
                test_din_valid <= 1'b0; test_dout_ready <= 1'b0;
                while(test_free != 1'b1) begin
                    #(PERIOD);
                end
                iterator_buffer = iterator_buffer + 128;
            end
        end
        #(PERIOD);
        last_block = 8*buffer_size - iterator_buffer;
        if(last_block != 0) begin
            iterator_dout = 0;
            test_din <= {32'b0,32'b0,32'b0,32'b0};
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
            test_enable_round <= 2'b11;
            #PERIOD;
            while(iterator_dout < last_block) begin
                buffer_out[iterator_buffer +: 8] <= test_dout[iterator_dout +: 8];
                iterator_buffer = iterator_buffer + 8;
                iterator_dout = iterator_dout + 8;
            end
            if(last_block > 96) begin
                test_enable_round <= 2'b11;
            end else if(last_block > 64) begin
                test_enable_round <= 2'b10;
            end else if(last_block > 32) begin
                test_enable_round <= 2'b01;
            end else begin
                test_enable_round <= 2'b00;
            end
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            test_enable_round <= 2'b00;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
        end
    end
endtask

task test_blank;
    integer temp_i;
    begin
        test_init <= 1'b0;
        test_din_valid <= 1'b0;
        test_dout_ready <= 1'b0;
        test_encrypt <= 1'b0;
        test_decrypt <= 1'b0;
        test_enable_round <= 1'b0;
        test_din <= 128'b00;
        test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
        #PERIOD;
        temp_i = 0;
        while(temp_i < 2) begin
            test_din <= {32'b0, 32'b0, 32'b0, 32'b0};
            test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
            test_enable_round <= 2'b11;
            test_din_valid <= 1'b1;
            test_dout_ready <= 1'b1;
            #(PERIOD);
            test_din_valid <= 1'b0;
            test_dout_ready <= 1'b0;
            while(test_free != 1'b1) begin
                #(PERIOD);
            end
            temp_i = temp_i + 1;
        end
        #(PERIOD);
    end
endtask

task read_until_get_character;
    input integer file_read;
    input integer character_to_be_found;
    integer temp_text;
    begin
        temp_text = $fgetc(file_read);
        while((temp_text != character_to_be_found) && (!$feof(file_read))) begin
            temp_text = $fgetc(file_read);
        end
    end
endtask

task read_ignore_character;
    input integer file_read;
    input integer character_to_be_ignored;
    output integer last_character;
    integer temp_text;
    begin
        temp_text = $fgetc(file_read);
        while((temp_text == character_to_be_ignored) && (!$feof(file_read))) begin
            temp_text = $fgetc(file_read);
        end
        last_character = temp_text;
    end
endtask

task decode_hex_character;
    input integer a;
    output [3:0] value;
    begin
        if((a >= "0") && (a <= "9")) begin
            value = a - "0";
        end else if((a >= "A") && (a <= "F")) begin
            value = a - "A" + 4'd10;
        end else if((a >= "a") && (a <= "f")) begin
            value = a - "a" + 4'd10;
        end else begin
            value = 4'b0000;
        end
    end
endtask

integer aead_file;
integer hash_file;
integer temp_text1;
integer count;
integer key_size;
integer nonce_size;
integer pt_size;
integer ad_size;
integer ct_size;
integer tag_size;
integer status_ram_file;
integer test_iterator;
initial begin
    test_arstn <= 1'b0;
    test_init <= 1'b0;
    test_din_valid <= 1'b0;
    test_dout_ready <= 1'b0;
    test_encrypt <= 1'b0;
    test_decrypt <= 1'b0;
    test_enable_round <= 1'b0;
    test_din <= 128'b0;
    test_din_size <= {3'b000, 3'b000, 3'b000, 3'b000};
    test_error <= 1'b0;
    test_verification <= 1'b0;
    test_input_key_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_input_nonce_enc <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_input_pt_enc    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_input_ad_enc    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_output_ct_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_output_tag_enc  <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    true_output_ct_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_input_key_dec   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_input_nonce_dec <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_input_ct_dec    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_input_ad_dec    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_output_tag_dec  <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    test_output_pt_dec   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    true_output_pt_dec   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
    tag_size <= 16;
    #(PERIOD*2);
    test_arstn <= 1'b1;
    #(PERIOD);
    #(tb_delay);
    if(skip_hash_test == 0) begin
        $display("Start of the hash test");
        hash_file = $fopen(test_memory_file_subterranean_hash, "r");
        while(!$feof(hash_file)) begin
            read_until_get_character(hash_file, "=");
            status_ram_file = $fscanf(hash_file, "%d", count);
            $display("Test number : %d", count);
            #(PERIOD);
            test_error <= 1'b0;
            test_verification <= 1'b0;
            test_input_pt_enc    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_output_ct_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            true_output_ct_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            #(PERIOD);
            // Read Message
            read_until_get_character(hash_file, "=");
            read_ignore_character(hash_file, " ", temp_text1);
            pt_size = 0;
            while(temp_text1 != "\n") begin
                decode_hex_character(temp_text1, test_input_pt_enc[7:4]);
                temp_text1 = $fgetc(hash_file);
                if(temp_text1 != "\n") begin
                    decode_hex_character(temp_text1, test_input_pt_enc[3:0]);
                    temp_text1 = $fgetc(hash_file);
                end
                test_input_pt_enc = {test_input_pt_enc[7:0], test_input_pt_enc[(MAXIMUM_BUFFER_SIZE-1):8]};
                pt_size = pt_size + 1;
            end
            test_iterator = 0;
            if(pt_size > 0) begin
                test_iterator = MAXIMUM_BUFFER_SIZE;
                while (test_iterator > pt_size) begin
                    test_input_pt_enc = {test_input_pt_enc[7:0], test_input_pt_enc[(MAXIMUM_BUFFER_SIZE-1):8]};
                    test_iterator = test_iterator - 1;
                end
            end
            // Read MD
            read_until_get_character(hash_file, "=");
            read_ignore_character(hash_file, " ", temp_text1);
            while(temp_text1 != "\n") begin
                decode_hex_character(temp_text1, true_output_ct_enc[7:4]);
                temp_text1 = $fgetc(hash_file);
                if(temp_text1 != "\n") begin
                    decode_hex_character(temp_text1, true_output_ct_enc[3:0]);
                    temp_text1 = $fgetc(hash_file);
                end
                true_output_ct_enc[255:0] = {true_output_ct_enc[7:0], true_output_ct_enc[255:8]};
            end
            while(test_free == 1'b0) begin
                #PERIOD;
            end
            // Start hash procedure
            test_init_state();
            #(PERIOD);
            // Absorb the message
            test_absorb_unkeyed(test_input_pt_enc, pt_size);
            #(PERIOD);
            // Perform Blank
            test_blank();
            // Squeeze MD
            test_squeeze(32, test_output_ct_enc);
            #(PERIOD);
            // Compare hash output
            test_verification <= 1'b1;
            if (true_output_ct_enc == test_output_ct_enc) begin
                test_error <= 1'b0;
            end else begin
                test_error <= 1'b1;
                $display("Computed values do not match expected ones");
            end
            #(PERIOD);
            test_error <= 1'b0;
            test_verification <= 1'b0;
            #(PERIOD);
            read_ignore_character(hash_file, "\n", temp_text1);
        end
        $fclose(hash_file);
        $display("End of the hash test");
    end
    if(skip_aead_test == 0) begin
        $display("Start of the aead test");
        aead_file = $fopen(test_memory_file_subterranean_aead, "r");
        while(!$feof(aead_file)) begin
            read_until_get_character(aead_file, "=");
            status_ram_file = $fscanf(aead_file, "%d", count);
            $display("Test number : %d", count);
            #(PERIOD);
            test_error <= 1'b0;
            test_verification <= 1'b0;
            test_input_key_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_input_nonce_enc <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_input_pt_enc    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_input_ad_enc    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_output_ct_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_output_tag_enc  <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            true_output_ct_enc   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_input_key_dec   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_input_nonce_dec <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_input_ct_dec    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_input_ad_dec    <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_output_tag_dec  <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            test_output_pt_dec   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            true_output_pt_dec   <= {MAXIMUM_BUFFER_SIZE{1'b0}};
            #(PERIOD);
            // Read key
            read_until_get_character(aead_file, "=");
            read_ignore_character(aead_file, " ", temp_text1);
            key_size = 0;
            while(temp_text1 != "\n") begin
                decode_hex_character(temp_text1, test_input_key_enc[7:4]);
                temp_text1 = $fgetc(aead_file);
                if(temp_text1 != "\n") begin
                    decode_hex_character(temp_text1, test_input_key_enc[3:0]);
                    temp_text1 = $fgetc(aead_file);
                end
                test_input_key_enc = {test_input_key_enc[7:0], test_input_key_enc[127:8]};
                key_size = key_size + 1;
            end
            // Read nonce
            read_until_get_character(aead_file, "=");
            read_ignore_character(aead_file, " ", temp_text1);
            nonce_size = 0;
            while(temp_text1 != "\n") begin
                decode_hex_character(temp_text1, test_input_nonce_enc[7:4]);
                temp_text1 = $fgetc(aead_file);
                if(temp_text1 != "\n") begin
                    decode_hex_character(temp_text1, test_input_nonce_enc[3:0]);
                    temp_text1 = $fgetc(aead_file);
                end
                test_input_nonce_enc = {test_input_nonce_enc[7:0], test_input_nonce_enc[127:8]};
                nonce_size = nonce_size + 1;
            end
            // Read PT
            read_until_get_character(aead_file, "=");
            read_ignore_character(aead_file, " ", temp_text1);
            pt_size = 0;
            while(temp_text1 != "\n") begin
                decode_hex_character(temp_text1, test_input_pt_enc[7:4]);
                temp_text1 = $fgetc(aead_file);
                if(temp_text1 != "\n") begin
                    decode_hex_character(temp_text1, test_input_pt_enc[3:0]);
                    temp_text1 = $fgetc(aead_file);
                end
                test_input_pt_enc = {test_input_pt_enc[7:0], test_input_pt_enc[255:8]};
                true_output_pt_dec = {test_input_pt_enc[255:248], true_output_pt_dec[383:8]};
                pt_size = pt_size + 1;
            end
            // If the length is variable the buffer has to be adjusted
            if(pt_size > 0) begin
                test_iterator = 32;
                while (test_iterator > pt_size) begin
                    test_input_pt_enc = {test_input_pt_enc[7:0], test_input_pt_enc[255:8]};
                    test_iterator = test_iterator - 1;
                end
            end
            // Read AD
            read_until_get_character(aead_file, "=");
            read_ignore_character(aead_file, " ", temp_text1);
            ad_size = 0;
            while(temp_text1 != "\n") begin
                decode_hex_character(temp_text1, test_input_ad_enc[7:4]);
                temp_text1 = $fgetc(aead_file);
                if(temp_text1 != "\n") begin
                    decode_hex_character(temp_text1, test_input_ad_enc[3:0]);
                    temp_text1 = $fgetc(aead_file);
                end
                test_input_ad_enc = {test_input_ad_enc[7:0], test_input_ad_enc[255:8]};
                ad_size = ad_size + 1;
            end
            // If the length is variable the buffer has to be adjusted
            if(ad_size > 0) begin
                test_iterator = 32;
                while (test_iterator > ad_size) begin
                    test_input_ad_enc = {test_input_ad_enc[7:0], test_input_ad_enc[255:8]};
                    test_iterator = test_iterator - 1;
                end
            end
            // Read CT
            read_until_get_character(aead_file, "=");
            read_ignore_character(aead_file, " ", temp_text1);
            ct_size = 0;
            while(temp_text1 != "\n") begin
                decode_hex_character(temp_text1, true_output_ct_enc[7:4]);
                temp_text1 = $fgetc(aead_file);
                if(temp_text1 != "\n") begin
                    decode_hex_character(temp_text1, true_output_ct_enc[3:0]);
                    temp_text1 = $fgetc(aead_file);
                end
                true_output_ct_enc = {true_output_ct_enc[7:0], true_output_ct_enc[383:8]};
                if(ct_size >= pt_size) begin
                    true_output_pt_dec = {true_output_ct_enc[383:376], true_output_pt_dec[383:8]};
                end
                ct_size = ct_size + 1;
            end
            // If the length is variable the buffer has to be adjusted
            if(ct_size > 0) begin
                test_iterator = 48;
                while (test_iterator > ct_size) begin
                    true_output_ct_enc = {true_output_ct_enc[7:0], true_output_ct_enc[383:8]};
                    true_output_pt_dec = {true_output_pt_dec[7:0], true_output_pt_dec[383:8]};
                    test_iterator = test_iterator - 1;
                end
            end
            test_input_key_dec = test_input_key_enc;
            test_input_nonce_dec = test_input_nonce_enc;
            test_input_ad_dec = test_input_ad_enc;
            test_input_ct_dec = true_output_ct_enc[255:0];
            while(test_free == 1'b0) begin
                #PERIOD;
            end
            // Start the encryption procedure
            // Initialize the state
            test_init_state();
            #(PERIOD);
            // Absorb the key
            test_absorb_keyed(test_input_key_enc, key_size);
            #(PERIOD);
            // Absorb the Nonce
            test_absorb_keyed(test_input_nonce_enc, nonce_size);
            #(PERIOD);
            // Perform Blank
            test_blank();
            #(PERIOD);
            // Absorb the AD
            test_absorb_keyed(test_input_ad_enc, ad_size);
            #(PERIOD);
            // Absorb the pt and encrypt
            test_absorb_encrypt(test_input_pt_enc, pt_size, test_output_ct_enc);
            #(PERIOD);
            // Perform Blank
            test_blank();
            #(PERIOD);
            // Squeeze Tag
            test_squeeze(tag_size, test_output_tag_enc);
            #(PERIOD);
            test_iterator = 0;
            #(PERIOD);
            while(test_iterator < tag_size) begin
                test_output_ct_enc[(pt_size*8+test_iterator*8) +: 8] <= test_output_tag_enc[(test_iterator*8) +: 8];
                test_iterator = test_iterator + 1;
            end
            #(PERIOD);
            // Check ciphertext and tag
            #(PERIOD);
            test_verification <= 1'b1;
            if (true_output_ct_enc == test_output_ct_enc) begin
                test_error <= 1'b0;
            end else begin
                test_error <= 1'b1;
                $display("Computed values do not match expected ones");
            end
            #(PERIOD);
            test_error <= 1'b0;
            test_verification <= 1'b0;
            #(PERIOD);
            // Start the decryption procedure
            // Initialize the state
            test_init_state();
            #(PERIOD);
            // Absorb the key
            test_absorb_keyed(test_input_key_enc, key_size);
            #(PERIOD);
            // Absorb the Nonce
            test_absorb_keyed(test_input_nonce_enc, nonce_size);
            #(PERIOD);
            // Perform Blank
            test_blank();
            #(PERIOD);
            // Absorb the AD
            test_absorb_keyed(test_input_ad_enc, ad_size);
            #(PERIOD);
            // Absorb the ct and decrypt
            test_absorb_decrypt(test_input_ct_dec, pt_size, test_output_pt_dec);
            #(PERIOD);
            // Perform Blank
            test_blank();
            #(PERIOD);
            // Squeeze Tag
            test_squeeze(tag_size, test_output_tag_dec);
            #(PERIOD);
            test_iterator = 0;
            while(test_iterator < tag_size) begin
                test_output_pt_dec[(pt_size*8+test_iterator*8) +: 8] <= test_output_tag_dec[(test_iterator*8) +: 8];
                test_iterator = test_iterator + 1;
            end
            #(PERIOD);
            // Check plaintext and tag
            #(PERIOD);
            test_verification <= 1'b1;
            if (true_output_pt_dec == test_output_pt_dec) begin
                test_error <= 1'b0;
            end else begin
                test_error <= 1'b1;
                $display("Computed values do not match expected ones");
            end
            #(PERIOD);
            test_error <= 1'b0;
            test_verification <= 1'b0;
            #(PERIOD);
            read_ignore_character(aead_file, "\n", temp_text1);
        end
        $fclose(aead_file);
        $display("End of the aead test.");
    end
    $display("End of the test.");
    disable clock_generator;
    #(PERIOD);
end

generate
if(sim_enable_dump == 1'b1) begin
    initial
    begin
        $dumpfile("dump");
        $dumpvars(0, tb_subterranean_rounds_simple_4);
    end
    end
endgenerate

endmodule