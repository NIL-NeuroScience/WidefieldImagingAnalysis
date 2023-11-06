%Multi Wavelength Aqcuisition
% MARTIN THUNEMANN VERSION 1/25/2023
% Only use Matlab 2022 or newer

% Error Messages:
% If 'Connecting to LED Drivers' gives you an error message, please switch LED drivers off and on again
% If 'Setting up LEDS' gives you an error message, please go to the specified LED driver, click 'LED settings' -> click yellow button 'Test Head' (light should flash) -> click red button 'Meas' below

%%
clearvars -except handler470 handler525 handler565 handler625 %try clearvars if error occur
clc;
%% Put where you want the file saved here
Root_Folder = 'D:\bcraus\23-08-29\';
Mouse = 'Test';
Run = 7;
fprintf('\n\nPreparing acquisition...')
%%
[~,~,~]=mkdir(fullfile(Root_Folder,Mouse,'Triggers'));

%% Settings Defined by User
% LED Settings. Power of LEDs are set in Amps.
% Fluorescent LEDs 470 and 565 have max power of 10 Amps
% Reflectance LEDs 525 and 625 have max power of 1 Amp
settings.Rows = 2048; % Number of rows in the image (Before Binning): Height in Solis button Binning/ROI
settings.LEDOrder= ['470';'565';'525';'625']; % Strings with the order of the LEDs Must be 470, 525, 565 or 625
% When only doing intrinsic imaging, increase exposure time on reflectance % channels to 8 ms. If doing fluorescence lower reflectance exposure times to 4 ms to save time but NEVER go below 4 ms
settings.ExposureTimes  =   [3,3,3,3]; % Time that each 
% LED is on in ms (Trigger length will be calculated)
settings.LEDPower =   [0.3,6,0.1,0.05]; % LED Power in Amps out of 4 max for 475 and 10 max for 565
settings.BaslerExposure = 15; % Exposure time for the behavior camera in ms
% if baseline, set repetitions to 0 and just add pre and post 180s
settings.PreStimulusBaseline = 60; % Imaging Time before stimulus in seconds %300 1/24/23
settings.PostStimulusBaseline = 0; % Imaging Time After Stimulus in seconds. Always need to have some post-stimulus baseline
settings.StimulusRepetitions = 0; % Repetions of the stimulus % Nr of trials
settings.StimulusISI = 3; % Inter stimulus interval in seconds
settings.StimulusFrequency = 5; % Frequency of stimulus Hz %3
settings.StimulusDurationLong = 1; % Full Length Of Stimulus in Seconds %2
settings.StimulusDurationShort = 10; % Length of an individual puff in milliseconds
settings.DAQFrequency = 30E3; % Hz

settings.userSetsFS = 1; % Make 1 to set an acquisition frequency lower than the maximum possible frequency
settings.userFS = 10; % Hz: User defined acquisiton frequency is only used if userSetsFS is set to true

%% Calculate Extra Time Required for Rolling Shutter
load('Zyla_Rolling_Shutter_1360_New.mat');
tmpScalingFactor = settings.Rows/1360;
settings.ExtraTriggerTime = tmpScalingFactor * tTrigger2FireAll; % Extra Time between when trigger starts and fire all ms
settings.MandatoryWaitTime = tmpScalingFactor * tEndFireALL2ARM; % Time between when trigger ends and camera can take another image ms
settings.ExtraWaitTime = 0.2; % 0.2 ms Extra time between triggers to ensure no frames are missed ms
settings.totalTime = settings.PreStimulusBaseline + settings.PostStimulusBaseline + (settings.StimulusISI * settings.StimulusRepetitions);
clearvars tmp* tEndFireALL2ARM tTrigger2FireAll

