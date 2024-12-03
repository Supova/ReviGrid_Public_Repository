from grid import Grid

import time

def get_solar_value_volt(solar: Grid) -> float:
    """Gets the voltage reading"""
    curr_val = float(solar.call("getVal")[0])
    print(curr_val)
    return curr_val


def get_solar_position(solar: Grid) -> float: 
    """Gets position in terms of stepper motor"""
    curr_val = float(solar.call("getPos")[0])
    print(f"Pos: {curr_val}")
    return curr_val


def rotate_panel(solar: Grid, cmd_name: str) -> None:
    """Moves the solar panel clockwise or counterclockwise"""
    # stepper motor
    steps = 30
    solar.call(cmd_name, steps)
    time.sleep(1.5)


def main() -> None:
    grid = Grid() 
    solar = grid.solar_modules[0]  # single solar tracker

    # call() from Module class
    solar.call("init")
    time.sleep(8)

    # stepper motor
    max_pos = 440
    # move CCW, cant continue moving CCW if at home position
    min_pos = 20

    while(True):
        prev_val = get_solar_value_volt(solar) 
        rotate_panel(solar, "moveCW")
        curr_val = get_solar_value_volt(solar)
        curr_pos = get_solar_position(solar)
        
        if curr_val > prev_val:
            # keep moving in clockwise when current value
            #   is greater than previous value.
            while ((curr_val > prev_val) and (curr_pos < max_pos)):
                rotate_panel(solar, "moveCW")
                prev_val = curr_val
                curr_val = get_solar_value_volt(solar)
                curr_pos = get_solar_position(solar)
            rotate_panel(solar, "moveCCW")
        else:
            prev_val = curr_val
            rotate_panel(solar, "moveCCW")
            curr_val = get_solar_value_volt(solar)
            curr_pos = get_solar_position(solar)
            # keep moving in counterclockwise when current value
            # is greater than previous value
            while ((curr_val > prev_val) and (curr_pos > min_pos)):
                rotate_panel(solar, "moveCCW")
                prev_val = curr_val
                curr_val = get_solar_value_volt(solar)
                curr_pos = get_solar_position(solar)
            rotate_panel(solar, "moveCW")
        

if __name__ == "__main__":
    main()
        
