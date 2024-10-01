clear;
clc;
unitList = registerUnits();
numOfUnits = size(unitList, 2);

for i = 1:numOfUnits
    ID = unitList{i}.ID;
    if ID == "houseload"
        house = unitList{i};
    elseif ID == "fan"
        fan = unitList{i};
    elseif ID == "solartracker"
        solar = unitList{i};
    elseif ID == "windturbine"
        wind = unitList{i};
    elseif ID == "generator"
        gen = unitList{i};
    elseif ID == "LEDSun"
        sun = unitList{i};
    end
end

clear ID;
clear i;

% register
function unitList = registerUnits()
    SPNameList = serialportlist; % get all available serial ports
    SPCount = size(SPNameList, 2); % get num of available serial ports
    unitList = {};
    for i = 1:SPCount % register all avaialble serial ports
        % create a serail port obj with baud rate 9600 and timeout 2 sec.
        SP = registerSP(SPNameList(i));
        ID = getID(SP);
        unit = setUpUnit(ID, SP);
        writeSP(SP, "init");
        unitList{i} = unit;
    end % for
end

% register a serial port object with "portName"
function SP = registerSP(portName)
    % create a serail port with baud rate 9600 and timeout 2 sec.
    try % check serial port
        str = "Registering serial port " + portName + "...";
        disp(str);
        SP = serialport(portName, 115200, "Timeout", 2);
        SP.configureTerminator("LF");
        pause(1.5) % wait for serial port to set up, min 1.5
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


function unit = setUpUnit(ID, SP)
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

    unit.setup(SP, ID)
    str = ID + " registered" + newline;
    disp(str);
end

% write a string to serial port
function writeSP(SP, str)
    str = string(str) + newline;
    SP.write(str, "char");
end