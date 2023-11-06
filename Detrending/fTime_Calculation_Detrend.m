% Patrick Doran Version 09/25/2023
% This function calculates the timing of red (jRGECO) and green (GRAB)
% frames
function [tGRAB,tjRGECO] = fTime_Calculation_Detrend(digitalInput,settings)

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

% tCamera is the time of the first LED
tCamera = t(tmpDiff_First_LED==-1);
tjRGECO  = tjRGECO - tCamera(1);
tGRAB = tGRAB - tCamera(1);
end