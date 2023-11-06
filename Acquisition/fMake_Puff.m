function [DAQ_Out] = fMake_Puff(settings)
Length_Out = round(settings.totalTime*settings.DAQFrequency);
DAQ_Out = zeros(Length_Out,1);
tmpLengthISI = round(settings.ISI*settings.DAQFrequency);
tmpISIOut = zeros(tmpLengthISI,1);
tmpIndex_start = 1;
tmpLengthPuff = (settings.DurationShort*settings.DAQFrequency)/1000;
tmpOnes = ones(tmpLengthPuff,1);
for iPuff = 1:(settings.Frequency*settings.DurationLong)
    tmpISIOut(tmpIndex_start:(tmpIndex_start+tmpLengthPuff-1)) = tmpOnes;
    tmpIndex_start = tmpIndex_start + round((1/settings.Frequency)*settings.DAQFrequency);
end
tmpIndex_start = 1;
for iRep = 1:settings.Repetitions
    DAQ_Out(tmpIndex_start:(tmpIndex_start+tmpLengthISI-1)) = tmpISIOut;
    tmpIndex_start = tmpIndex_start + tmpLengthISI;
end
end