%% Calculate Cycle Parameters
settings.extraTime = settings.MandatoryWaitTime + settings.ExtraWaitTime; % Extra time between each frame ms
settings.cycleTime = ((sum(settings.ExposureTimes)+((settings.extraTime+settings.ExtraTriggerTime)*length(settings.ExposureTimes)))/1000);
settings.fs = 1/settings.cycleTime;
if settings.userSetsFS
    if settings.userFS > settings.fs
        error("User defined acquisition frequency is too High!")
    else
        settings.fs = settings.userFS;
        settings.cycleTime = 1/settings.fs;
    end
end
settings.nCycles = floor(settings.totalTime/settings.cycleTime);
settings.nframes = settings.nCycles.*length(settings.ExposureTimes);

% Make sure stimuli start at the beggining of a cycle.
settings.PreStimulusBaseline = (ceil(settings.PreStimulusBaseline/settings.cycleTime))*settings.cycleTime;
settings.StimulusISI = (ceil(settings.StimulusISI/settings.cycleTime))*settings.cycleTime;
if settings.PostStimulusBaseline ~= 0
    settings.PostStimulusBaseline = settings.totalTime - settings.PreStimulusBaseline - (settings.StimulusRepetitions*settings.StimulusISI);
end

%% DAQ device
device.manufacturer='ni';
device.name='Dev1';
%% Digital Output channels
% The variable 'device.outputChannel.id' must be unique!
% The variable 'device.outputChannel.name' must be unique!
% The variable 'device.outputChannel.name' must match 'stimulus.name'!
% Do Not Change the ORDER of these channels
device.outputRate=30E3; %(in Hz)
device.outputChannel(1).id='port0/line0'; % Port 0 line 0 is trigger to camera. Port 0 line 16 is alternative trigger
device.outputChannel(1).name='SonaTrigger';
device.outputChannel(2).id='port0/line1';
device.outputChannel(2).name='LED470Trigger';
device.outputChannel(3).id='port0/line2';
device.outputChannel(3).name='LED525Trigger';
device.outputChannel(4).id='port0/line3';
device.outputChannel(4).name='LED565Trigger';
device.outputChannel(5).id='port0/line4';
device.outputChannel(5).name='LED625Trigger';
device.outputChannel(6).id='port0/line5';
device.outputChannel(6).name='BaslerTrigger';
device.outputChannel(7).id='port0/line6';
device.outputChannel(7).name='StimulusTrigger';

%% Digital Input channels
% The variable 'device.inputChannel.id' must be unique and
%   must match the channel name in the device (ai0, ai1, ai2, ...)!
% The variable 'device.inputChannel.name' must be unique!
device.inputRate=30E3; %(in Hz)
device.inputChannel(1).id='port0/line9';
device.inputChannel(1).name='SonaTrigger';
device.inputChannel(2).id='port0/line10';
device.inputChannel(2).name='BaslerTrigger';
device.inputChannel(3).id='port0/line11';
device.inputChannel(3).name='StimulusTrigger';
device.inputChannel(4).id='port0/line21';
device.inputChannel(4).name='FireALL';
device.inputChannel(5).id='port0/line8';
device.inputChannel(5).name='ARM';
device.inputChannel(6).id='port0/line17';
device.inputChannel(6).name='LED470Signal';
device.inputChannel(7).id='port0/line18';
device.inputChannel(7).name='LED525Signal';
device.inputChannel(8).id='port0/line19';
device.inputChannel(8).name='LED565Signal';
device.inputChannel(9).id='port0/line12';
device.inputChannel(9).name='LED625Signal';
device.inputChannel(10).id='port0/line22'; %Added to read vis stim trigger
device.inputChannel(10).name='VIS';
device.inputChannel(11).id='port0/line23'; %Added to read vis stim trigger
device.inputChannel(11).name='BIT0';
device.inputChannel(12).id='port0/line24'; %Added to read vis stim trigger
device.inputChannel(12).name='BIT1';
device.inputChannel(13).id='port0/line27'; %Added to read vis stim trigger % changed to line 
device.inputChannel(13).name='BIT2';
device.inputChannel(14).id='port0/line26'; %Added to read vis stim trigger
device.inputChannel(14).name='BIT3';
device.inputChannel(15).id='port0/line28'; 
device.inputChannel(15).name='Bpod';
device.inputChannel(16).id='port0/line30'; %Added to read vis stim trigger
device.inputChannel(16).name='LilVis';



