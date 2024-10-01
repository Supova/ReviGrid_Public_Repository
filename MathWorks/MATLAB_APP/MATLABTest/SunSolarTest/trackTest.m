clear
main
pause(3);

sun.call("setMax", 20);
sun.call("setStepDelay", 3000);
pause(2)
sun.call("stepOn");
solar.call("go1Q");

midKW = 0;
midPos = 0;
CWKW = 0;
CWPos = 0;
CCWKW = 0;
CCWPos = 0;

stepSize = 20;

for i = 1:1000
    % solar moves back to Q1 in the morning
    if str2double(sun.call("getCurrIdx")) <= 1
        pause(1)
        solar.call("go1Q");
        pause(2)
    end

    % read middle position
    pause(1)
    midKW = str2double(solar.call("getVal"));
    midPos = str2double(solar.call("getPos"));

    % read CW position
    solar.call("moveCW", stepSize);
    pause(1);
    CWPos = str2double(solar.call("getPos"));
    CWKW = str2double(solar.call("getVal"));

    % read CCW position
    solar.call("moveCCW", stepSize * 2);
    pause(1);
    CCWPos = str2double(solar.call("getPos"));
    CCWKW = str2double(solar.call("getVal"));

    % get max KW reading
    KWs = [CCWKW CWKW midKW]
    maxKW = max(KWs);

    if CCWKW == maxKW % if CCW position is max
        currKW = str2double(solar.call("getVal"));
        while currKW > maxKW % start small steps in CCW
            solar.call("moveCCW", 15);
            pause(1);
            currKW = str2double(solar.call("getVal"));
        end
    elseif midKW == maxKW % if middle position is max
        % move back to middle position
        solar.call("moveCW", stepSize);
    elseif CWKW == maxKW % if CW position is max
        solar.call("moveCW", (stepSize * 2)); % move back to CW position
        pause(1)
        currKW = str2double(solar.call("getVal"));
        while currKW > (maxKW + 5) % start small steps in CW
            solar.call("moveCW", 15);
            pause(1);
            currKW = str2double(solar.call("getVal"));
        end
    end
    % disp("out!!!")
end
