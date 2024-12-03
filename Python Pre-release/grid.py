from module import *

import time
import serial
from serial.tools import list_ports
from serial.tools.list_ports_common import ListPortInfo # for type annotation

class Grid:
    """The Grid class organizes the modules that can be included in a grid object"""
    
    def __init__(self) -> None:
        self.fan_modules = []
        self.house_modules = []
        self.solar_modules = []
        self.wind_modules = []
        self.generator_modules = []
        self.module_serial_ports = []
        self.init_modules()

    def init_modules(self) -> None:
        """Prints list of available/connected COM ports, then filters to register only ReviGrid devices"""
        available_com_ports: list[ListPortInfo] = serial.tools.list_ports.comports() 
        print("\nAvailable COM ports: ")
        for port in available_com_ports:
            print(port.description)

        self.register_revigrid_com_ports(available_com_ports)

    def register_revigrid_com_ports(self, available_com_ports: list[ListPortInfo]) -> None:
        """Registers only ReviGrid Arduino Chip CH340 ports and filters out rest"""
        revigrid_arduino_ports: list[ListPortInfo] = []
        print("\n")
        
        for port in available_com_ports:
            if "CH340" in str(port.description):
                revigrid_arduino_ports.append(port)
            else:
                print(f"Filter out {str(port.description)}")   
    
        self.register_serial_ports(revigrid_arduino_ports)

    def register_serial_ports(self, revigrid_arduino_ports: list[ListPortInfo]) -> None:
        serial_ports: list[serial.Serial] = []
        print("\n")

        for port in revigrid_arduino_ports:
            # port is a device name: depending on operating system. e.g. /dev/ttyUSB0 on GNU/Linux or COM3 on Windows.
            print(f"Registering {port.description}...")
            try:
                serial_port = serial.Serial(port.name, 115200, timeout = 2)
            except:
                print(f"{port.description} is busy or invalid")
                continue

            # config
            serial_port.baudrate = 115200  
            serial_port.bytesize = 8   # each byte has 8 bits
            serial_port.parity  ='N'   # no parity
            serial_port.stopbits = 1   # 1 stop bit
            serial_port.write_timeout = 1
            serial_port.rtscts = True # actual pin CH340 (true = 0 V)
            time.sleep(0.1)
            serial_port.rtscts = False
            serial_port.reset_input_buffer()
            serial_port.reset_output_buffer()
            serial_ports.append(serial_port)

        # Map module names to their corresponding classes and arrays
        module_map = {
            "houseload": (HouseModule, self.house_modules),
            "solartracker": (SolarModule, self.solar_modules),
            "fan": (FanModule, self.fan_modules),
            "windturbine": (WindModule, self.wind_modules),
            "generator": (GeneratorModule, self.generator_modules),
        }

        time.sleep(3) # wait for port to open
        print("\n")
        for port in serial_ports:
            self.write_SP(port, "*ID?")  # need to encode string into bytes
            module_name = self.read_SP(port)
            self.module_serial_ports.append(port)
            new_module_instance = None

            # Create the associated object for a module and 
            # update the arrays from the module mapping dictionary
            if module_name in module_map:
                ModuleClass, module_list = module_map[module_name]
                new_module_instance = ModuleClass(module_name, port)
                module_list.append(new_module_instance)
                self.module_serial_ports.append(port)
            else:  # Filter out non-ReviGrid devices
                print(f"Filter out {str(port.port)}")
                continue  
            print(f"{port.port}:{module_name}")

    def read_SP(self, port) -> str:
        """Reads a string from the COM port device"""
        message = port.read_until(b'\r\n')
        message = message.decode().strip()
        return message

    def write_SP(self, port, message: str) -> None:
        """Sends out a string to the COM port device"""
        message = f"{str(message)}\r\n"
        port.write(message.encode())
