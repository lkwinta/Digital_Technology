`timescale 1ns / 1ps

`define USED_DISPLAY_COUNT 8

module displays_driver #(parameter REFERESH_PERIOD = 100 * 1000)(
    input wire clk,
    
    // rejestr wejœciowy okreœlaj¹cy stan wszystkich wyœwietlaczy
    input reg [7:0] display [7:0],
    
    // wyjscia steujace wyswietlaczami
    // stan niski na danym indeksie aktywuje dany wyswietlacz
    output reg [7:0] sseg_anodes,
    
    // |   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |
    // |  DP   |   CG  |  CF   |  CE   |  CD   |  CC   |  CB   |  CA   |
    // stan niski na danym indeksie aktywuje dany segment na wszystkich aktywnych wyswietlaczach
    output reg [7:0] sseg_cathodes
);

initial 
begin
    sseg_anodes <= '1;
    sseg_cathodes <= '1;
end

reg refresh_clk; //1 khz refresh clock
clock_divider clk_div (
    .clock_period(REFERESH_PERIOD),
    .clk(clk),
    .divided_clock(refresh_clk)
);

reg [3:0] display_number = 0;

always@ (posedge refresh_clk)
begin 
    sseg_anodes = '1;
    sseg_anodes[display_number] <= 0;
    sseg_cathodes <= 8'(~display[display_number]);
    
    display_number = display_number + 1;
    if (display_number >= `USED_DISPLAY_COUNT)
        display_number <= 0;
end

endmodule
