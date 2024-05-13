`timescale 1ns / 1ps

// modu³ dziel¹cy zegar
module clock_divider(
    input integer clock_period,
    input wire clk,
    
    output reg divided_clock
);


initial
    divided_clock <= 0;

longint counter_value = 0;

// zliczamy zadany okres zegara (iloœæ cykli zegara wejœciowego), i gdy 
// doliczymy do konca zmieniamy stan spowolnionego zegara na przeciwny
always@ (posedge clk)
begin 
    if (counter_value >= clock_period) 
        begin
            divided_clock <= ~divided_clock;
            counter_value <= 0;
        end
    else 
        begin
            divided_clock <= divided_clock;
            counter_value <= counter_value + 1;
        end
end

endmodule
