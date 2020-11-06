/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module tb_subterranean_rounds_simple_1_axi4_lite
#(parameter PERIOD = 1000,
maximum_line_length = 10000,
MAXIMUM_BUFFER_SIZE = 8192,
skip_hash_test = 0, // 1 - True, 0 - False
skip_aead_test = 0, // 1 - True, 0 - False
test_memory_file_subterranean_hash = "../data_tests/LWC_HASH_KAT_256.txt",
test_memory_file_subterranean_aead = "../data_tests/LWC_AEAD_KAT_128_128.txt",
sim_enable_dump = 1 // 1 - True, 0 - False
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

reg test_aresetn;
reg [7:0] test_s_axi_awaddr;
reg [2:0] test_s_axi_awprot;
reg test_s_axi_awvalid;
wire test_s_axi_awready;
reg [31:0] test_s_axi_wdata;
reg [3:0]  test_s_axi_wstrb;
reg test_s_axi_wvalid;
wire test_s_axi_wready;
wire [1:0] test_s_axi_bresp;
wire test_s_axi_bvalid;
reg test_s_axi_bready;
reg [7:0] test_s_axi_araddr;
reg [2:0] test_s_axi_arprot;
reg test_s_axi_arvalid;
wire test_s_axi_arready;
wire [31:0] test_s_axi_rdata;
wire [1:0]  test_s_axi_rresp;
wire test_s_axi_rvalid;
reg test_s_axi_rready;

reg clk;
reg test_error = 1'b0;
reg test_verification = 1'b0;

localparam tb_delay = PERIOD/2;
localparam tb_delay_read = 3*PERIOD/4;

subterranean_rounds_simple_1_axi4_lite
test (
    .aclk(clk),
    .aresetn(test_aresetn),
    .s_axi_awaddr(test_s_axi_awaddr),
    .s_axi_awprot(test_s_axi_awprot),
    .s_axi_awvalid(test_s_axi_awvalid),
    .s_axi_awready(test_s_axi_awready),
    .s_axi_wdata(test_s_axi_wdata),
    .s_axi_wstrb(test_s_axi_wstrb),
    .s_axi_wvalid(test_s_axi_wvalid),
    .s_axi_wready(test_s_axi_wready),
    .s_axi_bresp(test_s_axi_bresp),
    .s_axi_bvalid(test_s_axi_bvalid),
    .s_axi_bready(test_s_axi_bready),
    .s_axi_araddr(test_s_axi_araddr),
    .s_axi_arprot(test_s_axi_arprot),
    .s_axi_arvalid(test_s_axi_arvalid),
    .s_axi_arready(test_s_axi_arready),
    .s_axi_rdata(test_s_axi_rdata),
    .s_axi_rresp(test_s_axi_rresp),
    .s_axi_rvalid(test_s_axi_rvalid),
    .s_axi_rready(test_s_axi_rready)
);

initial begin : clock_generator
    clk <= 1'b1;
    forever begin
        #(PERIOD/2);
        clk <= ~clk;
    end
end

task axi_4_lite_write_value;
    input [7:0] address;
    input [31:0] value;
    input [1:0] value_size;
    begin
        test_s_axi_awaddr <= 8'h00;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b0;
        test_s_axi_wdata <= 32'b0;
        test_s_axi_wstrb <= 4'b0000;
        test_s_axi_wvalid <= 1'b0;
        test_s_axi_bready <= 1'b0;
        test_s_axi_araddr <= 8'h00;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b0;
        test_s_axi_rready <= 1'b0;
        #(PERIOD);
        test_s_axi_awaddr <= address;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b1;
        test_s_axi_wdata <= value;
        case(value_size)
            2'b00 : begin
                test_s_axi_wstrb <= 4'b0001;
            end
            2'b01 : begin
                test_s_axi_wstrb <= 4'b0011;
            end
            2'b10 : begin
                test_s_axi_wstrb <= 4'b0111;
            end
            2'b11 : begin
                test_s_axi_wstrb <= 4'b1111;
            end
        endcase
        test_s_axi_wvalid <= 1'b1;
        if((test_s_axi_awvalid != 1'b1) || (test_s_axi_awready != 1'b1)) begin
            #(PERIOD);
        end
        if((test_s_axi_wvalid != 1'b1) || (test_s_axi_wready != 1'b1)) begin
            #(PERIOD);
        end
        test_s_axi_awaddr <= 8'h00;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b0;
        test_s_axi_wdata <= 32'b0;
        test_s_axi_wstrb <= 4'b0000;
        test_s_axi_wvalid <= 1'b0;
        test_s_axi_bready <= 1'b1;
        if((test_s_axi_bvalid != 1'b1) || (test_s_axi_bready != 1'b1)) begin
            #(PERIOD);
        end
        #(PERIOD);
        test_s_axi_bready <= 1'b0;
        #(PERIOD);
    end
