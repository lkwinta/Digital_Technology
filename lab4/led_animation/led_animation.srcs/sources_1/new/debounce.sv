`timescale 1ns / 1ps

// modu� filtruj�cy przyciski
module debounce #(parameter DEBOUNCE_TIME = 1000 * 100) (
    input wire clk,
    input wire button_physical,
    
    output reg button_active
);

// ustawiamy pocz�tkowy stan przycisku na 0
initial
    button_active = 0;

integer btn_clock_cycles_counter = 0;

// zliczamy zadan� ilo�� cykli zegara 
// je�li w kt�rym� cyklu przycisk b�dzie w stanie niskimi,
// resetujemy licznik warto�ci
always@ (posedge clk)
begin
   if (button_physical == 1)
       begin
            btn_clock_cycles_counter <= btn_clock_cycles_counter + 1;
            if (btn_clock_cycles_counter >= DEBOUNCE_TIME) 
                button_active <= 1;
       end
    else 
        begin
            btn_clock_cycles_counter <= 0;
            button_active <= 0;
        end
        
end

endmodule
