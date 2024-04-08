f = open("setter_test_data.dp", "w")
f.write("Data:\n")

###############################################################################
# |SR_RESET|S3|R3|S2|R2|S1|R1|S0|R0|IN3|IN2|IN1|IN0|EN|Q3|Q2|Q1|Q0| #
###############################################################################

class TestOutput: 
    def __init__(self):
        self.q_in_data = 0
        self.en = 0
        self.in_data = 0
        
        self.s0 = 0
        self.r0 = 0
        self.s1 = 0
        self.r1 = 0
        self.s2 = 0
        self.r2 = 0
        self.s3 = 0
        self.r3 = 0

        self.reset_sr = 0

    def to_bin_string(self):
        q_input_binary = str(bin(self.q_in_data)).removeprefix("0b").rjust(4, '0')
        en_binary = str(bin(self.en)).removeprefix("0b")
        input_binary = str(bin(self.in_data)).removeprefix("0b").rjust(4, '0')
        
        s0_binary = str(bin(self.s0)).removeprefix("0b")
        r0_binary = str(bin(self.r0)).removeprefix("0b")
        s1_binary = str(bin(self.s1)).removeprefix("0b")
        r1_binary = str(bin(self.r1)).removeprefix("0b")
        s2_binary = str(bin(self.s2)).removeprefix("0b")
        r2_binary = str(bin(self.r2)).removeprefix("0b")
        s3_binary = str(bin(self.s3)).removeprefix("0b")
        r3_binary = str(bin(self.r3)).removeprefix("0b")
        
        reset_sr_binary = str(bin(self.reset_sr)).removeprefix("0b")

        return (reset_sr_binary + 
                r3_binary + 
                s3_binary + 
                r2_binary + 
                s2_binary + 
                r1_binary + 
                s1_binary + 
                r0_binary + 
                s0_binary + 
                input_binary + 
                en_binary +
                q_input_binary)
    

    def to_hex_string(self, pad):
        hex_val = hex(int(self.to_bin_string(), 2))
        return hex_val.removeprefix("0x").rjust(pad, '0')


####################################
# Test cycle to reset JK flip flop #
####################################

reset_to = TestOutput()
reset_to.reset_sr = 1
f.write(reset_to.to_hex_string(8) + "\n")
f.write(reset_to.to_hex_string(8) + "\n")
reset_to.reset_sr = 0
f.write(reset_to.to_hex_string(8) + "\n")
data_count = 3

to = TestOutput()
for input in range(15, -1, -1):
    for q_input in range(15, -1, -1):
        to.in_data = input
        to.q_input = q_input
        

        f.write(to.to_hex_string(8) + "\n")
        data_count += 1

to.en = 1
for input in range(15, -1, -1):
    for q_input in range(15, -1, -1):
        to.in_data = input
        to.q_in_data = q_input
        
        in_bin = bin(input).removeprefix("0b").rjust(4, '0')
        q_in_bin = bin(q_input).removeprefix("0b").rjust(4, '0')

        to.s0 = 1 if in_bin[3] == "1" and q_in_bin[3] == "0" else 0
        to.r0 = 1 if in_bin[3] == "0" and q_in_bin[3] == "1" else 0

        to.s1 = 1 if in_bin[2] == "1" and q_in_bin[2] == "0" else 0
        to.r1 = 1 if in_bin[2] == "0" and q_in_bin[2] == "1" else 0

        to.s2 = 1 if in_bin[1] == "1" and q_in_bin[1] == "0" else 0
        to.r2 = 1 if in_bin[1] == "0" and q_in_bin[1] == "1" else 0

        to.s3 = 1 if in_bin[0] == "1" and q_in_bin[0] == "0" else 0
        to.r3 = 1 if in_bin[0] == "0" and q_in_bin[0] == "1" else 0

        f.write(to.to_hex_string(8) + "\n")
        data_count += 1


f.write("Initial:\n")
f.write("0000\n")
f.write("Final:\n")
f.write(str(hex(data_count)).capitalize().removeprefix("0x").rjust(4, '0'))

f.close()