endtask

task axi_4_lite_read_value;
    input [7:0] address;
    output [31:0] value;
    begin
        test_s_axi_awaddr <= 8'h00;
        test_s_axi_awprot <= 3'b000;
        test_s_axi_awvalid <= 1'b0;
        test_s_axi_wdata <= 32'b0;
        test_s_axi_wstrb <= 4'b0000;
        test_s_axi_wvalid <= 1'b0;
        test_s_axi_bready <= 1'b0;
        test_s_axi_araddr <= 8'h00;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b0;
        test_s_axi_rready <= 1'b0;
        #(PERIOD);
        test_s_axi_araddr <= address;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b1;
        if((test_s_axi_arvalid != 1'b1) || (test_s_axi_arready != 1'b1)) begin
            #(PERIOD);
        end
        test_s_axi_araddr <= 8'h00;
        test_s_axi_arprot <= 3'b000;
        test_s_axi_arvalid <= 1'b0;
        test_s_axi_rready <= 1'b1;
        if((test_s_axi_rvalid != 1'b1) || (test_s_axi_rready != 1'b1)) begin
            #(PERIOD);
        end
        #(PERIOD);
        test_s_axi_rready <= 1'b0;
        value <= test_s_axi_rdata;
        #(PERIOD);
    end
endtask

