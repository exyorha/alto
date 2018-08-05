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

endmodule
