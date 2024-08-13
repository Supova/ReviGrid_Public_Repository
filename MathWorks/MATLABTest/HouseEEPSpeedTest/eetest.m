clear
main
pause(2);

wrongCount = 0;

tic
for i = 0:32767
    i
    val = mod(i, 10)
    house.call("EPw", [i val]);
    rVal = house.call("EPr", i);
    if str2double(rVal) ~= val
        disp("wrong data");
        wrongCount = wrongCount + 1;
    end
end
toc