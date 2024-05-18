###
### Plik zawieraj¹cy informacje wi¹¿¹ce fizyczne wyprowadzenia uk³adu
### z nazwami u¿ywanymi w kodzie
###

## Przypisanie zegara systemowego o czêstotliwoœci 100Mhz (okres 10.00 ns)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk }];       #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## Przypisanie przyciskow których bêdziemy u¿ywaæ 
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports {btn_freq_up}];  #IO_L4N_T0_D05_14 Sch=btnu
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports {btn_freq_dn}];  #IO_L9N_T1_DQS_D13_14 Sch=btnd
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports {btn_dir}];      #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports {len_up}];      #IO_L9P_T1_DQS_14 Sch=btnc
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports {len_dn}];      #IO_L9P_T1_DQS_14 Sch=btnc

## Przypisanie wyprowadzen do wyœwietlacza 7 segmentowego - jako, ¿e segmenty s¹ aktywne w stanie niskim
## musimy wysterowaæ wszytkie nawet nieu¿ywane segmenty aby ustawiæ stan wysoki na segnentach które nie powinny
## siê œwieciæ

# Segment A
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[0] }]; #IO_L24N_T3_A00_D16_14 Sch=ca
# Segment B
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[1] }]; #IO_25_14 Sch=cb
# Segment C
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[2] }]; #IO_25_15 Sch=cc
# Segment D
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[3] }]; #IO_L17P_T2_A26_15 Sch=cd
# Segment E
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[4] }]; #IO_L13P_T2_MRCC_14 Sch=ce
# Segment F
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[5] }]; #IO_L19P_T3_A10_D26_14 Sch=cf
# Segment G
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[6] }]; #IO_L4P_T0_D04_14 Sch=cg
# Kropka
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { sseg_cathodes[7] }]; #IO_L19N_T3_A21_VREF_15 Sch=dp

# Aktywacja 1 wystwietlacz 1 (1 od prawej)
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[0] }]; #IO_L23P_T3_FOE_B_15 Sch=an[0]
# Aktywacja 2 wyswietlacza 
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[1] }]; #IO_L23N_T3_FWE_B_15 Sch=an[1]
# Aktywacja 3 wyswietlacza 
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[2] }]; #IO_L24P_T3_A01_D17_14 Sch=an[2]
# Aktywacja 4 wyswietlacza 
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[3] }]; #IO_L19P_T3_A22_15 Sch=an[3]
# Aktywacja 5 wyswietlacza 
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[4] }]; #IO_L8N_T1_D12_14 Sch=an[4]
# Aktywacja 6 wyswietlacza 
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[5] }]; #IO_L14P_T2_SRCC_14 Sch=an[5]
# Aktywacja 7 wyswietlacza 
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[6] }]; #IO_L23P_T3_35 Sch=an[6]
# Aktywacja 8 wyswietlacza 
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { sseg_anodes[7] }]; #IO_L23N_T3_A02_D18_14 Sch=an[7]

## Przypisanie leda wizualizuj¹cego obecn¹ czêœtotliwoœæ spowolnionego zegara
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { clk_led ] }]; #IO_L18P_T2_A24_15 Sch=led[0]


