% Patrick Doran Version 11/1/2022
% This function makes the DAQ output for the wide field imaging system
function [DAQ_Out,settings] = fMake_DAQ_Out(settings)
%% Make one cycle output
Length_Out = round(settings.totalTime*settings.DAQFrequency);
Length_Cycle = round(settings.cycleTime*settings.DAQFrequency);
CycleOut = zeros(Length_Cycle,6);
tmpSonaOut = zeros(Length_Cycle,1);
tmpBaslerOut = zeros(Length_Cycle,1);
tmpIndex_start = 1;
tmpLengthExtra = round((settings.extraTime*settings.DAQFrequency)/1000);
% This loop makes the triggers for the camera
for iLED = 1:length(settings.ExposureTimes)
    tmpLengthOn = round(((settings.ExposureTimes(iLED)+settings.ExtraTriggerTime)*settings.DAQFrequency)/1000);
    tmpOnes = ones(tmpLengthOn,1);
    tmpSonaOut(tmpIndex_start:tmpIndex_start+tmpLengthOn-1) = tmpOnes;
    tmpIndex_start = tmpIndex_start + tmpLengthOn + tmpLengthExtra + 1;
end
CycleOut(:,1) = tmpSonaOut;
CycleOut(:,2:5) = fMake_LED_Triggers(settings,tmpSonaOut);
tmpLengthBasler = round((settings.BaslerExposure*settings.DAQFrequency)/1000);
tmpOnes = ones(tmpLengthBasler,1);
tmphalfOut = floor(Length_Cycle/2);
tmpBaslerOut(1:tmphalfOut) = 1;
CycleOut(:,6) = tmpBaslerOut;
%clear i* tmp*
%% Make DAQ out for LEDs and Triggers
DAQ_Out = zeros(Length_Out,7);
tmpIndex_start = 1;
for iCycle = 1:settings.nCycles
    DAQ_Out((tmpIndex_start:(tmpIndex_start+Length_Cycle-1)),1:6) = CycleOut;
    tmpIndex_start = tmpIndex_start + Length_Cycle;
end
%% Make Stimulus Output
Length_Out = settings.totalTime*settings.DAQFrequency;
if settings.StimulusRepetitions > 0
    Stim_Out = zeros(Length_Out,1);
    tmpLengthISI = round(settings.StimulusISI*settings.DAQFrequency);
    tmpISIOut = zeros(tmpLengthISI,1);
    tmpIndex_start = 1;
    tmpLengthPuff = (settings.StimulusDurationShort*settings.DAQFrequency)/1000;
    tmpOnes = ones(tmpLengthPuff,1);
    for iPuff = 1:(settings.StimulusFrequency*settings.StimulusDurationLong)
        tmpISIOut(tmpIndex_start:(tmpIndex_start+tmpLengthPuff-1)) = tmpOnes;
        tmpIndex_start = tmpIndex_start + round((1/settings.StimulusFrequency)*settings.DAQFrequency);
    end
    diff_trigger = diff(DAQ_Out(:,1));
    trigger_rise = find(diff_trigger==1);                                      
    trigger_rise = trigger_rise(length(settings.ExposureTimes):length(settings.ExposureTimes):end);
    tmpIndex_start = round(settings.PreStimulusBaseline*settings.DAQFrequency);
    for iRep = 1:settings.StimulusRepetitions
        [~,tmpIndex] = min(abs(trigger_rise-tmpIndex_start));
        tmpIndex_start = trigger_rise(tmpIndex);
        Stim_Out(tmpIndex_start:(tmpIndex_start+tmpLengthISI-1)) = tmpISIOut;
        tmpIndex_start = tmpIndex_start + tmpLengthISI;
    end
else
    Stim_Out = zeros((settings.totalTime*settings.DAQFrequency),1);
end
Stim_Out2 = zeros(size(DAQ_Out,1),1);
Stim_Out2(1:length(Stim_Out)) = Stim_Out;
DAQ_Out(:,7) = Stim_Out2;

%% Recalculate ISI and background Time
if settings.StimulusRepetitions>1
t = linspace(0,settings.totalTime,length(Stim_Out));
diff_stim = diff(Stim_Out);
stim_rise = t(find(diff_stim==1));
settings.PreStimulusBaseline = stim_rise(1);
settings.StimulusISI = stim_rise((settings.StimulusDurationLong*settings.StimulusFrequency)+1) - stim_rise(1);
end

end

