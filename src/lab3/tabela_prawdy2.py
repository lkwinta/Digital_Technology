import logicmin

direction_controller_tt = logicmin.TT(6, 4)
floor_controller_tt = logicmin.TT(5, 4)
door_controller_tt = logicmin.TT(5, 4)
elevator_motor_mux_tt = logicmin.TT(4, 2)

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

    elif variables['ACTIVE'] and variables['BELOW'] and not variables['DOOR_OPEN']:
        set_up = '0'
        reset_up = '0'
        set_dn = '1'
        reset_dn = '0'

    elif variables['ACTIVE'] and variables['ABOVE'] and not variables['DOOR_OPEN']:
        set_up = '1'
        reset_up = '0'
        set_dn = '0'
        reset_dn = '0'

    floor_controller_tt.add(permutation, [set_up, reset_up, set_dn, reset_dn])

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