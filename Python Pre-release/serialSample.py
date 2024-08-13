import serial # pyserial
import time
print("Hello")
SerialObj = serial.Serial('COM24')
SerialObj.baudrate = 115200  
SerialObj.bytesize = 8   # each byte has 8 bits
SerialObj.parity  ='N'   # no parity
SerialObj.stopbits = 1   # 1 stop bit
SerialObj.write_timeout = 2
SerialObj.timeout = 2
time.sleep(3) # wait for port to open
SerialObj.write("init".encode())  # need to encode string into bytes 

time.sleep(3) # wait for port to open
SerialObj.write("*ID?".encode())  # need to encode string into bytes 
# print("Hello")
time.sleep(2) # wait for port to open
ReceivedString = SerialObj.readline()
print(ReceivedString.decode())


SerialObj.close()      # Close the port

