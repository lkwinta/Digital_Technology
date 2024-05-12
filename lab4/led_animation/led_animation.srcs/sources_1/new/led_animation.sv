`timescale 1ns / 1ps // tylko dla symulacji

// Przydatne makra dla wyswietlaczow
`define SET_ACTIVE(mask) (~mask)

`define SEGMENT_A_MASK ( 1 << 0)
`define SEGMENT_B_MASK ( 1 << 1)
`define SEGMENT_C_MASK ( 1 << 2)
`define SEGMENT_D_MASK ( 1 << 3)
`define SEGMENT_E_MASK ( 1 << 4)
`define SEGMENT_F_MASK ( 1 << 5)
`define SEGMENT_G_MASK ( 1 << 6)
`define SEGMENT_DOT_MASK ( 1 << 7)
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

//definicja stanow dla maszyny stanow
enum {
    SEGMENT_A0, SEGMENT_B0, SEGMENT_C0, SEGMENT_D0,
    SEGMENT_D1, SEGMENT_E1, SEGMENT_F1, SEGMENT_A1
} current_state = SEGMENT_A0;

// definicja kierunku poruszania sie segmentu
enum {LEFT, RIGHT} dir = LEFT;

// w zaleznosci od kierunku, w kazdym cyklu spowolnionego zegara
// poruszamy sie do przodu lub wstecz po stanach
always@ (posedge divided_clk)
begin
    if (dir == RIGHT)
        current_state <= current_state.next();
    else
        current_state <= current_state.prev();
end

// przypisanie wyjsciastanow wzgledem obecnego wyjscia przy negatywnym zboczu zegara
// w ten sposob zmiana stanu nastapi przy pozytywnym zboczu zegara,
// a zmiana wyjscia wzgledem nowego stanu przy opadajacym zboczu zegara
always@ (posedge divided_clk)
begin
    case(current_state)
        SEGMENT_A0:
            begin
                display[1] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[0] <= `SET_ACTIVE(`SEGMENT_A_MASK);
            end
        SEGMENT_B0:
            begin
                display[1] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[0] <= `SET_ACTIVE(`SEGMENT_B_MASK);
            end
        SEGMENT_C0:
            begin
                display[1] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[0] <= `SET_ACTIVE(`SEGMENT_C_MASK);
            end
        SEGMENT_D0:
            begin
                display[1] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[0] <= `SET_ACTIVE(`SEGMENT_D_MASK);
            end
            
         SEGMENT_D1:
            begin
                display[0] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[1] <= `SET_ACTIVE(`SEGMENT_D_MASK);
            end
        SEGMENT_E1:
            begin
                display[0] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[1] <= `SET_ACTIVE(`SEGMENT_E_MASK);
            end
        SEGMENT_F1:
            begin
                display[0] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[1] <= `SET_ACTIVE(`SEGMENT_F_MASK);
            end
        SEGMENT_A1:
            begin
                display[0] <= `SET_ACTIVE(`DISPLAY_CLEAR);
                display[1] <= `SET_ACTIVE(`SEGMENT_A_MASK);
            end
    endcase
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
