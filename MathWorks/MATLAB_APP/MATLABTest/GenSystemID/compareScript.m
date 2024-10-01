printOsci
pause(5)
disp("Generating transfer function...");
data = iddata(voltOut2, voltOut1, timeInterval);
Gest = tfest(data, 1, 0, NaN)
%load('TFGateWithCap.mat', 'Gest');
opt = compareOptions;
opt.InitialCondition = 'z';
figure
compare(data, Gest, opt)
