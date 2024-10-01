clear;

s = serialport("COM16", 115200); % change COM port
pauseTime = 0.02; % change delay in s

pause(1.5);


str = "setMot" + newline;
PWMval = 0;

for i = 1:inf
    s.write("motOn" + newline, "char");
    pause(pauseTime);
    s.write("motOff" + newline, "char");
    pause(pauseTime);
end