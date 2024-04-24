from enum import Enum
import time 

class ElevatorState(Enum):
    FLOOR_1_DOOR_CLOSED = 0
    FLOOR_1_DOOR_OPEN   = 1

    FLOOR_2_DOOR_CLOSED = 2
    FLOOR_2_DOOR_OPEN = 3

    FLOOR_3_DOOR_CLOSED = 4
    FLOOR_3_DOOR_OPEN = 5

    GOING_UP = 6
    GOING_DOWN = 7

current_state = ElevatorState.FLOOR_1_DOOR_OPEN

door_button_floor_1 = 0
door_button_floor_2 = 0
door_button_floor_3 = 0

door_close_button = 0
door_should_close = 0

while True:
    match current_state:
        case ElevatorState.FLOOR_1_DOOR_CLOSED:
            if door_button_floor_1 == 1:
                door_button_floor_1 = 0
                current_state = ElevatorState.FLOOR_1_DOOR_OPEN
            elif door_button_floor_2 == 1 or door_button_floor_3 == 1:
                current_state = ElevatorState.GOING_UP
        
        case ElevatorState.FLOOR_1_DOOR_OPEN:
            if door_close_button == 1 or door_should_close == 1:
                current_state = ElevatorState.FLOOR_1_DOOR_CLOSED
                door_close_button = 0
                door_should_close = 0

        case ElevatorState.FLOOR_2_DOOR_CLOSED:
            if door_button_floor_2 == 1:
                door_button_floor_2 = 0
                current_state = ElevatorState.FLOOR_2_DOOR_OPEN
            elif door_button_floor_3 == 1:
                current_state = ElevatorState.GOING_UP
            elif door_button_floor_1 == 1:
                current_state = ElevatorState.GOING_DOWN

        case ElevatorState.FLOOR_2_DOOR_OPEN:
            if door_close_button == 1 or door_should_close == 1:
                current_state = ElevatorState.FLOOR_2_DOOR_CLOSED
                door_close_button = 0
                door_should_close = 0

        case ElevatorState.FLOOR_3_DOOR_CLOSED:
            if door_button_floor_3 == 1:
                door_button_floor_3 = 0
                current_state = ElevatorState.FLOOR_3_DOOR_OPEN
            elif door_button_floor_2 == 1 or door_button_floor_1 == 1:
                current_state = ElevatorState.GOING_DOWN

        case ElevatorState.FLOOR_3_DOOR_OPEN:
            if door_close_button == 1 or door_should_close == 1:
                current_state = ElevatorState.FLOOR_3_DOOR_CLOSED
                door_close_button = 0
                door_should_close = 0

        case ElevatorState.GOING_UP:
            time.sleep(2)
            if door_button_floor_2 == 1:
                current_state = ElevatorState.FLOOR_2_DOOR_CLOSED
            elif door_button_floor_3 == 1:
                current_state = ElevatorState.FLOOR_3_DOOR_CLOSED

        case ElevatorState.GOING_DOWN:
            time.sleep(2)
            if door_button_floor_2 == 1:
                current_state = ElevatorState.FLOOR_2_DOOR_CLOSED
            elif door_button_floor_1 == 1:
                current_state = ElevatorState.FLOOR_1_DOOR_CLOSED

    if (current_state == ElevatorState.FLOOR_1_DOOR_OPEN or 
        current_state == ElevatorState.FLOOR_2_DOOR_OPEN or 
        current_state == ElevatorState.FLOOR_3_DOOR_OPEN):
        time.sleep(2)
        door_should_close = 1

