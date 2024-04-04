f = open("test_data.dp", "w")
f.write("Data:\n")

###############################################################################
# |SR_RESET|ALARM|OUT3|OUT2|OUT1|OUT0|CLK|START|IN3|IN2|IN1|IN0| #
###############################################################################

class TestOutput: 
    def __init__(self):
        self.in_data = 0
        self.start = 0
        self.clk = 0
        self.output_data = 0
        self.alarm = 0
        self.reset_sr = 0

    def to_bin_string(self):
        input_binary = str(bin(self.in_data)).removeprefix("0b").rjust(4, '0')
        start_binary = str(bin(self.start)).removeprefix("0b")
        clk_binary = str(bin(self.clk)).removeprefix("0b")
        output_binary = str(bin(self.output_data)).removeprefix("0b").rjust(4, '0')
        alarm_binary = str(bin(self.alarm)).removeprefix("0b")
        reset_sr_binary = str(bin(self.reset_sr)).removeprefix("0b")

        return reset_sr_binary + alarm_binary + output_binary + clk_binary + start_binary + input_binary
    

    def to_hex_string(self, pad):
        hex_val = hex(int(self.to_bin_string(), 2))
        return hex_val.removeprefix("0x").rjust(pad, '0')


####################################
# Test cycle to reset JK flip flop #
####################################

reset_to = TestOutput()
reset_to.alarm = 1
reset_to.reset_sr = 1
f.write(reset_to.to_hex_string(8) + "\n")
f.write(reset_to.to_hex_string(8) + "\n")
reset_to.reset_sr = 0
f.write(reset_to.to_hex_string(8) + "\n")
data_count = 3

for i in range(16):
    to = TestOutput()
    to.in_data = i
    to.start = 1
    to.output_data = i 
    to.alarm = int(i == 0)

    f.write(to.to_hex_string(8) + "\n")
    data_count += 1

    to.in_data = 0
    to.start = 0
    to.alarm = int(i == 0)

    for k in range(i):
        to.clk = 1
        to.output_data -= 1
        if to.output_data == 0:
            to.alarm = 1

        f.write(to.to_hex_string(8) + "\n")
        data_count += 1

        to.clk = 0

        f.write(to.to_hex_string(8) + "\n")
        data_count += 1

    f.write(to.to_hex_string(8) + "\n")
    data_count += 1

f.write("Initial:\n")
f.write("0000\n")
f.write("Final:\n")
f.write(str(hex(data_count)).capitalize().removeprefix("0x").rjust(4, '0'))

f.close()