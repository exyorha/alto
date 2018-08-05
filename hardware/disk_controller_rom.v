module disk_controller_rom (
    input             clk_i,
    input             rst_i,

    input       [9:0] adr_i,
    output reg [17:0] dat_o
);

    reg [17:0] memory [0:1023];

    always @ (posedge clk_i)
        if(rst_i)
            dat_o <= 18'b0;
        else
            dat_o <= memory[adr_i];

    integer i;
    initial
    begin
        for(i = 0; i < 1024; i = i + 1)
            memory[i[9:0]] = i[17:0];
    end

endmodule
