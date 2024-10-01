function main(modeFlag)
    % mode = 0 -> without prompts (developer mode)
    % mode = 1 -> with prompts (normal mode)
    if (modeFlag ~= 0) && (modeFlag ~= 1)
        str = "ERROR: Invalid mode flag.";
        error(str);
    end

    evalin('base','clear') % clear base workspace
    unitList = registerUnits(modeFlag);
    numOfUnits = size(unitList, 2);
    assignin('base', 'modeFlag', 0); % developer mode is default
    for i = 1:numOfUnits
        ID = unitList{i}.ID;
        if ID == "houseload"
            house = unitList{i};
            assignin('base', 'house', house);
        elseif ID == "fan"
            fan = unitList{i};
            assignin('base', 'fan', fan);
        elseif ID == "solartracker"
            solar = unitList{i};
            assignin('base', 'solar', solar);
        elseif ID == "windturbine"
            wind = unitList{i};
            assignin('base', 'wind', wind);
        elseif ID == "generator"
            gen = unitList{i};
            assignin('base', 'gen', gen);
        elseif ID == "LEDSun"
            sun = unitList{i};
            assignin('base', 'sun', sun);
        end % end if else
    end % end for
end % end main()


% register all modules
function unitList = registerUnits(modeFlag)
    SPNameList = serialportlist; % get all available serial ports
    SPCount = size(SPNameList, 2); % get num of available serial ports
    unitList = {};
    for i = 1:SPCount % register all avaialble serial ports
        % create a serail port obj with 115200 baud rate and 2 sec timeout.
        SP = registerSP(SPNameList(i));
        ID = getID(SP);
        unit = setUpUnit(ID, SP, modeFlag);
        writeSP(SP, "init");
        unitList{i} = unit;
    end % for
end

% register a serial port object with "portName"
function SP = registerSP(portName)
    % create a serail port with baud rate 115200 and timeout 2 sec.
    try % check serial port
        str = "Registering serial port " + portName + "...";
        disp(str);
        SP = serialport(portName, 115200, "Timeout", 2);
        SP.configureTerminator("LF");
        pause(1.5) % wait for serial port to set up, min 1.5 sec
    catch 
        str = "ERROR: Can't open " + portName;
        error(str);
    end
end

% get unit ID associated with the "SP" serial port object
function ID = getID(SP)
    writeSP(SP, "*ID?") % request ID

    % check serial port readline
    try
        lastwarn('');
        ID = readline(SP); % get ID
        if(~isempty(lastwarn))
            % readline() only triggers a warning when timeout
            % insert an error to trigger "catch"
            error();
        end
    catch 
        str = "ERROR: Can't read ID from " + SP.Port;
        error(str);
    end

    % check ID validity
    if isstring(ID) == 0
        str = "ERROR: Invalid ID from " + SP.Port; 
        error(str);
    end
    % remove newline char from ID
    ID = convertStringsToChars(ID);
    ID = ID(1:end - 1);
end


function unit = setUpUnit(ID, SP, modeFlag)
    if ID == "houseload" % set up house object
        unit = houseObj;
    elseif ID == "solartracker" % set up solar tracker object
        unit = solarObj;
    elseif ID == "windturbine" % set up wind turbine object
        unit = windObj;
    elseif ID == "fan" % set up fan object
        unit = fanObj;
    elseif ID == "generator" % set up generator object
        unit = generatorObj;
    elseif ID == "LEDSun"
        unit = sunObj;
    else
        str = "ERROR: Invalid unit ID, '" + ID + "' at " + SPName;
        error(str);
    end

    unit.setup(SP, ID, modeFlag)
    str = ID + " registered" + newline;
    disp(str);
end

% write a string to serial port
function writeSP(SP, str)
    str = string(str) + newline;
    SP.write(str, "char");
end