clear;

s = serialport("COM16", 115200);
pause(1.5);

str = "init" + newline;
s.write(str, "char");
pause(3);

str = "setMot" + newline;
s.write(str, "char");

str = "255" + newline;
s.write(str, "char");
pause(3);

str = "setGenPWM" + newline;
PWMval = 0;

while(1)
    if PWMval == 255
        PWMval = 0;
    end
    disp(PWMval);
    s.write(str, "char");
    s.write(string(PWMval)+newline, "char")
    pause(0.015);
    PWMval = PWMval + 1;
end