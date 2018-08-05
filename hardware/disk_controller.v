module disk_controller #(
    parameter USE_KCPSM3 = 1'b0
) (
    input clk_i,
    input rst_i,

    output sd_sck_o,
    output sd_mosi_o,
    input sd_miso_i,
    output sd_ss_n_o
);

    `define DISK_CONTROLLER_PORT_SPI_DATA   1'b0
    `define DISK_CONTROLLER_PORT_SPI_STATUS 1'b1

    wire [9:0] ibus_adr;
    wire [17:0] ibus_dat;

    wire [7:0] pbus_adr;
    wire [7:0] pbus_dat_o;
    reg [7:0] pbus_dat_i;
    wire pbus_wr;
    wire pbus_rd;

    wire interrupt;
    wire interrupt_ack;

    reg sd_select;
    wire [7:0] spi_dat;
    wire spi_busy;

    generate
        if(USE_KCPSM3)
        begin : kcpsm3
            kcpsm3 cpu (
                .address(ibus_adr),
                .instruction(ibus_dat),
                .port_id(pbus_adr),
                .write_strobe(pbus_wr),
                .out_port(pbus_dat_o),
                .read_strobe(pbus_rd),
                .in_port(pbus_dat_i),
                .interrupt(interrupt),
                .interrupt_ack(interrupt_ack),
                .reset(rst_i),
                .clk(clk_i)
            );
        end
        else
        begin : pacoblaze
            pacoblaze cpu (
                .address(ibus_adr),
                .instruction(ibus_dat),
                .port_id(pbus_adr),
                .write_strobe(pbus_wr),
                .out_port(pbus_dat_o),
                .read_strobe(pbus_rd),
                .in_port(pbus_dat_i),
                .interrupt(interrupt),
                .interrupt_ack(interrupt_ack),
                .reset(rst_i),
                .clk(clk_i)
            );
        end
    endgenerate

    disk_controller_rom rom (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .adr_i(ibus_adr),
        .dat_o(ibus_dat)
    );

    disk_controller_spi spi (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .sck_o(sd_sck_o),
        .mosi_o(sd_mosi_o),
        .miso_i(sd_miso_i),

        .dat_i(pbus_dat_o),
        .dat_o(spi_dat),

        .strobe_i(pbus_wr && pbus_adr[0:0] == `DISK_CONTROLLER_PORT_SPI_DATA),
        .busy_o(spi_busy)
    );
    
    always @ (*)
        case(pbus_adr[0:0])
        `DISK_CONTROLLER_PORT_SPI_DATA:
            pbus_dat_i = spi_dat;

        `DISK_CONTROLLER_PORT_SPI_STATUS:
            pbus_dat_i = { 6'b0, sd_select, spi_busy };
        endcase

    always @ (posedge clk_i)
        if(rst_i)
        begin
            sd_select <= 1'b0;
        end
        else
        begin
            if(pbus_wr)
                case(pbus_adr[0:0])
                `DISK_CONTROLLER_PORT_SPI_DATA: ;
                `DISK_CONTROLLER_PORT_SPI_STATUS:
                begin
                    sd_select <= pbus_dat_o[1];
                end
                endcase
        end

    assign sd_ss_n_o = ~sd_select;

endmodule
