module disk_controller_spi (
    input        clk_i,
    input        rst_i,

    output reg   sck_o,
    output       mosi_o,
    input        miso_i,

    input  [7:0] dat_i,
    output [7:0] dat_o,

    input        strobe_i,
    output reg   busy_o
);

    `define DISK_CONTROLLER_SPI_STATE_IDLE  5'b00000
    `define DISK_CONTROLLER_SPI_STATE_DWELL 5'b00001
    `define DISK_CONTROLLER_SPI_STATE_HIGH0 5'b00010
    `define DISK_CONTROLLER_SPI_STATE_LOW0  5'b00011
    `define DISK_CONTROLLER_SPI_STATE_HIGH1 5'b00100
    `define DISK_CONTROLLER_SPI_STATE_LOW1  5'b00101
    `define DISK_CONTROLLER_SPI_STATE_HIGH2 5'b00110
    `define DISK_CONTROLLER_SPI_STATE_LOW2  5'b00111
    `define DISK_CONTROLLER_SPI_STATE_HIGH3 5'b01000
    `define DISK_CONTROLLER_SPI_STATE_LOW3  5'b01001
    `define DISK_CONTROLLER_SPI_STATE_HIGH4 5'b01010
    `define DISK_CONTROLLER_SPI_STATE_LOW4  5'b01011
    `define DISK_CONTROLLER_SPI_STATE_HIGH5 5'b01100
    `define DISK_CONTROLLER_SPI_STATE_LOW5  5'b01101
    `define DISK_CONTROLLER_SPI_STATE_HIGH6 5'b01110
    `define DISK_CONTROLLER_SPI_STATE_LOW6  5'b01111
    `define DISK_CONTROLLER_SPI_STATE_HIGH7 5'b10000

    reg [7:0] tx_sr;
    reg [7:0] rx_sr;

    reg [4:0] state;

    always @ (posedge clk_i)  
        if(rst_i)
        begin
          tx_sr  <= 8'b0;
          rx_sr  <= 8'b0;
          busy_o <= 1'b0;
          sck_o  <= 1'b0;
          state  <= `DISK_CONTROLLER_SPI_STATE_IDLE;
        end  
        else
            /* verilator lint_off CASEINCOMPLETE */
            case(state)
            `DISK_CONTROLLER_SPI_STATE_IDLE:
                if(strobe_i)
                begin
                    busy_o <= 1'b1;
                    tx_sr  <= dat_i;
                    state  <= `DISK_CONTROLLER_SPI_STATE_DWELL;
                end

            `DISK_CONTROLLER_SPI_STATE_DWELL:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH0;
            end

            `DISK_CONTROLLER_SPI_STATE_HIGH0:
            begin
                sck_o <= 1'b0;
                tx_sr <= { tx_sr[6:0], 1'b0 };
                state <= `DISK_CONTROLLER_SPI_STATE_LOW0;
            end

            `DISK_CONTROLLER_SPI_STATE_LOW0:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH1;
            end

            `DISK_CONTROLLER_SPI_STATE_HIGH1:
            begin
                sck_o <= 1'b0;
                tx_sr <= { tx_sr[6:0], 1'b0 };
                state <= `DISK_CONTROLLER_SPI_STATE_LOW1;
            end

            `DISK_CONTROLLER_SPI_STATE_LOW1:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH2;
            end

            `DISK_CONTROLLER_SPI_STATE_HIGH2:
            begin
                sck_o <= 1'b0;
                tx_sr <= { tx_sr[6:0], 1'b0 };
                state <= `DISK_CONTROLLER_SPI_STATE_LOW2;
            end

            `DISK_CONTROLLER_SPI_STATE_LOW2:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH3;
            end

            `DISK_CONTROLLER_SPI_STATE_HIGH3:
            begin
                sck_o <= 1'b0;
                tx_sr <= { tx_sr[6:0], 1'b0 };
                state <= `DISK_CONTROLLER_SPI_STATE_LOW3;
            end

            `DISK_CONTROLLER_SPI_STATE_LOW3:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH4;
            end

            `DISK_CONTROLLER_SPI_STATE_HIGH4:
            begin
                sck_o <= 1'b0;
                tx_sr <= { tx_sr[6:0], 1'b0 };
                state <= `DISK_CONTROLLER_SPI_STATE_LOW4;
            end

            `DISK_CONTROLLER_SPI_STATE_LOW4:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH5;
            end
            
            `DISK_CONTROLLER_SPI_STATE_HIGH5:
            begin
                sck_o <= 1'b0;
                tx_sr <= { tx_sr[6:0], 1'b0 };
                state <= `DISK_CONTROLLER_SPI_STATE_LOW5;
            end

            `DISK_CONTROLLER_SPI_STATE_LOW5:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH6;
            end
            
            `DISK_CONTROLLER_SPI_STATE_HIGH6:
            begin
                sck_o <= 1'b0;
                tx_sr <= { tx_sr[6:0], 1'b0 };
                state <= `DISK_CONTROLLER_SPI_STATE_LOW6;
            end

            `DISK_CONTROLLER_SPI_STATE_LOW6:
            begin
                sck_o <= 1'b1;
                rx_sr <= { rx_sr[6:0], miso_i };
                state <= `DISK_CONTROLLER_SPI_STATE_HIGH7;
            end

            `DISK_CONTROLLER_SPI_STATE_HIGH7:
            begin
                sck_o <= 1'b0;
                busy_o <= 1'b0;
                state <= `DISK_CONTROLLER_SPI_STATE_IDLE;
            end
            endcase
            /* verilator lint_on CASEINCOMPLETE */

    assign dat_o = rx_sr;
    assign mosi_o = tx_sr[7];
    
endmodule
