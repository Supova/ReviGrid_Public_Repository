clear
main
pause(3);

initKW = str2double(solar.call("getKW"));
maxKW = initKW;
maxIdx = 0;
KWs = double(17);

sun.call("setMax", 17);

for i = 1:18
    sun.call("goIdx", i - 1);
    pause(0.5);
    KWs(i) = str2double(solar.call("getVal"))
    pause(0.5);
    if KWs(i) > maxKW
        maxKW = KWs(i);
        maxIdx = i - 1;
    end
end

KWs
sun.call("goIdx", maxIdx);
str = "initKW: " + string(initKW);
disp(str);
str = "maxKW: " + string(maxKW);
disp(str);
str = "maxIdx: " + string(maxIdx);
disp(str);