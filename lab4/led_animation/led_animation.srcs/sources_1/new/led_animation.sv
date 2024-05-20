`timescale 1ns / 1ps // tylko dla symulacji

// Przydatne makra dla wyswietlaczow
`define SEGMENT_A_MASK 8'(1 << 0)
`define SEGMENT_B_MASK 8'(1 << 1)
`define SEGMENT_C_MASK 8'(1 << 2)
`define SEGMENT_D_MASK 8'(1 << 3)
`define SEGMENT_E_MASK 8'(1 << 4)
`define SEGMENT_F_MASK 8'(1 << 5)
`define SEGMENT_G_MASK 8'(1 << 6)
`define SEGMENT_DOT_MASK 8'(1 << 7)
`define DISPLAY_CLEAR '0
`define DISPLAY_ALL '1

`define DISPLAY_REFRESH_FREQUENCY (100 * 1000 / 8) // czêstotliwoœæ odœwie¿ania ekranów = 0,125kHz
`define START_ANIMATION_PERIOD (1000*100*1000 / 4) // okres startowy = 0,25s
`define MAX_ANIMATION_PERIOD 1000*100*1000*100 // maks okres = 100s
`define MIN_ANIMATION_PERIOD 1

`define DISPLAY_COUNT 8 // liczba wykorzystywanych wyœwietlaczy

`define MAX_SNAKE_LENGTH (`DISPLAY_COUNT*2 + 3)
`define START_SNAKE_LENGTH 1
`define MIN_SNAKE_LENGTH 1