task test_init_state;
    begin
    axi_4_lite_write_value({3'b000, 3'b100,2'b00}, 32'b0, 2'b11);
    end
endtask

task test_absorb_unkeyed;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    integer temp_i;
    begin
        #PERIOD;
        temp_i = 0;
        while(temp_i < buffer_size) begin
            axi_4_lite_write_value({3'b001, 3'b001,2'b00}, buffer_in[8*temp_i +: 8], 2'b11);
            #(PERIOD);
            axi_4_lite_write_value({3'b001, 3'b000,2'b00}, 32'b0, 2'b11);
            #(PERIOD);
            temp_i = temp_i + 1;
        end
        #(PERIOD);
        axi_4_lite_write_value({3'b001, 3'b000,2'b00}, 32'b0, 2'b11);
        #(PERIOD);
        axi_4_lite_write_value({3'b001, 3'b000,2'b00}, 32'b0, 2'b11);
        #(PERIOD);
    end
endtask

task test_absorb_keyed;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    reg [31:0] temp_din;
    reg [2:0] temp_din_size;
    integer iterator_buffer;
    integer iterator_din;
    integer last_block;
    begin
        #PERIOD;
        iterator_buffer = 0;
        if(buffer_size >= 4) begin
            while(iterator_buffer <= 8*(buffer_size - 4)) begin
                axi_4_lite_write_value({3'b001, 3'b100,2'b00}, buffer_in[iterator_buffer +: 32], 2'b11);
                #(PERIOD);
                iterator_buffer = iterator_buffer + 32;
            end
        end
        last_block = 8*buffer_size - iterator_buffer;
        if(last_block == 0) begin
            axi_4_lite_write_value({3'b001, 3'b000,2'b00}, 32'b0, 2'b11);
            #(PERIOD);
        end else begin
            iterator_din = 0;
            while(iterator_din < last_block) begin
                temp_din[iterator_din +: 8] <= buffer_in[iterator_buffer +: 8];
                iterator_buffer = iterator_buffer + 8;
                iterator_din = iterator_din + 8;
            end
            while(iterator_din < 32) begin
                temp_din[iterator_din +: 8] <= 8'b0;
                iterator_din = iterator_din + 1;
            end
            temp_din_size <= last_block/8;
            #(PERIOD);
            axi_4_lite_write_value({3'b001, temp_din_size,2'b00}, temp_din, 2'b11);
            #(PERIOD);
        end
    end
endtask

task test_absorb_encrypt;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    output [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_out;
    reg [31:0] temp_din;
    reg [31:0] temp_dout;
    reg [2:0] temp_din_size;
    integer iterator_buffer_in;
    integer iterator_buffer_out;
    integer iterator_din;
    integer last_block;
    begin
        buffer_out <= {MAXIMUM_BUFFER_SIZE{1'b0}};
        #PERIOD;
        iterator_buffer_in = 0;
        iterator_buffer_out = 0;
        if(buffer_size >= 4) begin
            while(iterator_buffer_in <= 8*(buffer_size - 4)) begin
                axi_4_lite_write_value({3'b010, 3'b100,2'b00}, buffer_in[iterator_buffer_in +: 32], 2'b11);
                #(PERIOD);
                axi_4_lite_read_value({3'b101, 3'b100,2'b00}, buffer_out[iterator_buffer_out +: 32]);
                #(PERIOD);
                iterator_buffer_in = iterator_buffer_in + 32;
                iterator_buffer_out = iterator_buffer_out + 32;
            end
        end
        last_block = 8*buffer_size - iterator_buffer_in;
        if(last_block == 0) begin
            axi_4_lite_write_value({3'b010, 3'b000,2'b00}, 32'b0, 2'b11);
            #(PERIOD);
        end else begin
            iterator_din = 0;
            while(iterator_din < last_block) begin
                temp_din[iterator_din +: 8] <= buffer_in[iterator_buffer_in +: 8];
                iterator_buffer_in = iterator_buffer_in + 8;
                iterator_din = iterator_din + 8;
            end
            while(iterator_din < 32) begin
                temp_din[iterator_din +: 8] <= 8'b0;
                iterator_din = iterator_din + 8;
            end
            temp_din_size <= last_block/8;
            #(PERIOD);
            axi_4_lite_write_value({3'b010, temp_din_size,2'b00}, temp_din, 2'b11);
            #(PERIOD);
            axi_4_lite_read_value({3'b101, 3'b100,2'b00}, temp_dout);
            #(PERIOD);
            iterator_din = 0;
            while(iterator_din < last_block) begin
                buffer_out[iterator_buffer_out +:8] <= temp_dout[iterator_din +:8];
                iterator_buffer_out = iterator_buffer_out + 8;
                iterator_din = iterator_din + 8;
            end
            #(PERIOD);
        end
    end
endtask

task test_absorb_decrypt;
    input [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_in;
    input integer buffer_size;
    output [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_out;
    reg [31:0] temp_din;
    reg [31:0] temp_dout;
    reg [2:0] temp_din_size;
    integer iterator_buffer_in;
    integer iterator_buffer_out;
    integer iterator_din;
    integer last_block;
    begin
        buffer_out <= {MAXIMUM_BUFFER_SIZE{1'b0}};
        #PERIOD;
        iterator_buffer_in = 0;
        iterator_buffer_out = 0;
        if(buffer_size >= 4) begin
            while(iterator_buffer_in <= 8*(buffer_size - 4)) begin
                axi_4_lite_write_value({3'b011, 3'b100,2'b00}, buffer_in[iterator_buffer_in +: 32], 2'b11);
                #(PERIOD);
                axi_4_lite_read_value({3'b101, 3'b100,2'b00}, buffer_out[iterator_buffer_out +: 32]);
                #(PERIOD);
                iterator_buffer_in = iterator_buffer_in + 32;
                iterator_buffer_out = iterator_buffer_out + 32;
            end
        end
        last_block = 8*buffer_size - iterator_buffer_in;
        if(last_block == 0) begin
            axi_4_lite_write_value({3'b011, 3'b000,2'b00}, 32'b0, 2'b11);
            #(PERIOD);
        end else begin
            iterator_din = 0;
            while(iterator_din < last_block) begin
                temp_din[iterator_din +: 8] <= buffer_in[iterator_buffer_in +: 8];
                iterator_buffer_in = iterator_buffer_in + 8;
                iterator_din = iterator_din + 8;
            end
            while(iterator_din < 32) begin
                temp_din[iterator_din +: 8] <= 8'b0;
                iterator_din = iterator_din + 8;
            end
            temp_din_size <= last_block/8;
            #(PERIOD);
            axi_4_lite_write_value({3'b011, temp_din_size,2'b00}, temp_din, 2'b11);
            #(PERIOD);
            axi_4_lite_read_value({3'b101, 3'b100,2'b00}, temp_dout);
            #(PERIOD);
            iterator_din = 0;
            while(iterator_din < last_block) begin
                buffer_out[iterator_buffer_out +:8] <= temp_dout[iterator_din +:8];
                iterator_buffer_out = iterator_buffer_out + 8;
                iterator_din = iterator_din + 8;
            end
            #(PERIOD);
        end
    end
endtask

task test_squeeze;
    input integer buffer_size;
    output [(MAXIMUM_BUFFER_SIZE - 1):0] buffer_out;
    reg [31:0] temp_dout;
    integer iterator_buffer_out;
    integer iterator_dout;
    integer last_block;
    begin
        buffer_out <= {MAXIMUM_BUFFER_SIZE{1'b0}};
        #PERIOD;
        iterator_buffer_out = 0;
        if(buffer_size >= 4) begin
            while(iterator_buffer_out <= 8*(buffer_size - 4)) begin
                axi_4_lite_write_value({3'b100, 3'b000,2'b00}, 32'b00, 2'b11);
                #(PERIOD);
                axi_4_lite_read_value({3'b101, 3'b100,2'b00}, buffer_out[iterator_buffer_out +: 32]);
                #(PERIOD);
                iterator_buffer_out = iterator_buffer_out + 32;
            end
        end
        #(PERIOD);
        last_block = 8*buffer_size - iterator_buffer_out;
        if(last_block != 0) begin
            iterator_dout = 0;
            axi_4_lite_write_value({3'b100, 3'b000,2'b00}, 32'b00, 2'b11);
            #(PERIOD);
            axi_4_lite_read_value({3'b101, 3'b100,2'b00}, temp_dout);
            #(PERIOD);
            while(iterator_dout < last_block) begin
                buffer_out[iterator_buffer_out +: 8] <= temp_dout[iterator_dout +: 8];
                iterator_buffer_out = iterator_buffer_out + 8;
                iterator_dout = iterator_dout + 8;
            end
        end
    end
endtask

task test_blank;
    integer temp_i;
    begin
        temp_i = 0;
        #PERIOD;
        while(temp_i < 8) begin
            axi_4_lite_write_value({3'b001, 3'b000,2'b00}, 32'b00, 2'b11);
            #(PERIOD);
            temp_i = temp_i + 1;
        end
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
    test_aresetn <= 1'b0;
    test_s_axi_awaddr <= 8'h00;
    test_s_axi_awprot <= 3'b000;
    test_s_axi_awvalid <= 1'b0;
    test_s_axi_wdata <= 32'b0;
    test_s_axi_wstrb <= 4'b0000;
    test_s_axi_wvalid <= 1'b0;
    test_s_axi_bready <= 1'b0;
    test_s_axi_araddr <= 8'h00;
    test_s_axi_arprot <= 3'b000;
    test_s_axi_arvalid <= 1'b0;
    test_s_axi_rready <= 1'b0;
    
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
    test_aresetn <= 1'b1;
    #(PERIOD);
    #(tb_delay);
    if(skip_hash_test == 0) begin
        $display("Start of the hash test");
        hash_file = $fopen(test_memory_file_subterranean_hash, "r");
        while(!$feof(hash_file)) begin
            read_until_get_character(hash_file, "=");
            status_ram_file = $fscanf(hash_file, "%d", count);
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
        $dumpvars(1, tb_subterranean_rounds_simple_1_axi4_lite);
        $dumpvars(1, tb_subterranean_rounds_simple_1_axi4_lite.test);
    end
end
endgenerate

endmodule