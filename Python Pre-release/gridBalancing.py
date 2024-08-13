from GridClass import Grid
import time

grid = Grid()
time.sleep(5)
house = grid.HouseModuleArr[0]
solar = grid.SolarModuleArr[0]
gen = grid.GeneratorModuleArr[0]
fan = grid.FanModuleArr[0]
wind = grid.WindModuleArr[0]

house.call("lightAll")
time.sleep(0.5)
gen.call("trackOn")
time.sleep(0.5)

while True:
    receivedVal = house.call("getAll")
    loadVal1 = float(receivedVal[1])

    receivedVal = solar.call("getAll")
    loadVal2 = float(receivedVal[1])
    loadVal = loadVal1 + loadVal2

    receivedVal = wind.call("getAll")
    loadVal3 = float(receivedVal[1])
    loadVal = loadVal + loadVal3

    loadVal = loadVal * (-1)
    gen.call("setLoad", loadVal)
    receivedVal = gen.call("getAll")
    loadVal4 = float(receivedVal[1])

    #print(loadVal1, loadVal2, loadVal3, loadVal4)