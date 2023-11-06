% MARTIN THUNEMANN VERSION 3/15/2023
% This is used to collect analog input from a NI USB-6363 DAQ system
% We use this code to measure the accelerometer. The camera triggers sent
% to the mesoscope by the main DAQ system are recorded to align the
% accelrometer data to the wide field imaging data. 


%% Prepare workspace


clearvars; clc; daqreset;
%% Folder
% Filename will be generated as 'root\date\animal\trigger\Run00X_info.mat'

folder.root='C:\data\bcraus';
folder.date='23-10-02';     % (use YY-MM-DD)
folder.animal='Thy1_173';
folder.run = 1; % (needs to be a number)
folder.info=''; % what does this mean?pointscan_Run01_A3_airpuff
%% Define trials and record duration

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% |
% | preTrialRecordTime (in s)
% |
% | %%%%%%%%% N repetitions %%%%%%%%%%%%
% | %  Trial length: ISI (in s)        %
% | %  Contains stimulus sequences     %
% | %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% |
% | postTrialRecordTime (in s)
% |
%\|/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trial.N = 0; %28, 37 long 5Hz,30sec % 5 for baseline, 7 for air puff pO2?
trial.ISI = 0;% (in s) %20 long 5Hz,30sec
trial.backgroundTime=600;%20 long 5Hz,30sec
trial.postTrialRecordTime=30;% (in s) Extra recording time after last trial %20 long 5Hz,30sec
% % Derived from previous parameters
run.tTotal=trial.backgroundTime+trial.N*trial.ISI+trial.postTrialRecordTime;
%% DAQ device

device.manufacturer='ni';
device.name='Dev1';
%% Analog Input channels
% The variable 'device.inputChannel.id' must be unique and must match the channel 
% name in the device (ai0, ai1, ai2, ...)! The variable 'device.inputChannel.name' 
% must be unique!

device.inputRate=1E5;  %(in Hz)
device.inputChannel(1).id='ai0';
device.inputChannel(1).name='CameraTrigger';
% 
device.inputChannel(2).id='ai4';
device.inputChannel(2).name='Accelerometer_X';
device.inputChannel(3).id='ai5';
device.inputChannel(3).name='Accelerometer_Y';
device.inputChannel(4).id='ai6';
device.inputChannel(4).name='Accelerometer_Z';

device.inputChannel(2).id='ai16';
device.inputChannel(2).name='PhotoDiode';

%% Define file name and check if file already exists.

[~,~,~]=mkdir(fullfile(folder.root,folder.date,folder.animal,'accelerometer'));
folder.directory = fullfile(folder.root,folder.date,folder.animal,'trigger');
folder.fullfile=fullfile(folder.root,folder.date,folder.animal,'accelerometer',sprintf('Run%03.0f%s.mat',folder.run,folder.info));
fprintf('\n\nRecording file name:           %s...', folder.fullfile)
if exist(folder.fullfile,'file')
    fig = uifigure;
    tmpProceed=uiconfirm(fig,sprintf('Overwrite %s?',folder.fullfile),'Target file already exists!','Icon','warning','Options',{'Overwrite','Cancel'},'DefaultOption',2,'CancelOption',2);
    close(fig);clearvars fig
    if ~strcmp(tmpProceed,'Overwrite')
        return;
    else
        fprintf('OVERWRITE');
    end
end
%% Prepare DAQ system

fprintf('\n\nPreparing DAQ system...')
daqreset; clearvars handler*
tmpInfo=daqlist(device.manufacturer);
tmpInd=find(strcmp({tmpInfo.DeviceInfo.Subsystems.SubsystemType},'AnalogInput'));
device.info.analogInput.channelNames=tmpInfo.DeviceInfo.Subsystems(tmpInd).ChannelNames;
tmpInd=find(strcmp({tmpInfo.DeviceInfo.Subsystems.SubsystemType},'AnalogOutput'));
device.info.analogOutput.channelNames=tmpInfo.DeviceInfo.Subsystems(tmpInd).ChannelNames;
%% Perform consistency checks

if size({device.inputChannel.id},2)~=size(unique({device.inputChannel.id}),2)
    error('Analog Input Channel ID (device.inputChannel.id) must be unique');
end
if size({device.inputChannel.name},2)~=size(unique({device.inputChannel.name}),2)
    error('Analog Input Channel Name (device.inputChannel.name) must be unique');
end
% if size({device.outputChannel.id},2)~=size(unique({device.outputChannel.id}),2)
%     error('Analog Output Channel ID (device.outputChannel.id) must be unique');
% end
% if size({device.outputChannel.name},2)~=size(unique({device.outputChannel.name}),2)
%     error('Analog Output Channel Name (device.outputChannel.name) must be unique');
% end
%% Check for correct Analog Input Channel and Output Channel assignment

for iChannel = 1:size(device.inputChannel,2)
    tmpInd=find(strcmp(device.info.analogInput.channelNames,device.inputChannel(iChannel).id));
    if isempty(tmpInd)
        error(['Analog Input Channel with ID ' device.inputChannel(iChannel).id ' is not available on ' device.name])
    end
end
% for iChannel = 1:size(device.outputChannel,2)
%     tmpInd=find(strcmp(device.info.analogOutput.channelNames,device.outputChannel(iChannel).id));
%     if isempty(tmpInd)
%         error(['Analog Output Channel with ID ' device.outputChannel(iChannel).id 'is not available on ' device.name])
%     end
% end
clear tmp*
%% Create Analog Input Handler

handlerDeviceInput=         daq(device.manufacturer);
handlerDeviceInput.Rate=    device.inputRate;
for iChannel=1:size(device.inputChannel,2)
    [~,device.inputChannelIndex(iChannel)]=addinput(handlerDeviceInput,device.name,device.inputChannel(iChannel).id,"Voltage");
    handlerDeviceInput.Channels(device.inputChannelIndex(iChannel)).TerminalConfig="SingleEnded";
    handlerDeviceInput.Channels(device.inputChannelIndex(iChannel)).Name=device.inputChannel(iChannel).name;
end
%% Create Analog Output Handler

% handlerDeviceOutput=        daq(device.manufacturer);
% handlerDeviceOutput.Rate =  device.outputRate;
% for iChannel=1:size(device.outputChannel,2)
%     [~,device.outputChannelIndex(iChannel)]=addoutput(handlerDeviceOutput,device.name,device.outputChannel(iChannel).id,"Voltage");
%     handlerDeviceOutput.Channels(device.outputChannelIndex(iChannel)).Name=device.outputChannel(iChannel).name;
% end
%% Load Analog Output to DAQ Card

% preload(handlerDeviceOutput,run.VOut);
% fprintf('done.')
%% Wait for user input

fprintf('\n\nPress any key to start run...'); pause
%% Perform run

fprintf('\nStarting analog input...')
start(handlerDeviceInput,"Duration",seconds(run.tTotal+10));
fprintf('\nPre-trial baseline');
pause(trial.backgroundTime)
fprintf('\nTrials...')
% start(handlerDeviceOutput,"RepeatOutput")
pause(trial.N*trial.ISI)
% stop(handlerDeviceOutput)
fprintf('\nPost-trial recording time...')
pause(trial.postTrialRecordTime)
pause(10);
fprintf('\nAcquistion finished.')
%% Load analog input and save into mat file

fprintf('\nReading analog input and save to file...')
analogInput = read(handlerDeviceInput,"all");
save(folder.fullfile,'analogInput','trial','folder','device','-v7.3');
fprintf('done.')
fprintf('\nFinished.\n')
daqreset; clearvars handler*