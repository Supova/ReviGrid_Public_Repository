clear
% find available visa device
visalist = visadevlist;

% create visa object
osci = visadev(visalist.(1)); % create visa object using device ID
% "USB0::0xF4ED::0xEE3A::SDS1EEFX7R5086::0::INSTR"
osci.Timeout = 2; % set timeout to 2 seconds

ID = sendread(osci, "*IDN?");
% waveSetup = sendread(osci, "WFSU?")
voltDiv = sendread(osci, 'C2:VDIV?');
voltDiv = str2double(voltDiv(8:end-1));
voltOffset = sendread(osci, 'C2:OFST?');
voltOffset = str2double(voltOffset(8:end-1));
timeDiv = sendread(osci, 'TDIV?');
timeDiv = str2double(timeDiv(5:end-1));
timeDelay = sendread(osci, 'TRDL?');
timeDelay = str2double(timeDelay(5:end-1));

sampleNum = sendread(osci, 'SANU? C2');
sampleNum = str2double(sampleNum(5:end-3));
% sampleFreq = str2double(sendread(osci, 'SARA?'))
% sampleRate = 1/sampleFreq

osci.write('C2:WF? DAT2');
messageHead = osci.read(16, 'char');
%sampleNum = str2double(messageHead(8:end))

osci.InputBufferSize = sampleNum + 2;

fopen(osci);
data = fread(osci, sampleNum+2, 'uint8');

% extract measurement data:
data = data(1:(end-2));

% determine output array size:
outputSize = size(data);


% decode time:
timeOut = zeros(outputSize);
samplePerTimeDiv = sampleNum / 14;
timeInterval = timeDiv / samplePerTimeDiv;
for i = 1:outputSize
    timeOut(i) = (i-1) * timeInterval;
end

% decode raw data:
voltOut = zeros(outputSize);
for i = 1:outputSize
    if data(i) > 127
        data(i) = data(i) - 255;
    end
    voltOut(i) = data(i)*(voltDiv/25)-voltOffset;
end

pkToPk = sendread(osci, 'C2:PAVA? PKPK');
pkToPk = str2double(pkToPk(13:end-1));

maxVoltage = sendread(osci, 'C2:PAVA? MAX');
maxVoltage = str2double(maxVoltage(12:end-1));

minVoltage = sendread(osci, 'C2:PAVA? MIN');
minVoltage = str2double(minVoltage(12:end-1));

meanVoltage = sendread(osci, 'C2:PAVA? MEAN');
meanVoltage = str2double(meanVoltage(13:end-1));

figure
plot(timeOut, voltOut)
blankDist = abs(pkToPk / 10);
ylim([min(0, minVoltage-blankDist) maxVoltage+max(1, blankDist)])

fprintf("PK2PK:     % 0.4f [V] \n", pkToPk);
fprintf("MAX:       % 0.4f [V] \n", maxVoltage);
fprintf("MIN:       % 0.4f [V] \n", minVoltage);
fprintf("MEAN:      % 0.4f [V] \n", meanVoltage);
fprintf("vDIV:      % 0.4f [V] \n", voltDiv);
fprintf("vOFF:      % 0.4f [V] \n", voltOffset);
fprintf("tDIV:      % 0.4f [s] \n", timeDiv);
fprintf("tDELAY:    % 0.4f [s] \n", timeDelay);
fprintf("Sample Num:% i \n\n\n", sampleNum);

fclose(osci);
function returnVal = sendread(osci, SCPI)
    returnVal = convertStringsToChars(osci.writeread(SCPI));
    returnVal = returnVal(1:end-1);
end

