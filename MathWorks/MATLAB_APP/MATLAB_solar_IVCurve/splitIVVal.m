clear;
regReviGridObjs;
pause(5);

solar.call("runIVScan");
str = readline(solar.SP);
for i = 1:255
    str(i) = readline(solar.SP)
end
testStr = str;
for i = 1:255
    splitStr = strsplit(testStr(i), ' , ');
    resistance(i) = splitStr(1);
    voltage(i) = splitStr(2);
    current(i) = splitStr(3);
    power(i) = splitStr(4);
end

resistance = str2double(resistance);
voltage = str2double(voltage);
current = str2double(current);
power = str2double(power);

plot(voltage, current)
hold on
plot(voltage, power)