%% Set up LEDs - Connect to the LED Drivers
% Uses visadev interface to communicate to USB connected DC-2200
% If we run the code repeatedly, we do not delete handlers to speed up
% measurement initialization.
% When we create the handlers, we set a timout of 1 s.
% When we use the old handlers, we flush the read/write cache and
% send the signal to turn the LED off (just in case).

fprintf('\nConnecting to LED Drivers...')
fprintf(' 470...');
if ~exist('handler470','var')       % when handler does not exist
    handler470 = visadev('USB0::0x1313::0x80C8::M00841791::0::INSTR');
    handler470.Timeout=0.1;
    writeline(handler470,'*RST')
else                                % when handler does exist
    writeline(handler470,'*RST')
    writeline(handler470,'OUTPUT:STATE 0');
end

fprintf(' 525...');
if ~exist('handler525','var')   
    handler525 = visadev('USB0::0x1313::0x80C8::M00827828::0::INSTR');
    handler525.Timeout=0.1;
    writeline(handler525,'*RST')
else
    writeline(handler525,'*RST')
    writeline(handler525,'OUTPUT:STATE 0');
end

fprintf(' 565...');
if ~exist('handler565','var')
    handler565 = visadev('USB0::0x1313::0x80C8::M00841792::0::INSTR');
    handler565.Timeout=0.1;
    writeline(handler565,'*RST')
else
    writeline(handler565,'*RST')
    writeline(handler565,'OUTPUT:STATE 0');
end

fprintf(' 625...');
if ~exist('handler625','var')   
    handler625 = visadev('USB0::0x1313::0x80C8::M00827827::0::INSTR');
    handler625.Timeout=0.1;
    writeline(handler625,'*RST')
else
    writeline(handler625,'*RST')
    writeline(handler625,'OUTPUT:STATE 0');
end
fprintf(' done.')
%%
fprintf('\nSetting up LEDS...')
for iLED = 1:length(settings.LEDPower)
    switch settings.LEDOrder(iLED,:)
        case '470'
            fprintf(' 470...')
            f_test_LED(handler470,settings.LEDPower(iLED),'470')
            writeline(handler470,'SOURCE:MODE TTL')
            writeline(handler470,sprintf('SOURCE:TTL:AMPLITUDE %.3f',settings.LEDPower(iLED)))
            writeline(handler470,'OUTPUT:STATE 1');
            writeline(handler470,'DISPLAY:BRIGHTNESS 0');
            pause(2);
        case '525'
            fprintf(' 525...')
            f_test_LED(handler525,settings.LEDPower(iLED),'525')
            writeline(handler525,'SOURCE:MODE TTL')
            writeline(handler525,sprintf('SOURCE:TTL:AMPLITUDE %.3f',settings.LEDPower(iLED)))
            writeline(handler525,'OUTPUT:STATE 1');
            writeline(handler525,'DISPLAY:BRIGHTNESS 0');
            pause(2);
        case '565'
            fprintf(' 565...')
            f_test_LED(handler565,settings.LEDPower(iLED),'565')
            writeline(handler565,'SOURCE:MODE TTL')
            writeline(handler565,sprintf('SOURCE:TTL:AMPLITUDE %.3f',settings.LEDPower(iLED)))
            writeline(handler565,'OUTPUT:STATE 1');
            writeline(handler565,'DISPLAY:BRIGHTNESS 0');
            pause(2);
        case '625'
            fprintf(' 625...')
            f_test_LED(handler625,settings.LEDPower(iLED),'625')
            writeline(handler625,'SOURCE:MODE TTL')
            writeline(handler625,sprintf('SOURCE:TTL:AMPLITUDE %.3f',settings.LEDPower(iLED)))
            writeline(handler625,'OUTPUT:STATE 1');
            writeline(handler625,'DISPLAY:BRIGHTNESS 0');
            pause(2);
        otherwise
            error('Change LED order to only have 470, 525, 565 or 625')
    end
