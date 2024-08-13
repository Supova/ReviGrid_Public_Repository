# - The Module class is used in the grid class to organize the modules that can be
#   included in a grid object
# - The module class includes 1 superclass, "Module",
#   and 5 subclasses: FanModule, HouseModule, SolarModule, WindModule, and GeneratorModule

import pandas as pd # pip install pandas
from CmdClass import Cmd
import time

class Module():
    def __init__(self, moduleType, port):
        # module name set by the user
        self.name = None
        # module ID returned from the "*ID?" command
        self.moduleType = str(moduleType)
        # an array of command objects
        self.cmdObjArr = []
        # serial port obj used by the module
        self.serialPortObj = port
        # name of the Excel file that stores all information for each command
        self.cmdExcelFileName = "ReviGridCmds.xlsx"

        self.setUpCmdObjArr() # initialize self.cmdObjArr
        self.writeSP("init") # initialize the module

    def __str__(self):
        return f"name: {self.name} \
                 \nmoduleType: {self.moduleType} \
                 \nserialPortObj: {self.serialPortObj}"

    def printCmdObjArr(self):
        for cmd in self.cmdObjArr:
            print("\n")
            print(cmd)

    # initialize self.cmdObjArr
    def setUpCmdObjArr(self):
        # read command information from the Excel file, the sheetname is the self.moduleType
        cmdInfoSheet = pd.read_excel(self.cmdExcelFileName, sheet_name = self.moduleType, dtype = str, keep_default_na = False)
        # get a list of available commands from the module
        self.writeSP("getCommands")
        # read the first command
        currCmd = self.readSP()
        while currCmd != "eoc": # while the current command is not the last command
            #print(currCmd)
            numOfArgsFromMC = 0
            numOfArgsFromUser = 0

            # - The following if-else statement extracts the command name, numOfArgsFromUser, and numOfArgsFromMC
            # - "<" means number of arguments the microcontroller (module) will send back after sending out the command
            # - ">" means number of arguments the command needs from the user before sending out to the module
            if ('<' in currCmd) and ('>' in currCmd): # if the command contains both special characters
                specialIndex1 = currCmd.index('<')
                specialIndex2 = currCmd.index('>')
                if specialIndex1 < specialIndex2: # if numOfArgsFromMC is before numOfArgsFromUser
                    numOfArgsFromMC = currCmd[(specialIndex1 + 1):specialIndex2]
                    numOfArgsFromUser = currCmd[(specialIndex2 + 1):]
                    cmdName = currCmd[:specialIndex1]
                else: # numOfArgsFromUser is before numOfArgsFromMC
                    numOfArgsFromUser = currCmd[(specialIndex2 + 1):specialIndex1]
                    numOfArgsFromMC = currCmd[(specialIndex1 + 1):]
                    cmdName = currCmd[:specialIndex2]
            elif '<' in currCmd: # if the command only contains numOfArgsFromMC
                specialIndex = currCmd.index('<')
                numOfArgsFromMC = currCmd[(specialIndex + 1):]
                cmdName = currCmd[:specialIndex]
            elif '>' in currCmd: # if the command only contains numOfArgsFromUser
                specialIndex = currCmd.index('>')
                numOfArgsFromUser = currCmd[(specialIndex + 1):]
                cmdName = currCmd[:specialIndex]
            else: # the command doesn't contain special character
                cmdName = currCmd

            numOfArgsFromUser = int(numOfArgsFromUser)
            numOfArgsFromMC = int(numOfArgsFromMC)

            currCmdObj = Cmd() # create a command object
            cmdRow = self.getRow(cmdInfoSheet, cmdName) # retrieve command information from the Excel file
            if cmdRow is None: # if command information is not found in the table
                currCmdObj.setCmdName(cmdName)
                currCmdObj.setNumOfArgsFromUser(numOfArgsFromUser)
                currCmdObj.setNumOfArgsFromMC(numOfArgsFromMC)
                currCmdObj.setMCOutputPrompts("n/a")
                currCmdObj.setUserInputPrompts("n/a")
                currCmdObj.setUserInputMaxRange("n/a")
                currCmdObj.setUserInputMinRange("n/a")
                currCmdObj.setCmdDescription("n/a")
                pass
            else: # if command information is found in the table
                currCmdObj.setCmdName(cmdName)
                currCmdObj.setNumOfArgsFromUser(numOfArgsFromUser)
                currCmdObj.setNumOfArgsFromMC(numOfArgsFromMC)
                currCmdObj.setMCOutputPrompts(cmdRow["MCOutputPrompts"])
                currCmdObj.setUserInputPrompts(cmdRow["userInputPrompts"])
                currCmdObj.setUserInputMaxRange(cmdRow["userInputMaxRange"])
                currCmdObj.setUserInputMinRange(cmdRow["userInputMinRange"])
                currCmdObj.setCmdDescription(cmdRow["cmdDescription"])

          
            # append the current command object to self.currCmdObj array
            self.cmdObjArr.append(currCmdObj)
            currCmd = self.readSP()
        
        return

    # returns a row from cmd Excel file containing the specified command information
    def getRow(self, dataFrame, cmdName):
        for index, row in dataFrame.iterrows():
            if row["cmdName"] == cmdName:
                return row
        return None

    # returns a command object based on the specified command name
    def getCmd(self, cmdName):
        for cmd in self.cmdObjArr:
            if cmd.cmdName == str(cmdName):
                return cmd
        return None    

    # sends a command out to the module
    # returns the received strings if command takes arguments from the microcontroller(module)
    def call(self, cmdName, *args):
        cmd = self.getCmd(cmdName) # get command object
        if cmd is None: # if command is not found self.cmdObjArr
            raise Exception("Invalid Command: " + cmdName)
            return

        if (cmd.numOfArgsFromUser == 0) and (cmd.numOfArgsFromMC == 0): # if command doesn't have any inputs or outputs
            self.writeSP(cmd.cmdName)
            return

        if not self.isValidInput(cmd, args): # if user input is invalid
            # The self.isValidInput function triggers an error or warning if input is invalid
            return

        fullCmd = str(cmdName) # fullCmd will contain both the command name and the user inputs
        for arg in args:
            fullCmd += " " + str(arg)
        self.writeSP(fullCmd) # send command and arguments out to the module

        if cmd.numOfArgsFromMC != 0: # if the command returns arguments from the microcontroller(module)
            receivedStringArr = []
            for i in range(cmd.numOfArgsFromMC):
                receivedString = self.readSP()
                receivedStringArr.append(receivedString)

            return receivedStringArr
        return

    # checks if user input is valid
    def isValidInput(self, cmd, args):
        if len(args) != cmd.numOfArgsFromUser: # if the number of input doesn't match
            errorMessage = "Invalid number of input for command:" + cmd.cmdName
            errorMessage += "\nExpected: " + str(cmd.numOfArgsFromUser)
            errorMessage += "\nReceived: " + str(len(args))
            raise Exception(errorMessage)
            return False

        # if input range is not specified
        if (cmd.userInputMaxRange == "n/a") and (cmd.setUserInputMinRange == "n/a"):
            return True

        # if input is out of range
        for idx, arg in enumerate(args):
            if cmd.userInputMaxRange != "n/a":
                if cmd.userInputMinRange[idx] > args[idx]:
                  
                    return False

            if cmd.userInputMinRange != "n/a":
                if cmd.userInputMaxRange[idx] < args[idx]:
                  
                    return False

        return True

    # sends a command out to the module
    def writeSP(self, message):
        message = str(message) + "\r\n"
        self.serialPortObj.write(message.encode())

    # reads a value from the microcontroller
    def readSP(self):
        # startTime = time.time()
        # while (self.serialPortObj.in_waiting == 0) and ((time.time() - startTime) < 2):
        #     pass
 
        message = self.serialPortObj.read_until(b'\r\n')
        message = message.decode()
        message = message.strip() # removes leading and trailing newline
        return message

class FanModule(Module):
    pass

class HouseModule(Module):
    pass

class SolarModule(Module):
    pass

class WindModule(Module):
    pass

class GeneratorModule(Module):
    pass
