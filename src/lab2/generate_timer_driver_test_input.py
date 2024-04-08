f = open("driver_test_data.dp", "w")
f.write("Data:\n")

###############################################################################
# |SR_RESET|EQ0|T3|T2|T1|T0|EN|Q3|Q2|Q1|Q0| #
###############################################################################

class TestOutput: 
    def __init__(self):
        self.in_data = 0
        self.en = 0
        self.output_data = 0
        self.eq0 = 0
        self.reset_sr = 0

    def to_bin_string(self):
        input_binary = str(bin(self.in_data)).removeprefix("0b").rjust(4, '0')
        en_binary = str(bin(self.en)).removeprefix("0b")
        output_binary = str(bin(self.output_data)).removeprefix("0b").rjust(4, '0')
        eq0_binary = str(bin(self.eq0)).removeprefix("0b")
        reset_sr_binary = str(bin(self.reset_sr)).removeprefix("0b")

        return reset_sr_binary + eq0_binary + output_binary + en_binary + input_binary
    

    def to_hex_string(self, pad):
        hex_val = hex(int(self.to_bin_string(), 2))
        return hex_val.removeprefix("0x").rjust(pad, '0')


####################################
# Test cycle to reset JK flip flop #
####################################

reset_to = TestOutput()
reset_to.eq0 = 1
reset_to.reset_sr = 1
f.write(reset_to.to_hex_string(8) + "\n")
f.write(reset_to.to_hex_string(8) + "\n")
reset_to.reset_sr = 0
f.write(reset_to.to_hex_string(8) + "\n")
data_count = 3

to = TestOutput()
for input in range(15, -1, -1):
    to.in_data = input
    to.eq0 = 1 if input == 0 else 0

    f.write(to.to_hex_string(8) + "\n")
    data_count += 1

to.en = 1
for input in range(15, -1, -1):
    to.in_data = input
    to.output_data = input ^ 15 if input == 0 else input ^ (input - 1)
    to.eq0 = 1 if input == 0 else 0

    f.write(to.to_hex_string(8) + "\n")
    data_count += 1


f.write("Initial:\n")
f.write("0000\n")
f.write("Final:\n")
f.write(str(hex(data_count)).capitalize().removeprefix("0x").rjust(4, '0'))

f.close()