end
fprintf(' done.')
%% Begin DAQ setup
fprintf('\nSetting up DAQ system...');
daqreset;
tmpInfo=daqlist(device.manufacturer);

tmpInfo=tmpInfo(1,:);

tmpInd=find(strcmp({tmpInfo.DeviceInfo.Subsystems.SubsystemType},'DigitalIO'));
device.info.digital.channelNames=tmpInfo.DeviceInfo.Subsystems(tmpInd).ChannelNames;
tmpInd=find(strcmp({tmpInfo.DeviceInfo.Subsystems.SubsystemType},'AnalogInput'));
device.info.analogInput.channelNames=tmpInfo.DeviceInfo.Subsystems(tmpInd).ChannelNames;
%% Create Digital Input Handler
handlerDeviceInput=         daq(device.manufacturer);
handlerDeviceInput.Rate=    device.inputRate;
for iChannel=1:size(device.inputChannel,2)
    [~,device.inputChannelIndex(iChannel)]=addinput(handlerDeviceInput,device.name,device.inputChannel(iChannel).id,"Digital");
    handlerDeviceInput.Channels(device.inputChannelIndex(iChannel)).Name=device.inputChannel(iChannel).name;
end
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
addclock(handlerDeviceInput,"ScanClock","External",'Dev1/PFI12');
start(daqClk,"continuous");
%% Load Digital Output to DAQ Card
[DAQ_Out,settings] = fMake_DAQ_Out(settings); % This makes the triggers
preload(handlerDeviceOutput,double(DAQ_Out));
fprintf('done.\n');
%% Wait for user input
fprintf('\nSet up SOLIS Software:')
fprintf('\n Kinetic series Length:                  *** %i frames',settings.nframes);
fprintf('\n Number of rows should be:               *** %i',settings.Rows);
fprintf('\n Trigger Mode:                           *** External Exposure');
fprintf('\n Hardware-Auxillary Output Configuration *** Fire All');
fprintf('\n\nThe effective frame rate will be %.2f Hz',settings.fs);
fprintf('\n\nPress any key+return to start run / press q+return to abort...'); 
msgRet=input('','s');
if strcmp(msgRet,'q')
    f_LED_Off(settings,handler470,handler525,handler565,handler625);
    return;
end
fprintf('\nStarting digital input...')
start(handlerDeviceInput,"Duration",seconds(settings.totalTime+10));
pause(2)
fprintf('\nStarting digital output...')
start(handlerDeviceOutput)
tic;
% This loop tells the user when incraments of 10% of the acquisition are
% done
while toc<settings.totalTime+3
    pause((settings.totalTime+3)/10);fprintf('\n %0.0f%% done',100*toc/(settings.totalTime+3))
end
fprintf('\nAcquistion finished!\n')

%% Turn LEDS Off
f_LED_Off(settings,handler470,handler525,handler565,handler625);

%% Load analog input and save into mat file
fprintf('\nReading digital input and save to file...')
digitalInput = read(handlerDeviceInput,"all");
save_fname = fullfile(Root_Folder,Mouse,'Triggers',sprintf('Run%03i.mat',Run));
save(save_fname,'digitalInput','settings','-v7.3');
fprintf('done. Have a nice day!\n')

