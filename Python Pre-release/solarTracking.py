from GridClass import Grid
import time

grid = Grid() # create a grid object and register all ReviGrid devices
solar = grid.SolarModuleArr[0] # access the solar tracker object

# function that retrieves the current kW value from the solar tracker
def solarGetVal():
    currVal = solar.call("getVal")
    currVal = float(currVal)
    print(currVal)
    return currVal

# function that retrieves the current position of the solar panel
def solarGetPos(): 
    currVal = float(solar.call("getPos"))
    print("Pos: ", currVal)
    return currVal

# function that moves the solar panel clockwise or counterclockwise
def movePanel(cmdName):
    solar.call(cmdName, 30)
    time.sleep(1.5)

solar.call("init") # initialize the module
time.sleep(8)

while(True):
    prevVal = solarGetVal() 
    movePanel("moveCW")
    currVal = solarGetVal()
    currPos = solarGetPos()
    if currVal > prevVal:
        # keep moving in clockwise when current value
        #   is greater than previous value.
        # 440 is the max position value for solar moudle
        while ((currVal > prevVal) and (currPos < 440)):
            movePanel("moveCW")
            prevVal = currVal
            currVal = solarGetVal()
            currPos = solarGetPos()
        movePanel("moveCCW")
    else:
        prevVal = currVal
        movePanel("moveCCW")
        currVal = solarGetVal()
        currPos = solarGetPos()
        # keep moving in counterclockwise when current value
        # is greater than previous value
        while ((currVal > prevVal) and (currPos > 20)):
            movePanel("moveCCW")
            prevVal = currVal
            currVal = solarGetVal()
            currPos = solarGetPos()
        movePanel("moveCW")
        

        