%https://www.mathworks.com/help/simulink/ug/using-the-sim-command.html
clear
disp("Initializing...")
COM = serialportlist;

found = false;

for i = 1:COM.size(2)
    SP = serialport(COM(i), 115200, "Timeout", 2);
    str = "Registering " + COM(i) + "...";
    disp(str);
    pause(3);
    SP.writeline("*ID?")
    try
        lastwarn('');
        ID = readline(SP);
        if(~isempty(lastwarn))
            error();
        end
    catch
        str = COM(i) + " is not generator.";
        disp(str);
        continue;
    end
    ID = convertStringsToChars(ID);
    ID = ID(1:end - 1);
    if ID == "generator"
        str = "Found generator at " + COM(i);
        disp(str);
        found = true;
        COM = COM(i);
        break;
    end
    str = COM(i) + " is not generator.";
    disp(str);
end

if ~found
    error("Can't find generator module");
end


clear SP

set_param("genSimu/generator PID/generator serial configuration", "Port", COM)
set_param("genSimu/generator PID/getVal serial send", "Port", COM)
set_param("genSimu/generator PID/getVal serial receive", "Port", COM)
set_param("genSimu/generator PID/setMot serial send", "Port", COM)

set_param("genSimu/P", "value", "5")
set_param("genSimu/I", "value", "25")
set_param("genSimu/D", "value", "0.001")
set_param("genSimu/setpoint", "value", "120")

disp("Starting Simulation...")