if all(digitalInput.SonaTrigger==false);fprintf('\nWARNING: SonaTrigger not recorded!\n');end
if all(digitalInput.FireALL==false);fprintf('\nWARNING: FireALL not recorded!\n');end
if all(digitalInput.ARM==false);fprintf('\nWARNING: ARM not recorded!\n');end
if all(digitalInput.LED470Signal==false);fprintf('\nWARNING: LED470Signal not recorded!\n');end
if all(digitalInput.LED525Signal==false);fprintf('\nWARNING: LED525Signal not recorded!\n');end
if all(digitalInput.LED565Signal==false);fprintf('\nWARNING: LED565Signal not recorded!\n');end
if all(digitalInput.LED625Signal==false);fprintf('\nWARNING: LED625Signal not recorded!]\n');end
if settings.nframes~=size(find((diff(digitalInput.SonaTrigger)>0.5)),1);fprintf('\nWARNING: SonaTrigger (%0.0f)/nframes (%0.0f) mismatch!\n',size(find((diff(digitalInput.SonaTrigger)>0.5)),1),settings.nframes);end
%%
function []=f_LED_Off(settings,handler470,handler525,handler565,handler625)
%% Turn LEDS Off
for iLED = 1:length(settings.LEDPower)
    switch settings.LEDOrder(iLED,:)
        case '470'
            writeline(handler470,'OUTPUT:STATE 0');
            writeline(handler470,'DISPLAY:BRIGHTNESS 1');
            writeline(handler470,'SOURCE:MODE 1')
            writeline(handler470,'*RST')
        case '525'
            writeline(handler525,'OUTPUT:STATE 0');
            writeline(handler525,'DISPLAY:BRIGHTNESS 1');
            writeline(handler525,'SOURCE:MODE 1')
            writeline(handler525,'*RST')
        case '565'
            writeline(handler565,'OUTPUT:STATE 0');
            writeline(handler565,'DISPLAY:BRIGHTNESS 1');
            writeline(handler565,'SOURCE:MODE 1')
            writeline(handler565,'*RST')
        case '625'
            writeline(handler625,'OUTPUT:STATE 0');
            writeline(handler625,'DISPLAY:BRIGHTNESS 1');
            writeline(handler625,'SOURCE:MODE 1')
            writeline(handler625,'*RST')
    end
end
end

function[] = f_test_LED(handler,current,LED)%#ok<*ST2NM> 
% we turn the LED off (just in case)
writeline(handler,'OUTPUT:STATE 0');
% we set the mode to constant current (1)
writeline(handler,'SOURCE:MODE 1')
% we set the current to the given value
writeline(handler,sprintf('SOURCE:CCURENT:AMPLITUDE %f',current));
% we turn the LED on
writeline(handler,'OUTPUT:STATE 1');
% we wait 0.25 s
pause(0.25)

% we check the LED state  
tic;
while 1
    if toc>5
        writeline(handler,'OUTPUT:STATE 0');
        error('Error testing LED %s',LED)
    end
    try
        isOn = str2double(writeread(handler,'OUTPUT:STATE?'));
        break;
    catch
        fprintf('*')
    end
end
tic;
while 1
    if toc>5
        writeline(handler,'OUTPUT:STATE 0');
        error('Error testing LED %s',LED)
    end
    try
        hasLim = str2num(writeread(handler,'SOURCE1:CURR:LIM:TRIP?'));
        break;
    catch
        fprintf('#')
    end
end
tic;
while 1
    if toc>5
        writeline(handler,'OUTPUT:STATE 0');
        error('Error testing LED %s',LED)
    end
    try
        ccLim=str2num(writeread(handler,'SOURCE1:CCUR:AMPL?')); 
        break;
    catch
        fprintf('+')
    end
end
writeline(handler,'OUTPUT:STATE 0');
if hasLim == 1
    error('\nCurrent of LED %s (%0.1f A) is set higher than limit (%0.1f A)!\n',LED,current,ccLim)
end
if isOn == 0
    error('\nCurrent of LED %s is too high!',LED);
end
end