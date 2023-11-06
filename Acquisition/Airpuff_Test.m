% Patrick Doran version 12/8/2022
% Use this script to only send the airpuff triggers
% This is to be used for positioning the airpuff stimulation

clear
%% Settings Set Stimulus Parameters
settings.Repetitions = 3; % Repetions of the stimulus
settings.ISI = 15; % Inter stimulus interval in seconds
settings.Frequency = 3; % Frequency of stimulus Hz
settings.DurationLong = 2; % Full Length Of Stimulus in Seconds

settings.DurationShort = 10; % Length of an individual puff in milliseconds 
settings.DAQFrequency = 30E3; % Hz
settings.totalTime = settings.ISI * settings.Repetitions;
%% DAQ device 
device.manufacturer='ni';
device.name='Dev1';
%% Output Channel
device.outputRate=30E3; %(in Hz)
device.outputChannel(1).id='port0/line6';
device.outputChannel(1).name='StimulusTrigger';
%% Prepare DAQ system 
fprintf('\n\nPreparing DAQ system...')
daqreset; clearvars handler*
tmpInfo=daqlist(device.manufacturer);
tmpInd=find(strcmp({tmpInfo.DeviceInfo(1,1).Subsystems.SubsystemType},'DigitalIO'));
device.info.digital.channelNames=tmpInfo.DeviceInfo(1,1).Subsystems(tmpInd).ChannelNames;
%% Make DAQ Output
DAQ_Out = fMake_Puff(settings);
%% Create Digital Output Handler
handlerDeviceOutput=        daq(device.manufacturer);
handlerDeviceOutput.Rate =  device.outputRate;
for iChannel=1:size(device.outputChannel,2)
    [~,device.outputChannelIndex(iChannel)]=addoutput(handlerDeviceOutput,device.name,device.outputChannel(iChannel).id,"Digital");
    handlerDeviceOutput.Channels(device.outputChannelIndex(iChannel)).Name=device.outputChannel(iChannel).name;
end
%% Set Up Clock
daqClk = daq("ni");
ch1 = addoutput(daqClk,"Dev1","ctr0","PulseGeneration");
clkTerminal = ch1.Terminal;
ch1.Frequency = device.outputRate;
addclock(handlerDeviceOutput,"ScanClock","External",'Dev1/PFI12');
start(daqClk,"continuous");
%% Load Digital Output to DAQ Card
preload(handlerDeviceOutput,double(DAQ_Out));
fprintf('done.')
%% Wait for user input
fprintf('\n\nPress any key to start run...'); pause
fprintf('\nStarting digital output...')
start(handlerDeviceOutput)
pause(settings.totalTime+1);
fprintf('\nAcquistion finished.')




