import logicmin


automata_transitions = {
    0: {'F1': 1, 'F2': 2, 'F3': 3, 'S1': 0, 'S2': 0, 'S3': 0},
    1: {'F1': 1, 'F2': 1, 'F3': 1, 'S1': 1, 'S2': 4, 'S3': 4},

    2: {'F1': 2, 'F2': 2, 'F3': 2, 'S1': 5, 'S2': 2, 'S3': 4},
    3: {'F1': 3, 'F2': 3, 'F3': 3, 'S1': 5, 'S2': 5, 'S3': 3},
    4: {'F1': 4, 'F2': 2, 'F3': 3, 'S1': 4, 'S2': 4, 'S3': 4},
    5: {'F1': 1, 'F2': 2, 'F3': 5, 'S1': 5, 'S2': 5, 'S3': 5},
    6: {'F1': 0, 'F2': 0, 'F3': 0, 'S1': 0, 'S2': 0, 'S3': 0},
    7: {'F1': 0, 'F2': 0, 'F3': 0, 'S1': 0, 'S2': 0, 'S3': 0},
}

automata_output = {
    0: {'UP': '0', 'DN': '0'},
    1: {'UP': '0', 'DN': '0'},
    2: {'UP': '0', 'DN': '0'},
    3: {'UP': '0', 'DN': '0'},
    4: {'UP': '1', 'DN': '0'},
    5: {'UP': '0', 'DN': '1'},
}

truth_table = logicmin.TT(9, 3)

for i in range(0, 512):
    permutation = bin(i).removeprefix("0b").rjust(9, '0')

    state = permutation[0:3]
    int_state = int(state, 2)
    in_variables = {
        'F1': permutation[3],
        'F2': permutation[4],
        'F3': permutation[5],
        'S1': permutation[6],
        'S2': permutation[7],
        'S3': permutation[8]
    }

    transition = automata_transitions[int_state]
    new_state = int_state
    for var, trans_state in transition.items():
        if trans_state != int_state and in_variables[var] == '1':
            new_state = trans_state
    
    if int_state == 6 or int_state == 7:
        new_state = 0

    truth_table.add(permutation, bin(new_state).removeprefix("0b").rjust(3, '0'))

    print(f"state: {int_state}, F1: {in_variables['F1']}, F2: {in_variables['F2']}, F3: {in_variables['F3']}, S1: {in_variables['S1']}, S2: {in_variables['S2']}, S3: {in_variables['S3']} -> {new_state}")

sols = truth_table.solve()
print(sols.printN(xnames=['Q2','Q1','Q0', 'F1', 'F2', 'F3', 'S1', 'S2', 'S3'],ynames=['D2','D1', 'D0'], info=True))