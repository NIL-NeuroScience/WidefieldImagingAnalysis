% Patrick Doran Version 09/25/2023
% This function calculates the timing of red (jRGECO), green (GRAB) and
% hemoglobin frames. It also determines the time of stimulus onset
function [tHb,tGRAB,tjRGECO,tStim] = fTime_Calculation(digitalInput,settings)

% This determines which LED is used first. This is only necessary for
% determining what time to call zero (when first frame ends)
tmpFirstLED = str2double(settings.LEDOrder(1,:));
switch tmpFirstLED
    case 525
        tmpDiff_First_LED = diff(digitalInput.LED525Signal);
    case 625
        tmpDiff_First_LED = diff(digitalInput.LED625Signal);
    case 565
        tmpDiff_First_LED = diff(digitalInput.LED565Signal);
    case 470
        tmpDiff_First_LED = diff(digitalInput.LED470Signal);
end

% This takes the time the LED goes off as the time that the frame is
% measured
t = seconds(digitalInput.Time);
tmpdiffjRGECO = diff(digitalInput.LED565Signal);
tjRGECO = t(tmpdiffjRGECO==-1);
tmpdiffGRAB = diff(digitalInput.LED470Signal);
tGRAB = t(tmpdiffGRAB == -1);
tmpdiff525 = diff(digitalInput.LED525Signal);
tmpt525 = t(tmpdiff525==-1);
tmpdiff625 = diff(digitalInput.LED625Signal);
tmpt625 =  t(tmpdiff625==-1);

% Make timing of Hb the time when the last Reflectance LED goes off
if tmpt625(1) > tmpt525(1)
    tHb = tmpt625;
else
    tHb = tmpt525;
end

% tCamera is the time of the first LED
tCamera = t(tmpDiff_First_LED==-1);
tmpDiff_Stim = diff(digitalInput.StimulusTrigger);
tStim = t(tmpDiff_Stim==1);
tStim = tStim - tCamera(1);
tHb  = tHb - tCamera(1);
tjRGECO  = tjRGECO - tCamera(1);
tGRAB = tGRAB - tCamera(1);
% Deterimne number of puffs per stimulus presentation from settings
tmpnPuffs = settings.StimulusDurationLong * settings.StimulusFrequency;
tStim = tStim(1:tmpnPuffs:end);
end