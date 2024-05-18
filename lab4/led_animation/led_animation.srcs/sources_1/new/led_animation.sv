`timescale 1ns / 1ps // tylko dla symulacji

// Przydatne makra dla wyswietlaczow
`define SET_ACTIVE(mask) 8'(~mask)

`define SEGMENT_A_MASK 8'(1 << 0)
`define SEGMENT_B_MASK 8'( 1 << 1)
`define SEGMENT_C_MASK 8'( 1 << 2)
`define SEGMENT_D_MASK 8'( 1 << 3)
`define SEGMENT_E_MASK 8'( 1 << 4)
`define SEGMENT_F_MASK 8'( 1 << 5)
`define SEGMENT_G_MASK 8'( 1 << 6)
`define SEGMENT_DOT_MASK 8'( 1 << 7)
`define DISPLAY_CLEAR '0
`define DISPLAY_ALL '1

/* Definicja modu�u z wejsciami i wyjsciami zdefiniowanymi w pliku .xdc */
module led_animation(
    // wejscia przycisk�w
    input wire btn_freq_up,
    input wire btn_freq_dn,
    input wire btn_dir,
    
    input wire clk, // zegar systemowy 100Mhz
    
    // wyjscia steujace wyswietlaczami
    // stan niski na danym indeksie aktywuje dany wyswietlacz
    output reg [7:0] sseg_anodes,
    
    // |   7   |   6   |   5   |   4   |   3   |   2   |   1   |   0   |
    // |  DP   |   CG  |  CF   |  CE   |  CD   |  CC   |  CB   |  CA   |
    // stan niski na danym indeksie aktywuje dany segment na wszystkich aktywnych wyswietlaczach
    output reg [7:0] sseg_cathodes,
    
    // wyjscie sterujace ledem
    output wire clk_led
);

initial
begin
    sseg_cathodes <= '1;
    sseg_anodes <= '1;
end

// startowy okres spowolnionego zegara
longint clock_period = 1000*100*1000 / 4;

// u�ycie modu�u spowalniaj�cego zegar
reg divided_clk;
assign clk_led = divided_clk;
clock_divider clk_div (
    .clock_period(clock_period),
    .clk(clk),
    .divided_clock(divided_clk)
);

reg [7:0] display [7:0];
displays_driver display_driver (
    .clk(clk),
    .display(display),
    .sseg_anodes(sseg_anodes),
    .sseg_cathodes(sseg_cathodes)
);
defparam display_driver.REFERESH_PERIOD = 100 * 1000 / 8;

// definicja kierunku poruszania sie segmentu
enum {LEFT, RIGHT} dir = RIGHT;


localparam num_of_displays = 4; // liczba wykorzystywanych wy?wietlaczy
localparam num_of_segments = (4 + num_of_displays * 2);
integer curr_state = 0;
integer curr_display = 0;
integer prev = 0;

// przej?cie na kolejny segment
always@ (posedge divided_clk)
begin
    if (dir == RIGHT)
        curr_state = (curr_state + 1);
    else
        curr_state = (curr_state - 1);
        
    if (curr_state < 0)
        curr_state = num_of_segments + curr_state;
        
    else if (curr_state > num_of_segments - 1)
        curr_state = curr_state - num_of_segments;
end

always@ (posedge divided_clk)
begin
    if (curr_display == 0) // obs?uga prawego wy?wietlacza
        begin
            display[prev] = `DISPLAY_CLEAR;
            display[0] = 8'(1 << curr_state);
            prev = curr_display;
            if ((dir == LEFT && curr_state == 0) || (dir == RIGHT && curr_state == 3))
                curr_display = curr_display + 1;
        end
    
    else if (curr_display == (num_of_displays - 1)) // obs?uga dolnego wy?wietlacza
        begin
            display[prev] = `DISPLAY_CLEAR;
            display[num_of_displays - 1] = 8'(1 << curr_state - (num_of_displays - 1));
            prev = curr_display;
            if ((dir == LEFT && curr_state == (num_of_displays + 2)) || (dir == RIGHT && curr_state == (num_of_displays + 5)))
                curr_display = curr_display - 1;
        end
                
    else if (curr_state > 3 && curr_state < (num_of_displays + 2)) // obs?uga dolnych segment�w
        begin
            display[prev] = `DISPLAY_CLEAR;
            prev = curr_display;
            if (dir == RIGHT)
                begin
                    display[curr_display] = 8'(1 << 3);
                    curr_display = (curr_display + 1) & (num_of_displays - 1);
                end
            
            else
                begin
                    display[curr_display] = 8'(1 << 3);
                    curr_display = (curr_display - 1) & (num_of_displays - 1);
                end
        end
    else // obs?uga g�rnych segment�w
        begin
        display[prev] = `DISPLAY_CLEAR;
        prev = curr_display;
            if (dir == RIGHT)
                begin
                    display[curr_display] = 8'(1 << 0);
                    curr_display = (curr_display - 1) & (num_of_displays - 1);
                end
            
            else
                begin
                    display[curr_display] = 8'(1 << 0);
                    curr_display = (curr_display + 1) & (num_of_displays - 1);
                end
        end
end



// u�ycie modu�u filtruj�cego zak��cenia przycisk�w
reg button_dir_active, button_freq_up_active, button_freq_dn_active;
debounce dir_debounce ( 
    .clk(clk),
    .button_physical(btn_dir),
    .button_active(button_dir_active)
);

debounce freq_up_debounce ( 
    .clk(clk),
    .button_physical(btn_freq_up),
    .button_active(button_freq_up_active)
);

debounce freq_dn_debounce ( 
    .clk(clk),
    .button_physical(btn_freq_dn),
    .button_active(button_freq_dn_active)
);

reg button_freq_up_old = 0;
reg button_freq_dn_old = 0;
reg button_dir_old = 0;

reg button_freq_up_raise = 0;
reg button_freq_dn_raise = 0;
reg button_dir_raise = 0;

// blok wykrywaj�cy narastaj�ce stanu przyciku poprzez por�wnanie starej wartosci z now� warto�ci�
always@ (posedge clk)
begin
    if (button_freq_up_active != button_freq_up_old && button_freq_up_active == 1)
        button_freq_up_raise <= 1;
        
    if (button_freq_dn_active != button_freq_dn_old && button_freq_dn_active == 1)
        button_freq_dn_raise <= 1;
        
    if (button_dir_active != button_dir_old && button_dir_active == 1)
        button_dir_raise <= 1;
       
    if (button_freq_up_raise == 1)
        clock_period <= clock_period >> 1;
       
    if (button_freq_dn_raise == 1)
        clock_period <= clock_period << 1;
        
    if (button_dir_raise == 1)
        if(dir == LEFT) dir <= RIGHT;
        else            dir <= LEFT;
        
    button_freq_dn_old <= button_freq_dn_active;
    button_freq_up_old <= button_freq_up_active;
    button_dir_old <= button_dir_active;
        
    button_freq_up_raise = 0;
    button_freq_dn_raise = 0;
    button_dir_raise = 0;
end

endmodule
