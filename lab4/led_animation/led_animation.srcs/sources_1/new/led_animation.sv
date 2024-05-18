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

/* Definicja modu³u z wejsciami i wyjsciami zdefiniowanymi w pliku .xdc */
module led_animation(
    // wejscia przycisków
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

// u¿ycie modu³u spowalniaj¹cego zegar
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
localparam length = 3; // d?ugo?? wy?wietlanej sekwencji

localparam num_of_segments = (4 + num_of_displays * 2);
integer curr_state = 0;
integer curr_display = 0;
integer prev = 0;

// robimy cykliczn? kolejk? do przechowywania informacji o za?wieconych segmentach
integer snake[0:num_of_segments][0:1]; 
integer head = length - 1;
integer tail = 0;
integer i; 
initial begin
    for (i = 0; i < num_of_segments; i = i + 1)
        begin
            snake[i][0] = -1;
            snake[i][1] = 0;
        end 
    for (i = 0; i < num_of_displays; i = i + 1)
        display[i] = `DISPLAY_CLEAR;
end

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
    if (snake[tail][0] != -1) // gasimy ogon
        begin
            display[snake[tail][0]] = display[snake[tail][0]] - 2**(snake[tail][1]);
        end
        
    // uaktualnienie wska?ników
    tail = tail + 1;
    head = head + 1;
    if (head == num_of_segments)
        head = 0;
    if (tail == num_of_segments)
        tail = 0;
    
    snake[head][0] = curr_display;

    if (curr_display == 0) // obs?uga prawego wy?wietlacza
        begin           
            snake[head][1] = curr_state;
            
            display[0] = display[0] + 2**curr_state;
            if ((dir == LEFT && curr_state == 0) || (dir == RIGHT && curr_state == 3))
                curr_display = curr_display + 1;
        end
    
    else if (curr_display == (num_of_displays - 1)) // obs?uga lewego wy?wietlacza
        begin
            snake[head][1] = (curr_state - (num_of_displays - 1) < 6 ? curr_state - (num_of_displays - 1) : 0);
            
            display[num_of_displays - 1] = display[num_of_displays - 1] + 2**(curr_state - (num_of_displays - 1) < 6 ? curr_state - (num_of_displays - 1) : 0);
            if ((dir == LEFT && curr_state == (num_of_displays + 2)) || (dir == RIGHT && curr_state == (num_of_displays + 5)))
                curr_display = curr_display - 1;
        end
                
    else if (curr_state > 3 && curr_state < (num_of_displays + 2)) // obs?uga dolnych segmentów
        begin
            snake[head][1] = 3;
            
            display[curr_display] = display[curr_display] + 2**3;
            if (dir == RIGHT)
                begin
                    curr_display = (curr_display + 1) & (num_of_displays - 1);
                end
            
            else
                begin
                    curr_display = (curr_display - 1) & (num_of_displays - 1);
                end
        end
    else // obs?uga górnych segmentów
        begin
            snake[head][1] = 0;
            display[curr_display] = display[curr_display] + 2**0;
            if (dir == RIGHT)
                begin
                    curr_display = (curr_display - 1) & (num_of_displays - 1);
                end
            
            else
                begin
                    curr_display = (curr_display + 1) & (num_of_displays - 1);
                end
        end
end



// u¿ycie modu³u filtruj¹cego zak³ócenia przycisków
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

// blok wykrywaj¹cy narastaj¹ce stanu przyciku poprzez porównanie starej wartosci z now¹ wartoœci¹
always@ (posedge clk)
begin
    if (button_freq_up_active != button_freq_up_old && button_freq_up_active == 1)
        button_freq_up_raise <= 1;
        
    if (button_freq_dn_active != button_freq_dn_old && button_freq_dn_active == 1)
        button_freq_dn_raise <= 1;
        
    if (button_dir_active != button_dir_old && button_dir_active == 1)
        button_dir_raise <= 1;
       
    if (button_freq_up_raise == 1)
        if (clock_period > 1)
            clock_period <= clock_period >> 1;
       
    if (button_freq_dn_raise == 1)
        if (clock_period < 1000*100*1000*100) // maks okres = 100s
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
