classdef sunObj < handle

    properties
        ID % name of unit
        cmds % dictionary (cmdName, cmd obj), stores cmds from Arduino getCommands()
        cmdMenu % dictionary (cmdName, cmd description), preprogrammed in private properties
        outPromptMenu % dictionary (outCmds, outPrompts), preprogrammed in private properties
        inPromptMenu % dictionary (inCmds, inPrompts), preprogrammed in private properties
        rangeMenu % dictionary (promptCmds, cmdRange), preprogrammed in private properties
        
        SP % Serial port obj for communication
        % status % values returned from Arduino getAll()
    end

    properties (Access = private)
        % name of all cmds
        cmdList = ["*ID?" "getCommands" "init" ...
            "off" ...
            ]
        % description of all cmds
        cmdDef = ["[private] returns unit ID" ... % *ID?
            "[private] returns all available cmds on Arduino" ... % getCommands
            "sets the unit to its initial condition" ... % init
            "turns the unit off" ... % off
            ]

        % cmds that send arguments to unit
        outCmds = [];
        % outCmd prompts
        outPrompts = {};
        % user input range
        cmdRange = {};

        % cmds that receive information from unit
        inCmds = [];
        % inCmd prompts
        inPrompts = {}
    end % private property

    methods
        % constructor
        function obj = sunObj()
            % create command menu (cmdName, cmdDefinition)
            if size(obj.cmdList, 2) ~= size(obj.cmdDef, 2) 
                error("ERROR: Invalid command menu");
            end
            obj.cmdMenu = dictionary(obj.cmdList, obj.cmdDef); 

            % create outPrompt menu (promptCmd, outPrompts)
            if (size(obj.outCmds, 2) ~= size(obj.outPrompts, 2))
                error("ERROR: Invalid outPrompt menu");
            end
            obj.outPromptMenu = dictionary(obj.outCmds, obj.outPrompts);

            % create range menu (outCmd, userInputRange)
            if (size(obj.outCmds, 2) ~= size(obj.cmdRange, 2))
                error("ERROR: Invalid range menu");
            end
            obj.rangeMenu = dictionary(obj.outCmds, obj.cmdRange); 

            % create inPrompt menu (inCmd, inPrompts)
            if (size(obj.inCmds, 2) ~= size(obj.inPrompts, 2))
                error("ERROR: Invalid inPrompt menu");
            end
            obj.inPromptMenu = dictionary(obj.inCmds, obj.inPrompts); 

            obj.cmds = dictionary; % stores cmds available for users to call
            % obj.status = strings; % string array
        end % constructor

        % setup a sun object
        function setup(obj, serialPort, ID)
            obj.ID = ID;
            obj.SP = serialPort;
            obj.setUpCmds(); % populate obj.cmds
        end % setup()
        

        % set up the class property, obj.cmds
        function setUpCmds(obj)
            % load cmds from microcontroller
            obj.writeSP("getCommands");
            cmdName = obj.readSP(); % read a cmd name
            % keep getting cmds until "eoc"
            while strcmp('eoc', cmdName) == 0
                numOfOutput = 0;
                numOfInput = 0;
                specialIndex = -1; % index of the 1st special char
                                   % ">" means cmd needs input
                                   % "<" means cmd has output
                % if name contains ">"
                if contains(cmdName, ">") == 1
                    % update num of output
                    specialIndex = strfind(cmdName, ">");
                    numOfOutput = cmdName(specialIndex + 1:end);
                    numOfOutput = str2double(numOfOutput);
                end
                % if name contains "<"
                if contains(cmdName, "<") == 1
                    % update name of input
                    specialIndex = strfind(cmdName, "<");
                    numOfInput = cmdName(specialIndex + 1:end);
                    numOfInput = str2double(numOfInput);
                end
                % if name has special char
                if specialIndex ~= -1
                    % update name
                    cmdName = cmdName(1:specialIndex - 1);
                end
                

                % create cmd obj
                currCmd = cmd(cmdName, numOfInput, numOfOutput);
                currCmd.setUnitName(obj.ID);

                % set cmd parameters
                if isKey(obj.cmdMenu, cmdName) == 0 % cmd is not in obj.cmdMenu
                    % generate a warning when cmd is not in dictionary
                    str = "Warning: " + cmdName + " is not in command menu.";
                    disp(str);

                    currCmd.setDescription("unknown"); 
                    currCmd.setPrompt(["unknown: "]);
                    currCmd.setRange(NaN, NaN); 
                else % cmd is in obj.cmdMenu
                    currCmd.setDescription(obj.cmdMenu(cmdName));
                    % set prompts for cmds with input and output
                    if numOfOutput ~= 0 % cmd has output
                        % error checking, cmd is not in dictionary
                        if isKey(obj.outPromptMenu, cmdName) == 0
                            str = "ERROR: " + cmdName + " is not in outPrompt menu.";
                            error(str);
                            return;
                        end
    
                        % set prompts
                        cmdPrompt = obj.outPromptMenu(cmdName);
                        cmdPrompt = cmdPrompt{1};
                        if numOfOutput ~= size(cmdPrompt, 2)
                            str = "ERROR: Invalid number of output for '" + cmdName + "'";
                            error(str);
                        end
                        currCmd.setPrompt(cmdPrompt);
                        % set range
                        cmdRange = obj.rangeMenu(cmdName);
                        min = cmdRange{1}(1);
                        max = cmdRange{1}(2);
                        currCmd.setRange(min, max);
                    elseif numOfInput ~= 0 % cmd has input
                        % error checking, cmd is not in dictionary
                        if isKey(obj.inPromptMenu, cmdName) == 0
                            str = "ERROR: '" + cmdName + "' is not in inPrompt menu.";
                            error(str);
                        end
    
                        % set prompts
                        cmdPrompt = obj.inPromptMenu(cmdName);
                        cmdPrompt = cmdPrompt{1};
                        if numOfInput ~= size(cmdPrompt, 2)
                            str = "ERROR: Invalid number of input for '" + cmdName + "'";
                            error(str);
                        end
                        currCmd.setPrompt(cmdPrompt);
                    end % if for setting input and output prompts
                end

                

                % store cmd obj in dictionary
                obj.cmds(cmdName) = currCmd;
                % get next cmd name
                cmdName = obj.readSP();
            end % while loop
        end % setUpCmds()


        % write a string to serial port
        function writeSP(obj, str)
            str = string(str) + newline;
            obj.SP.write(str, "char");
        end


        % read and format a serial input
        function str = readSP(obj)
            % check serial port readline
            try
                lastwarn('');
                str = readline(obj.SP); % read a message from serial buffer
                if(~isempty(lastwarn))
                    % readline() only triggers a warning when timeout
                    % insert an error to trigger "catch"
                    error();
                end
            catch 
                str = "ERROR: Can't read ID from " + obj.SP.Port;
                error(str);
            end

            str = convertStringsToChars(str); % convert to char vector for formatting
            carriageReturn = '';
            carriageReturn(1) = 13;
            while(endsWith(str, newline) || endsWith(str, carriageReturn))
                str = str(1:end - 1); % remove terminator
            end
        end % end readSP()


        % send a cmd to Arduino
        function call(obj, cmdName)
            % error checking, cmd is not in dictionary
            if isKey(obj.cmds, cmdName) == 0
                str = "ERROR: " + "'" + cmdName + "' is not in cmd menu.";
                error(str);
                return;
            end
            % find cmd obj from dictionary
            currCmd = obj.cmds(cmdName);
            % send cmds
            if (currCmd.in == 0 && currCmd.out == 0) % cmds without input and output
                obj.writeSP(cmdName);
            elseif (currCmd.in ~= 0) % Matlab receives input
                obj.readCmdMessage(currCmd);
            elseif (currCmd.out ~= 0) % cmd needs user input
                obj.sendCmdArgument(currCmd);
            end % if
        end % call()

        % check if a user input is valid or not
        function isValid = checkValid(obj, currCmd, input)
            % skip the validity check if range is unknown (for customized
            % cmds)
            if isnan(currCmd.maxRange)
                isValid = 1;
                return
            end
            
            flag = 1;
            input = str2double(input);
            if isnan(input)
                flag = 0;
                disp("* Warning: Input is not a number, try again.");
            end
            % invalid input if is not an integer
            if(~isreal(input) || input ~= floor(input))
                flag = 0;
                disp("* Warning: Input is not an integer, try again.")
            end
            
            % invalid input if out of range
            if(input < currCmd.minRange || input > currCmd.maxRange)
                flag = 0;
                disp("* Warning: Input out of range, try again.")
            end
            isValid = flag;
        end % isvalid()

        % !!! different from App designer objects
        % get cmd arguments from user and send them to the unit
        function sendCmdArgument(obj, currCmd)
            % commented out due to customized cmds
            % if isKey(obj.outPromptMenu, currCmd.name) == 0
            %    str = "ERROR: " + "'" + cmdName + "' is not in outPromptMenu";
            %    error(str);
            % end
            strOut = convertCharsToStrings(currCmd.name) + newline;
            % receive all user input
            for i = 1:(currCmd.out)
                if isKey(obj.cmdMenu, currCmd.name) == 0
                    prompt = "input: ";
                else
                    prompt = currCmd.prompts{i};
                end
                isValid = 0;
                while isValid == 0
                    str = input(prompt, "s");
                    isValid = obj.checkValid(currCmd, str);
                end
                str = convertCharsToStrings(str) + newline;
                strOut = strOut + str;
            end
            obj.writeSP(strOut);
        end % sendCmdArgument()
        
        % !!! different from App desginer objects
        % read cmd message send back to MATLAB
        function readCmdMessage(obj, currCmd)
            % commented out for customized cmds
            %if isKey(obj.inPromptMenu, currCmd.name) == 0
            %    str = "ERROR: " + "'" + currCmd.name + "' is not in inPromptMenu";
            %    error(str);
            %end

            % send cmd
            obj.writeSP(currCmd.name);
            % receive all input
            for i = 1:(currCmd.in)
                str = obj.readSP(); % read a serial input
                if (currCmd.prompts == "unknown: ")
                    prompt = "";
                else
                    prompt = currCmd.prompts(i);
                end
                str = strcat(prompt, newline + "   ", str);
                disp(str);
            end
            disp(newline);
        end % readCmdMessage()



        
    end % method
end % sunObj class















