/*--------------------------------------------------------------------------------*/
/* Implementation by Pedro Maat C. Massolino,                                     */
/* hereby denoted as "the implementer".                                           */
/*                                                                                */
/* To the extent possible under law, the implementer has waived all copyright     */
/* and related or neighboring rights to the source code in this file.             */
/* http://creativecommons.org/publicdomain/zero/1.0/                              */
/*--------------------------------------------------------------------------------*/
`default_nettype    none

module subterranean_rounds_simple_1_axi4_lite
(
    input wire aclk,
    input wire aresetn,
    // Write Address related signals
    input wire [7:0] s_axi_awaddr,
    input wire [2:0] s_axi_awprot,
    input wire s_axi_awvalid,
    output wire s_axi_awready,
    // Write data signals
    input wire [31:0] s_axi_wdata,
    input wire [3:0] s_axi_wstrb,
    input wire s_axi_wvalid,
    output wire s_axi_wready,
    // Response channel
    output wire [1:0] s_axi_bresp,
    output wire s_axi_bvalid,
    input wire s_axi_bready,
    // Read Address related signals
    input wire [7:0] s_axi_araddr,
    input wire [2:0] s_axi_arprot,
    input wire s_axi_arvalid,
    output wire s_axi_arready,
    // Read data signals
    output wire [31:0] s_axi_rdata,
    output wire [1:0] s_axi_rresp,
    output wire s_axi_rvalid,
    input wire s_axi_rready
);


reg [7:0] reg_s_axi_awaddr;
reg [2:0] reg_s_axi_awprot;
reg reg_s_axi_awvalid;
reg reg_s_axi_awready;

reg reg_s_axi_awaddr_is_good;

reg [31:0] reg_s_axi_wdata;
reg [3:0] reg_s_axi_wstrb;
reg reg_s_axi_wvalid;
reg reg_s_axi_wready;

wire [2:0] reg_s_axi_wdata_number_bytes;

reg [1:0] reg_s_axi_bresp;
reg reg_s_axi_bvalid;

reg [7:0] reg_s_axi_araddr;
reg [2:0] reg_s_axi_arprot;
reg reg_s_axi_arvalid;
reg reg_s_axi_arready;

reg reg_s_axi_araddr_is_good;

reg [31:0] reg_s_axi_rdata;
reg [1:0] reg_s_axi_rresp;
reg reg_s_axi_rvalid;

reg cipher_enable;
reg cipher_init;
reg cipher_encrypt;
reg cipher_decrypt;
wire [31:0] cipher_din;
wire [2:0] cipher_din_size;
reg cipher_din_valid;
wire cipher_din_ready;
wire [31:0] cipher_dout;
wire cipher_dout_valid;
reg cipher_dout_ready;
wire cipher_free;
wire cipher_finish;

reg [31:0] reg_cipher_dout;


assign s_axi_awready = reg_s_axi_awready;

assign s_axi_wready  = reg_s_axi_wready;

assign s_axi_bresp   = reg_s_axi_bresp;
assign s_axi_bvalid  = reg_s_axi_bvalid;

assign s_axi_arready = reg_s_axi_arready;

assign s_axi_rdata   = reg_s_axi_rdata;
assign s_axi_rresp   = reg_s_axi_rresp;
assign s_axi_rvalid  = reg_s_axi_rvalid;

// Input registers for Write address

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awaddr <= 8'b0;
    end else if (s_axi_awvalid == 1'b1) begin
        reg_s_axi_awaddr <= s_axi_awaddr;
    end
end

always @(*) begin
    if(reg_s_axi_awaddr[1:0] != 2'b00) begin
        reg_s_axi_awaddr_is_good <= 1'b0;
    end else begin
        case(reg_s_axi_awaddr[7:5])
            // Valid writing addresses
            3'b000 : begin // Initialize
                reg_s_axi_awaddr_is_good <= 1'b1;
            end
            3'b001 : begin // Duplex Simple
                reg_s_axi_awaddr_is_good <= 1'b1;
            end
            3'b010 : begin // Duplex Encrypt
                reg_s_axi_awaddr_is_good <= 1'b1;
            end
            3'b011 : begin // Duplex Decrypt
                reg_s_axi_awaddr_is_good <= 1'b1;
            end
            3'b100 : begin // Duplex Squeeze
                reg_s_axi_awaddr_is_good <= 1'b1;
            end
            default: begin // Not valid address
                reg_s_axi_awaddr_is_good <= 1'b0;
            end
        endcase
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awprot <= 3'b0;
    end else if (s_axi_awvalid == 1'b1) begin
        reg_s_axi_awprot <= s_axi_awprot;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awvalid <= 1'b0;
    end else if ((reg_s_axi_awvalid == 1'b0) || (reg_s_axi_wvalid == 1'b1)) begin
        reg_s_axi_awvalid <= s_axi_awvalid;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_awready <= 1'b0;
    end else begin
        reg_s_axi_awready <= 1'b1;
    end
end

// Input registers for Write data

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wdata <= 32'b0;
    end else if (s_axi_wvalid == 1'b1) begin
        reg_s_axi_wdata <= s_axi_wdata;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wstrb <= 3'b0;
    end else if (s_axi_wvalid == 1'b1) begin
        reg_s_axi_wstrb <= s_axi_wstrb;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wvalid <= 1'b0;
    end else if ((reg_s_axi_wvalid == 1'b0) || (reg_s_axi_awvalid == 1'b1)) begin
        reg_s_axi_wvalid <= s_axi_wvalid;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_wready <= 1'b0;
    end else begin
        reg_s_axi_wready <= 1'b1;
    end
end

assign reg_s_axi_wdata_number_bytes = reg_s_axi_awaddr[4:2];

// Response channel

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_bresp <= 2'b00;
    end else if ((reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
        if (reg_s_axi_awaddr_is_good == 1'b0) begin
            reg_s_axi_bresp <= 2'b10;
        end else begin
            reg_s_axi_bresp <= 2'b00;
        end
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_bvalid <= 1'b0;
    end else begin 
        if ((reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
            reg_s_axi_bvalid <= 1'b1;
        end else if ((reg_s_axi_bvalid == 1'b1) && (s_axi_bready == 1'b1)) begin
            reg_s_axi_bvalid <= 1'b0;
        end
    end
end

// Read Address related signals

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_araddr <= 8'b0;
    end else if (s_axi_arvalid == 1'b1) begin
        reg_s_axi_araddr <= s_axi_araddr;
    end
end

always @(*) begin
    if(reg_s_axi_araddr[1:0] != 2'b00) begin
        reg_s_axi_araddr_is_good <= 1'b0;
    end else begin
        case(reg_s_axi_araddr[7:5])
            // Valid reading addresses
            3'b000 : begin // Initialize
                reg_s_axi_araddr_is_good <= 1'b1;
            end
            3'b001 : begin // Duplex Simple
                reg_s_axi_araddr_is_good <= 1'b1;
            end
            3'b010 : begin // Duplex Encrypt
                reg_s_axi_araddr_is_good <= 1'b1;
            end
            3'b011 : begin // Duplex Decrypt
                reg_s_axi_araddr_is_good <= 1'b1;
            end
            3'b100 : begin // Duplex Squeeze
                reg_s_axi_araddr_is_good <= 1'b1;
            end
            3'b101 : begin // Read buffer
                reg_s_axi_araddr_is_good <= 1'b1;
            end
            default: begin // Not valid address
                reg_s_axi_araddr_is_good <= 1'b0;
            end
        endcase
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_arprot <= 3'b0;
    end else if (s_axi_arvalid == 1'b1) begin
        reg_s_axi_arprot <= s_axi_arprot;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_arvalid <= 1'b0;
    end else begin
        reg_s_axi_arvalid <= s_axi_arvalid;
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_arready <= 1'b0;
    end else begin
        reg_s_axi_arready <= 1'b1;
    end
end

// Read Data related signals

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_rdata <= 32'b0;
    end else begin
        if (reg_s_axi_arvalid == 1'b1) begin
            if (reg_s_axi_araddr[7:5] == 3'b101) begin
                reg_s_axi_rdata <= reg_cipher_dout;
            end else begin
                reg_s_axi_rdata <= 32'b0;
            end
        end
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_rresp <= 2'b0;
    end else if (reg_s_axi_arvalid == 1'b1) begin
        if(reg_s_axi_araddr_is_good == 1'b0) begin
            reg_s_axi_rresp <= 2'b10;
        end else begin
            reg_s_axi_rresp <= 2'b00;
        end
    end
end

always @(posedge aclk or negedge aresetn) begin
    if (aresetn == 1'b0) begin
        reg_s_axi_rvalid <= 1'b0;
    end else begin
        if (reg_s_axi_arvalid == 1'b1) begin
            reg_s_axi_rvalid <= 1'b1;
        end else if (reg_s_axi_rvalid == 1'b1 && s_axi_rready == 1'b1) begin
            reg_s_axi_rvalid <= 1'b0;
        end
    end
end

always @(*) begin
    if((reg_s_axi_awaddr_is_good == 1'b1) && (reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
        cipher_enable <= 1'b1;
    end else begin
        cipher_enable <= 1'b0;
    end
end


always @(*) begin
    if((reg_s_axi_awaddr_is_good == 1'b1) && (reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1) && (reg_s_axi_awaddr[7:5] == 3'b000)) begin
        cipher_init <= 1'b1;
    end else begin
        cipher_init <= 1'b0;
    end
end

always @(*) begin
    if((reg_s_axi_awaddr_is_good == 1'b1) && (reg_s_axi_awvalid == 1'b1) && (reg_s_axi_wvalid == 1'b1)) begin
        cipher_din_valid <= 1'b1;
        cipher_dout_ready <= 1'b1;
    end else begin
        cipher_din_valid <= 1'b0;
        cipher_dout_ready <= 1'b0;
    end
end

always @(*) begin
    if((reg_s_axi_awaddr[7:5] == 3'b010)) begin
        cipher_encrypt <= 1'b1;
    end else begin
        cipher_encrypt <= 1'b0;
    end
end

always @(*) begin
    if((reg_s_axi_awaddr[7:5] == 3'b011)) begin
        cipher_decrypt <= 1'b1;
    end else begin
        cipher_decrypt <= 1'b0;
    end
end

assign cipher_din = reg_s_axi_wdata;
assign cipher_din_size = reg_s_axi_wdata_number_bytes;

subterranean_rounds_simple_1
cipher (
    .clk(aclk),
    .arstn(aresetn),
    .enable(cipher_enable),
    .init(cipher_init),
    .encrypt(cipher_encrypt),
    .decrypt(cipher_decrypt),
    .din(cipher_din),
    .din_valid(cipher_din_valid),
    .din_ready(cipher_din_ready),
    .din_size(cipher_din_size),
    .dout(cipher_dout),
    .dout_valid(cipher_dout_valid),
    .dout_ready(cipher_dout_ready),
    .free(cipher_free),
    .finish(cipher_finish)
);

always @(posedge aclk) begin
    if (cipher_din_valid == 1'b1) begin
        reg_cipher_dout <= cipher_dout;
    end
end

endmodule