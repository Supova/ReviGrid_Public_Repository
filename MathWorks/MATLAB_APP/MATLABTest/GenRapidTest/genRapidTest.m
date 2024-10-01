

clear;
SP = serialport("COM16", 115200);
pause(1.5);

str = "rapidOn" + newline;
SP.write(str, 'char');
cmd = [0x01 0x00 0x00]; % enter rapid mode

for i = 1:2550
    %disp(cmd(2));
    SP.write(cmd, 'uint8');
    cmd(2) = cmd(2) + 1;
    if cmd(2) == 255
        cmd(2) = 0x00;
    end
    pause(0.00103);
end


