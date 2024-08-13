from GridClass import Grid
import time

grid = Grid()

module = grid.HouseModuleArr[0]

module.call("init")
print("-", "init")
time.sleep(3)
