# - The cmd class is used in the module class to organize the commands that can be
#   executed by each module
# - Cmd is short for command

class Cmd:
    def __init_(self):
        # name of command
        self.cmdName = None # string
        # number of arguments the command needs from the user before sending out to the module
        self.numOfArgsFromUser = None # int
        # number of arguments the microcontroller (module) will send back after sending out the command
        self.numOfArgsFromMC = None # int
        # description of each argument the microcontroller(module) returns after sending out the command
        self.MCOutputPrompts = None # string array
        # prompt for each user input
        self.userInputPrompts = None # string array
        # the maximum value of each user input
        self.userInputMaxRange = None # int array or "n/a"
        # the minimum value of each user input
        self.userInputMinRange = None # int array or "n/a"
        # a description of the command
        self.cmdDescription = None # string

    def __str__(self):
        return f"cmdName: {self.cmdName} \
                 \nnumOfArgsFromUser: {self.numOfArgsFromUser} \
                 \nnumOfArgsFromMC: {self.numOfArgsFromMC} \
                 \nMCOutputPrompts: {self.MCOutputPrompts} \
                 \nuserInputPrompts: {self.userInputPrompts} \
                 \nuserInputMaxRange: {self.userInputMaxRange} \
                 \nuserInputMinRange: {self.userInputMinRange} \
                 \ncmdDescription: {self.cmdDescription} "



    def setCmdName(self, name):
        self.cmdName = str(name)

    def setNumOfArgsFromUser(self, numOfArgs):
        if numOfArgs == "n/a":
            self.numOfArgsFromUser = 0
        else:
       
            self.numOfArgsFromUser = int(numOfArgs)

    def setNumOfArgsFromMC(self, numOfArgs):
        if numOfArgs == "n/a":
            self.numOfArgsFromMC = 0
        else:
    
            self.numOfArgsFromMC = int(numOfArgs)

    def setMCOutputPrompts(self, prompts):
        promptList = prompts.split(';') # create string array using the seperator, ';'
        self.MCOutputPrompts = promptList

    def setUserInputPrompts(self, prompts):
        promptList = prompts.split(';') # create string array using the seperator, ';'
        self.userInputPrompts = promptList

    def setUserInputMaxRange(self, maxVals):
        if maxVals == 'n/a': # store 'n/a' if value is invalid
            self.userInputMaxRange = maxVals
            return

        maxValListStr = maxVals.split(';') # create string array using the seperator, ';'
        maxValListInt = []
        for idx, maxVal in enumerate(maxValListStr):
          
            maxValListInt.append(int(maxVal)) # convert each string into int
        self.userInputMaxRange = maxValListInt

    def setUserInputMinRange(self, minVals):
        if minVals == 'n/a': # store 'n/a' if value is invalid
            self.userInputMinRange = minVals
            return

        minValListStr = minVals.split(';') # create string array using the seperator, ';'
        minValListInt = []
        for idx, minVal in enumerate(minValListStr):
     
            minValListInt.append(int(minVal)) # convert each string into int
        self.userInputMinRange = minValListInt

    def setCmdDescription(self, description):
        self.cmdDescription = str(description)

    def checkCmdValidity(self):
   
        pass
