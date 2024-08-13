clear
% find available visa device
visalist = visadevlist;

% create visa object
osci = visadev(visalist.(1)); % create visa object using device ID
% "USB0::0xF4ED::0xEE3A::SDS1EEFX7R5086::0::INSTR"
osci.Timeout = 2; % set timeout to 2 seconds

% ID
ID = sendread(osci, "*IDN?");
% voltage division
voltDiv1 = sendread(osci, 'C1:VDIV?');
voltDiv1 = str2double(voltDiv1(8:end-1));
voltDiv2 = sendread(osci, 'C2:VDIV?');
voltDiv2 = str2double(voltDiv2(8:end-1));
% voltage offset
voltOffset1 = sendread(osci, 'C1:OFST?');
voltOffset1 = str2double(voltOffset1(8:end-1));
voltOffset2 = sendread(osci, 'C2:OFST?');
voltOffset2 = str2double(voltOffset2(8:end-1));
% sample number
sampleNum1 = sendread(osci, 'SANU? C1');
sampleNum1 = str2double(sampleNum1(5:end-3));
sampleNum2 = sendread(osci, 'SANU? C2');
sampleNum2 = str2double(sampleNum2(5:end-3));
% time division
timeDiv = sendread(osci, 'TDIV?');
timeDiv = str2double(timeDiv(5:end-1));
% time delay
timeDelay = sendread(osci, 'TRDL?');
timeDelay = str2double(timeDelay(5:end-1));

% collect waveform data1
osci.write('C1:WF? DAT2');
messageHead1 = osci.read(16, 'char'); % read header message
osci.InputBufferSize = sampleNum1 + 2; % set input buffer size
fopen(osci);
% read waveform data
data1 = fread(osci, sampleNum1+2, 'uint8');
% take out terminator
data1 = data1(1:(end-2));
% decode time:
timeOut1 = zeros(size(data1));
samplePerTimeDiv1 = sampleNum1 / 14;
timeInterval = timeDiv / samplePerTimeDiv1;
for i = 1:size(data1)
    timeOut1(i) = (i-1) * timeInterval;
end
% decode waveform data:
voltOut1 = zeros(size(data1));
for i = 1:size(data1)
    if data1(i) > 127
        data1(i) = data1(i) - 255;
    end
    voltOut1(i) = data1(i)*(voltDiv1/25)-voltOffset1;
end

% collect waveform data2
osci.write('C2:WF? DAT2');
messageHead2 = osci.read(16, 'char'); % read header message
osci.InputBufferSize = sampleNum2 + 2; % set input buffer size
% fopen(osci);
% read waveform data
data2 = fread(osci, sampleNum2+2, 'uint8');
% take out terminator
data2 = data2(1:(end-2));
% decode time:
timeOut2 = zeros(size(data2));
samplePerTimeDiv2 = sampleNum2 / 14;
timeInterval = timeDiv / samplePerTimeDiv2;
for i = 1:size(data2)
    timeOut2(i) = (i-1) * timeInterval;
end
% decode waveform data:
voltOut2 = zeros(size(data2));
for i = 1:size(data2)
    if data2(i) > 127
        data2(i) = data2(i) - 255;
    end
    voltOut2(i) = data2(i)*(voltDiv2/25)-voltOffset2;
end

% peak to peak
pkToPk1 = sendread(osci, 'C1:PAVA? PKPK');
pkToPk1 = str2double(pkToPk1(13:end-1));
pkToPk2 = sendread(osci, 'C2:PAVA? PKPK');
pkToPk2 = str2double(pkToPk2(13:end-1));

% max voltage
maxVoltage1 = sendread(osci, 'C1:PAVA? MAX');
maxVoltage1 = str2double(maxVoltage1(12:end-1));
maxVoltage2 = sendread(osci, 'C2:PAVA? MAX');
maxVoltage2 = str2double(maxVoltage2(12:end-1));

% min voltage
minVoltage1 = sendread(osci, 'C1:PAVA? MIN');
minVoltage1 = str2double(minVoltage1(12:end-1));
minVoltage2 = sendread(osci, 'C2:PAVA? MIN');
minVoltage2 = str2double(minVoltage2(12:end-1));

% max voltage
meanVoltage1 = sendread(osci, 'C1:PAVA? MEAN');
meanVoltage1 = str2double(meanVoltage1(13:end-1));
meanVoltage2 = sendread(osci, 'C2:PAVA? MEAN');
meanVoltage2 = str2double(meanVoltage2(13:end-1));

% clean data
voltOut1 = voltOut1(10:end);
voltOut2 = voltOut2(10:end);
timeOut1 = timeOut1(10:end);
timeOut2 = timeOut2(10:end);

figure
plot(timeOut1, voltOut1)
hold on
plot(timeOut2, voltOut2)
legend("Ch1", "Ch2")
% blankDist = abs(pkToPk / 10);
%ylim([min(0, minVoltage-blankDist) maxVoltage+max(1, blankDist)])

fprintf("\n\nParameters:   Ch1         Ch2 \n");
fprintf("-------------------------------- \n");
fprintf("PK2PK:     % 0.4f    % 0.4f [V] \n", pkToPk1, pkToPk2);
fprintf("MAX:       % 0.4f    % 0.4f [V] \n", maxVoltage1, maxVoltage2);
fprintf("MIN:       % 0.4f    % 0.4f [V] \n", minVoltage1, minVoltage2);
fprintf("MEAN:      % 0.4f    % 0.4f [V] \n", meanVoltage1, meanVoltage2);
fprintf("vDIV:      % 0.4f    % 0.4f [V] \n", voltDiv1, voltDiv2);
fprintf("vOFF:      % 0.4f    % 0.4f [V] \n", voltOffset1, voltOffset2);
fprintf("tDIV:      % 0.4f [s] \n", timeDiv);
fprintf("tDELAY:    % 0.4f [s] \n", timeDelay);
fprintf("Sample Num:% i       % i \n", sampleNum1, sampleNum2);
fprintf("Time Int:  % i \n\n\n", timeInterval);
% fclose(osci);

function returnVal = sendread(osci, SCPI)
    returnVal = convertStringsToChars(osci.writeread(SCPI));
    returnVal = returnVal(1:end-1);
end

