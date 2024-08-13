# - The Grid class organizes the modules that can be included in a grid object

import serial # python -m pip install pyserial
from serial.tools import list_ports
import numpy as np
import time
from ModuleClass import *

class Grid:
    def __init__(self):
        # an array of fan objects
        self.FanModuleArr = []
        # an array of house objects
        self.HouseModuleArr = []
        # an array of solar tracker objects
        self.SolarModuleArr = []
        # an array of wind turbine objects
        self.WindModuleArr = []
        # an array of power plant objects
        self.GeneratorModuleArr = []
        # an array of the serial port objects of all the module objects
        self.serialPortObjList = []

        self.initModuleArrs() # populates the module arrays

    def __str__(self):
        return f" "

    def initModuleArrs(self):
        comPortsInfoArr = serial.tools.list_ports.comports() # gets a list of available COM ports
        print("\nAvailable COM ports: ")
        for portInfo in comPortsInfoArr:
            print(portInfo.description)

        # filter out the invalid COM ports and register all the valid COM port devices
        self.registerValidComPorts(comPortsInfoArr)

        
    def registerValidComPorts(self, comPortsInfoArr):
        arduinoPortInfos = []
        print("\n")
        for portInfo in comPortsInfoArr: # filter out non Arduino devices
            if "CH340" in str(portInfo.description):
                arduinoPortInfos.append(portInfo)
            else:
                print("Filter out", str(portInfo.description))   
        # filter out the non-ReviGrid devices and register all the ReviGrid devices
        self.registerSPs(arduinoPortInfos)


    def registerSPs(self, arduinoPortInfos):
        SPs = []
        print("\n")
        for portInfo in arduinoPortInfos:
            print("Registering ", portInfo.description, "...")
            try:
                SP = serial.Serial(portInfo.name, 115200, timeout = 2) # create a serial port
            except:
                print(portInfo.description, " is busy or invalid")
                continue

            SP.baudrate = 115200  
            SP.bytesize = 8   # each byte has 8 bits
            SP.parity  ='N'   # no parity
            SP.stopbits = 1   # 1 stop bit
            SP.write_timeout = 1
            SP.rtscts = True
            # SP.open()
            time.sleep(0.1)
            SP.rtscts = False
            SP.reset_input_buffer()
            SP.reset_output_buffer()
            SPs.append(SP)

        
        time.sleep(3) # wait for port to open
        print("\n")
        for port in SPs:
            self.writeSP(port, "*ID?")  # need to encode string into bytes
            moduleName = self.readSP(port)
            self.serialPortObjList.append(port)
            currModule = None
            if moduleName == "houseload": # create house object
                currModule = HouseModule(moduleName, port)
                self.HouseModuleArr.append(currModule)
                self.serialPortObjList.append(port)
            elif moduleName == "solartracker": # create solar tracker object
                currModule = SolarModule(moduleName, port)
                self.SolarModuleArr.append(currModule)
                self.serialPortObjList.append(port)
            elif moduleName == "fan": # create fan module
                currModule = FanModule(moduleName, port)
                self.FanModuleArr.append(currModule)
                self.serialPortObjList.append(port)
            elif moduleName == "windturbine": # create wind turbine object
                currModule = WindModule(moduleName, port)
                self.WindModuleArr.append(currModule)
                self.serialPortObjList.append(port)
            elif moduleName == "generator": # create generator object
                currModule = GeneratorModule(moduleName, port)
                self.GeneratorModuleArr.append(currModule)
                self.serialPortObjList.append(port)
            else: # filter out non-ReviGrid devices
                print("Filter out", str(port.port))
                continue
                
            print(port.port, ":", moduleName)

    # reads a string from the COM port device
    def readSP(self, portObj):
        message = portObj.read_until(b'\r\n')
        message = message.decode()
        message = message.strip() # removes leading and trailing newline
        return message

    # sends out a string to the COM port device
    def writeSP(self, portObj, message):
        message = str(message) + "\r\n"
        portObj.write(message.encode())

        




