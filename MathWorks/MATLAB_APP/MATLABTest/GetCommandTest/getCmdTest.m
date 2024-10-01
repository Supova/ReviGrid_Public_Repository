clear;

% num of runs
runCount = 1; % close and reopen serial port
% num of cmds
cmdCount = 200;
baudRate = 115200;

% generator
cmdMenu = ["init","runRange", "trackOn","trackOff"...
           "setLoad>1","setMot>1","setKp>1","setKi>1","setKd>1","setR>1","setG>1","setB>1"...
           "motOn","motOff"...
           "getVolts<1", "getBV<2"...
           "getVal<1","getKW<1","getCarbon<1","getAll<7","getRes<1","getDrop<1","getCurrent<1"...
           "off","eoc"];

% solar 
cmdMenu1 = ["init","runScan","trackOn","trackOff"...
                    "goHome","goMax","go1Q","go2Q","go3Q","go4Q"...
                    "moveCW>1","moveCCW>1","moveCWR<2","moveCCWR<2","lookCCW","lookCW"...
                    "setSteps>1","setLoad>1"...
                    "setRange>1", "setDelay>1", "setSpeed>1"...
                    "getVal<1","getKW<1","getCarbon<1","getMax<1","getAll<7"...
                    "getPos<1","getBusy<1"...
                    "on","off","eoc"];

% string cmd
strCmd = "getCommands" + newline;

errorCount = 0;
errorCountArr = double.empty;
totalCount = 0;
totalCountArr = double.empty;
errorArr = strings;
eTimeArr = double.empty;

for currRun = 1:runCount
    str = newline + "*****************************" + newline;
    str = str + "Registering Serial Port " + string(serialportlist) + newline;
    str = str + "Initializing run " + string(currRun) + newline; 
    disp(str);
    % register serial port
    SP = serialport(serialportlist, baudRate, "Timeout", 2);
    pause(1.5);

    startT = tic % start timer
    % start sending out cmds
    for currCmd = 1:cmdCount
        % send out a cmd
        SP.write(strCmd, "char");
        
        % read the first feedback
        cmdName = readSP(SP);
        if strcmp("!", cmdName) == 1
            errorStr = "ERROR: Can't read from " + SP.Port + " during " + string(currRun) + " : " + string(currCmd);
            errorArr(size(errorArr, 2) + 1) = errorStr;
            break;
        end
        
        % check if cmdName matches with cmdMenu
        while strcmp('eoc', cmdName) == 0
            % error checking, cmd is not in dictionary
            if ismember(cmdName, cmdMenu) == 0
                errorStr = "ERROR: " + cmdName + " is not in command menu during ";
                errorStr = errorStr + string(currRun) + " : " + string(currCmd) + " / " + string(cmdCount);
                disp(errorStr);
                errorArr(size(errorArr, 2) + 1) = errorStr;
                errorCount = errorCount + 1;
            end

            cmdName = readSP(SP)

            if strcmp("!", cmdName) == 1
                errorStr = "ERROR: Can't read from " + SP.Port + " during " + string(currRun) + " : " + string(currCmd);
                errorArr(size(errorArr, 2) + 1) = errorStr;
                break;
            end
        end

        % display run message
        str = string(currRun) + " : " + string(currCmd) + " / " + string(cmdCount) + " done";
        disp(str);

        % update count
        totalCount = totalCount + 1;
    end
    eTimeArr(currRun) = toc(startT); % stop timer
    clear SP;
    errorCountArr(currRun) = errorCount;
    totalCountArr(currRun) = totalCount;
    errorCount = 0;
    totalCount = 0;
end

for i = 1:runCount
    str = newline + "********** RUN " + string(i) + " *************" + newline;
    str = str + string(totalCountArr(i) - errorCountArr(i)) + " / " + string(totalCountArr(i)) + " passed." + newline;
    str = str + string(errorCountArr(i)) + " / " + string(totalCountArr(i)) + " failed." + newline;
    str = str + string(eTimeArr(i)) + " seconds.";
    disp(str);
end


% read and format a serial input
function str = readSP(port)
    % check serial port readline
    try
        lastwarn('');
        str = readline(port); % read a message from serial buffer
        if(~isempty(lastwarn))
            % readline() only triggers a warning when timeout
            % insert an error to trigger "catch"
            error();
        end
    catch 
        str = "!";
        return
    end

    str = convertStringsToChars(str); % convert to char vector for formatting
    str = str(1:end - 1); % remove "\n" terminator
end % end readSP()