/* Definicja modu³u z wejsciami i wyjsciami zdefiniowanymi w pliku .xdc */
module led_animation(
    // wejscia przycisków
    input wire btn_freq_up,
    input wire btn_freq_dn,
    input wire btn_dir,
    input wire len_up,
    input wire len_dn,
    
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
longint clock_period = `START_ANIMATION_PERIOD;

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
defparam display_driver.REFERESH_PERIOD = `DISPLAY_REFRESH_FREQUENCY;

// definicja kierunku poruszania sie segmentu
enum {LEFT, RIGHT} dir = RIGHT;

localparam num_of_segments = (4 + `DISPLAY_COUNT * 2);
integer curr_state = 0;
integer curr_display = 0;

// robimy cykliczn¹ kolejkê do przechowywania informacji o zaœwieconych segmentach
integer snake[0:num_of_segments][0:1]; 
integer head = `START_SNAKE_LENGTH - 1;
integer tail = 0;

integer length = `START_SNAKE_LENGTH;
integer old_length = `START_SNAKE_LENGTH;

integer i; 
initial begin
    for (i = 0; i < num_of_segments; i = i + 1)
        begin
            snake[i][0] = -1;
            snake[i][1] = 0;
        end 
    for (i = 0; i < `DISPLAY_COUNT; i = i + 1)
        display[i] = `DISPLAY_CLEAR;
end

// przejœcie na kolejny segment
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
    if (old_length > length) 
        begin
            display[snake[tail][0]] = display[snake[tail][0]] - 2**(snake[tail][1]);
            
            tail = tail + 1;
            old_length = old_length - 1;
            if (tail == num_of_segments)
                tail = 0;
            display[snake[tail][0]] = display[snake[tail][0]] - 2**(snake[tail][1]);
        end
    else if (old_length < length) 
        begin
            tail = tail - 1;
            old_length = old_length + 1;
            if (tail < 0)
                tail = num_of_segments - 1;
        end
        
    else if (snake[tail][0] != -1) // gasimy ogon
        begin
            display[snake[tail][0]] = display[snake[tail][0]] - 2**(snake[tail][1]);
        end
        
    // uaktualnienie wskaŸników
    tail = tail + 1;
    head = head + 1;
    if (head == num_of_segments)
        head = 0;
    if (tail == num_of_segments)
        tail = 0;
    
    snake[head][0] = curr_display;

    if (curr_display == 0) // obs³uga prawego wyœwietlacza
        begin           
            snake[head][1] = curr_state;
            display[0] = display[0] + 2**curr_state;
            
            if ((dir == LEFT && curr_state == 0) || (dir == RIGHT && curr_state == 3))
                curr_display = curr_display + 1;
        end
    
    else if (curr_display == (`DISPLAY_COUNT - 1)) // obs³uga lewego wyœwietlacza
        begin
            snake[head][1] = (curr_state - (`DISPLAY_COUNT - 1) < 6 ? curr_state - (`DISPLAY_COUNT - 1) : 0);
            display[`DISPLAY_COUNT - 1] = display[`DISPLAY_COUNT - 1] + 2**(curr_state - (`DISPLAY_COUNT - 1) < 6 
                                                                            ? curr_state - (`DISPLAY_COUNT - 1) : 0);
            
            if ((dir == LEFT && curr_state == (`DISPLAY_COUNT + 2)) 
                 || (dir == RIGHT && curr_state == (`DISPLAY_COUNT + 5)))
                curr_display = curr_display - 1;
        end
                
    else if (curr_state > 3 && curr_state < (`DISPLAY_COUNT + 2)) // obs³uga dolnych segmentów
        begin
            snake[head][1] = 3;
            display[curr_display] = display[curr_display] + 2**3;
            
            if (dir == RIGHT)
                curr_display = (curr_display + 1) & (`DISPLAY_COUNT - 1);
            
            else
                curr_display = (curr_display - 1) & (`DISPLAY_COUNT - 1);
        end
    else // obs³uga górnych segmentów
        begin
            snake[head][1] = 0;
            display[curr_display] = display[curr_display] + 2**0;
            
            if (dir == RIGHT)
                curr_display = (curr_display - 1) & (`DISPLAY_COUNT - 1);

            else
                curr_display = (curr_display + 1) & (`DISPLAY_COUNT - 1);
        end
end



// u¿ycie modu³u filtruj¹cego zak³ócenia przycisków
reg button_dir_active, button_freq_up_active, button_freq_dn_active, button_len_dn_active, button_len_up_active;
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

debounce len_dn_debounce ( 
    .clk(clk),
    .button_physical(len_dn),
    .button_active(button_len_dn_active)
);

debounce len_up_debounce ( 
    .clk(clk),
    .button_physical(len_up),
    .button_active(button_len_up_active)
);

reg button_freq_up_old = 0;
reg button_freq_dn_old = 0;
reg button_dir_old = 0;
reg button_len_up_old = 0;
reg button_len_dn_old = 0;

reg button_freq_up_raise = 0;
reg button_freq_dn_raise = 0;
reg button_dir_raise = 0;
reg button_len_up_raise = 0;
reg button_len_dn_raise = 0;

// blok wykrywaj¹cy narastaj¹ce stanu przyciku poprzez porównanie starej wartosci z now¹ wartoœci¹
always@ (posedge clk)
begin
    if (button_freq_up_active != button_freq_up_old && button_freq_up_active == 1)
        button_freq_up_raise <= 1;
        
    if (button_freq_dn_active != button_freq_dn_old && button_freq_dn_active == 1)
        button_freq_dn_raise <= 1;
        
    if (button_dir_active != button_dir_old && button_dir_active == 1)
        button_dir_raise <= 1;
        
    if (button_len_up_active != button_len_up_old && button_len_up_active == 1)
        button_len_up_raise <= 1;
        
    if (button_len_dn_active != button_len_dn_old && button_len_dn_active == 1)
        button_len_dn_raise <= 1;
       
    if (button_freq_up_raise == 1)
        if (clock_period > `MIN_ANIMATION_PERIOD)
            clock_period <= clock_period >> 1;
       
    if (button_freq_dn_raise == 1)
        if (clock_period < `MAX_ANIMATION_PERIOD) 
            clock_period <= clock_period << 1;
        
    if (button_dir_raise == 1)
        if(dir == LEFT) dir <= RIGHT;
        else            dir <= LEFT;
    
    if (button_len_up_raise == 1)
        if (length < `MAX_SNAKE_LENGTH) 
            length <= length + 1;
            
    if (button_len_dn_raise == 1)
        if (length > `MIN_SNAKE_LENGTH) 
             length <= length - 1;
        
    button_freq_dn_old <= button_freq_dn_active;
    button_freq_up_old <= button_freq_up_active;
    button_dir_old <= button_dir_active;
    button_len_up_old <= button_len_up_active;
    button_len_dn_old <= button_len_dn_active;
        
    button_freq_up_raise = 0;
    button_freq_dn_raise = 0;
    button_dir_raise = 0;
    button_len_up_raise = 0;
    button_len_dn_raise = 0;
end

endmodule
