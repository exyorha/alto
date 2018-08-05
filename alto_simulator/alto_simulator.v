module alto_simulator (
    input clk_i,
    input rst_i,
        
    output sd_sck_o,
    output sd_mosi_o,
    input sd_miso_i,
    output sd_ss_n_o
);

    disk_controller disk(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .sd_sck_o(sd_sck_o),
        .sd_mosi_o(sd_mosi_o),
        .sd_miso_i(sd_miso_i),
        .sd_ss_n_o(sd_ss_n_o)
    );

    wire [16:1] wb_adr;
    wire        wb_stb;
    wire        wb_cyc;
    wire        wb_we;
    wire  [1:0] wb_sel;
    wire [15:0] wb_dat_o;
    wire [15:0] wb_dat_i;
    wire        wb_ack;

    alto_system sys (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .wb_adr_o(wb_adr),
        .wb_stb_o(wb_stb),
        .wb_cyc_o(wb_cyc),
        .wb_we_o(wb_we),
        .wb_sel_o(wb_sel),
        .wb_dat_o(wb_dat_o),
        .wb_dat_i(wb_dat_i),
        .wb_ack_i(wb_ack)
    );

    bus_rom #(
        .DEPTH(16),
        .READONLY(0)
    ) ram (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .adr_i(wb_adr),
        .sel_i(wb_sel),
        .stb_i(wb_stb),
        .cyc_i(wb_cyc),
        .we_i(wb_we),
        .dat_i(wb_dat_o),
        .dat_o(wb_dat_i),
        .ack_o(wb_ack),
        .err_o()
    );
    
endmodule
