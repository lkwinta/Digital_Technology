import logicmin

direction_controller_tt = logicmin.TT(6, 4)
floor_controller_tt = logicmin.TT(5, 4)
door_controller_tt = logicmin.TT(5, 4)
elevator_motor_mux_tt = logicmin.TT(4, 2)

###############################################################################
# direction_controller #
###############################################################################

f = open("direction_controller_test_data.dp", "w")
f.write("Data:\n")
reset_sr = 1
f.write(hex(int(str(bin(1)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
f.write(hex(int(str(bin(1)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
f.write(hex(int(str(bin(0)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
data_count = 3
for i in range(64):
    permutation = bin(i).removeprefix("0b").rjust(6, '0')
    
    variables = {
        'F1': int(permutation[0]),
        'F2': int(permutation[1]),
        'F3': int(permutation[2]),
        'S1': int(permutation[3]),
        'S2': int(permutation[4]),
        'S3': int(permutation[5])
    }

    above = '0'
    below = '0'
    at_stop = '0'
    active = '0'

    if variables['F1'] and (variables['S2'] or variables['S3']):
        above = '1'
    
    elif variables['F2'] and variables['S1']:
        below = '1'

    elif variables['F2'] and variables['S3']:
        above = '1'
    
    elif variables['F3']and (variables['S1'] or variables['S2']):
        below = '1'

    if (variables['F1'] and variables['S1']) or (variables['F2'] and variables['S2']) or (variables['F3'] and variables['S3']):
        at_stop = '1'

    if variables['S1'] or variables['S2'] or variables['S3']:
        active = '1'

    direction_controller_tt.add(permutation, [above, below, at_stop, active])

    F1_b = str(bin(variables['F1'])).removeprefix("0b")
    F2_b = str(bin(variables['F2'])).removeprefix("0b")
    F3_b = str(bin(variables['F3'])).removeprefix("0b")
    S1_b = str(bin(variables['S1'])).removeprefix("0b")
    S2_b = str(bin(variables['S2'])).removeprefix("0b")
    S3_b = str(bin(variables['S3'])).removeprefix("0b")
    above_b = str(bin(int(above))).removeprefix("0b")
    below_b = str(bin(int(below))).removeprefix("0b")
    at_stop_b = str(bin(int(at_stop))).removeprefix("0b")
    active_b = str(bin(int(active))).removeprefix("0b")

    hex_val = hex(int(active_b + at_stop + below_b + above_b + S3_b + S2_b + S1_b + F3_b + F2_b + F1_b, 2)).removeprefix("0x").rjust(8, '0')
    f.write(hex_val + "\n")
    data_count += 1

f.write("Initial:\n")
f.write("0000\n")
f.write("Final:\n")
f.write(str(hex(data_count)).capitalize().removeprefix("0x").rjust(4, '0'))

f.close()

###############################################################################
# floor_controller #
###############################################################################

f = open("floor_controller_test_data.dp", "w")
f.write("Data:\n")
reset_sr = 1
f.write(hex(int(str(bin(1)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
f.write(hex(int(str(bin(1)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
f.write(hex(int(str(bin(0)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
data_count = 3
up = 0
dn = 0
for i in range(32):

    permutation = bin(i).removeprefix("0b").rjust(5, '0')
    
    variables = {
        'DOOR_OPEN': int(permutation[0]),
        'ACTIVE': int(permutation[1]),
        'BELOW': int(permutation[2]),
        'ABOVE': int(permutation[3]),
        'AT_STOP': int(permutation[4])
    }

    set_up = '0'
    reset_up = '0'
    set_dn = '0'
    reset_dn = '0'

    if not variables['ABOVE'] and not variables['BELOW'] and variables['AT_STOP']:
        set_up = '0'
        reset_up = '1'
        set_dn = '0'
        reset_dn = '1'
        up = dn = 0

    elif variables['ACTIVE'] and variables['BELOW'] and not variables['DOOR_OPEN']:
        set_up = '0'
        reset_up = '0'
        set_dn = '1'
        reset_dn = '0'
        dn = 1

    elif variables['ACTIVE'] and variables['ABOVE'] and not variables['DOOR_OPEN']:
        set_up = '1'
        reset_up = '0'
        set_dn = '0'
        reset_dn = '0'
        up = 1

    floor_controller_tt.add(permutation, [set_up, reset_up, set_dn, reset_dn])

    door_open_b = str(bin(variables['DOOR_OPEN'])).removeprefix("0b")
    active_b = str(bin(variables['ACTIVE'])).removeprefix("0b")
    below_b = str(bin(variables['BELOW'])).removeprefix("0b")
    above_b = str(bin(variables['ABOVE'])).removeprefix("0b")
    at_stop_b = str(bin(variables['AT_STOP'])).removeprefix("0b")
    up_b = str(bin(up)).removeprefix("0b")
    dn_b = str(bin(dn)).removeprefix("0b")
    # set_up = str(bin(int(set_up))).removeprefix("0b")
    # reset_up = str(bin(int(reset_dn))).removeprefix("0b")
    # set_dn = str(bin(int(set_dn))).removeprefix("0b")
    # reset_dn = str(bin(int(reset_dn))).removeprefix("0b")

    hex_val = hex(int(dn_b + up_b + door_open_b + active_b + at_stop_b + below_b + above_b, 2)).removeprefix("0x").rjust(8, '0')
    f.write(hex_val + "\n")
    data_count += 1

f.write("Initial:\n")
f.write("0000\n")
f.write("Final:\n")
f.write(str(hex(data_count)).capitalize().removeprefix("0x").rjust(4, '0'))

f.close()

###############################################################################
# door_controller #
###############################################################################

f = open("door_controller_test_data.dp", "w")
f.write("Data:\n")
reset_sr = 1
f.write(hex(int(str(bin(1)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
f.write(hex(int(str(bin(1)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
f.write(hex(int(str(bin(0)).removeprefix("0b").rjust(4, '0'), 2)).removeprefix("0x").rjust(8, '0') + "\n")
data_count = 3
for i in range(32):
    permutation = bin(i).removeprefix("0b").rjust(5, '0')
    
    variables = {
        'CLOSE_DOOR_PB': int(permutation[0]),
        'AT_STOP': int(permutation[1]),
        'F1': int(permutation[2]),
        'F2': int(permutation[3]),
        'F3': int(permutation[4])
    }

    r1 = '0'
    r2 = '0'
    r3 = '0'
    door_open = '0'

    if variables['AT_STOP']: door_open = '1'
    if variables['AT_STOP'] and variables['CLOSE_DOOR_PB']:
        if variables['F1']: r1 = '1'
        if variables['F2']: r2 = '1'
        if variables['F3']: r3 = '1'

    door_controller_tt.add(permutation, [r1, r2, r3, door_open])

    close_door_pb_b = str(bin(variables['CLOSE_DOOR_PB'])).removeprefix("0b")
    at_stop_b = str(bin(variables['AT_STOP'])).removeprefix("0b")
    F1_b = str(bin(variables['F1'])).removeprefix("0b")
    F2_b = str(bin(variables['F2'])).removeprefix("0b")
    F3_b = str(bin(variables['F3'])).removeprefix("0b")
    r1_b = str(bin(int(r1))).removeprefix("0b")
    r2_b = str(bin(int(r2))).removeprefix("0b")
    r3_b = str(bin(int(r3))).removeprefix("0b")
    door_open_b = str(bin(int(door_open))).removeprefix("0b")

    hex_val = hex(int(door_open_b + r3_b + r2_b + r1_b + close_door_pb_b + at_stop_b + F3_b + F2_b + F1_b, 2)).removeprefix("0x").rjust(8, '0')
    f.write(hex_val + "\n")
    data_count += 1

f.write("Initial:\n")
f.write("0000\n")
f.write("Final:\n")
f.write(str(hex(data_count)).capitalize().removeprefix("0x").rjust(4, '0'))

f.close()

for i in range(16):
    permutation = bin(i).removeprefix("0b").rjust(4, '0')
    
    a1 = '1'
    b1 = '1'

    if i == 0:
        a1 = '0'
        b1 = '0'
    elif i == 8:
        a1 = '1'
        b1 = '0'
    elif i == 15:
        a1 = '0'
        b1 = '1'


    elevator_motor_mux_tt.add(permutation, [a1, b1])

print("--------------------------------direction_controller_tt")
sols = direction_controller_tt.solve()
print(sols.printN(xnames=['F1', 'F2', 'F3', 'S1', 'S2', 'S3'],ynames=['ABOVE','BELOW', 'AT_STOP', 'ACTIVE']))

print("--------------------------------floor_controller_tt")
sols = floor_controller_tt.solve()
print(sols.printN(xnames=['DOOR_OPEN', 'ACTIVE', 'BELOW', 'ABOVE', 'AT_STOP'],ynames=['SET_UP', 'RESET_UP','SET_DN', 'RESET_DN']))

print("--------------------------------door_controller_tt")
sols = door_controller_tt.solve()
print(sols.printN(xnames=['CLOSE_DOOR_PB', 'AT_STOP', 'F1', 'F2', 'F3'],ynames=['R1','R2', 'R3', 'DOOR_OPEN']))

print("--------------------------------elevator_motor_tt")
sols = elevator_motor_mux_tt.solve()
print(sols.printN(xnames=['QD', 'QC', 'QB', 'QA'],ynames=['1A', '1B']))