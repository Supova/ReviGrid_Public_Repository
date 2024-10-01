clear;

s = serialport("COM16", 115200); % change COM port
pauseTime = 0.016; % change delay in s

pause(1.5);

str = "init" + newline;
s.write(str, "char"); % send init
pause(3);

str = "setMot" + newline;
PWMval = 0;

for i = 1:2550
    if PWMval == 256
        PWMval = 0;
    end
    disp(PWMval);
    s.write(str, "char"); % send setMot
    s.write(string(PWMval)+newline, "char") % send motor PWM
    pause(pauseTime); 
    PWMval = PWMval + 1; % increse motor PWM
end