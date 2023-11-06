% Patrick Doran
% Version 1.0 11/6/2023
% This function uses the digital input trigger matrix and the settings
% structure of imaging parameters to determine which behavior frames the
% LEDs were on for


function [Basler_Imaging_Frames] = f_Imaging_Frames(digitalInput,settings)
tDAQ = seconds(digitalInput.Time);

% Finds times that cycles of LED strobing starts
switch str2num(settings.LEDOrder(1,:))
    case 565
        Cycle_Start = tDAQ(diff(digitalInput.LED565Signal)==1);
    case 470
        Cycle_Start = tDAQ(diff(digitalInput.LED470Signal)==1);
    case 525
        Cycle_Start = tDAQ(diff(digitalInput.LED525Signal)==1);
    case 625
        Cycle_Start = tDAQ(diff(digitalInput.LED625Signal)==1);
end

Cycle_Border = find(diff(Cycle_Start)>5); % Greater than 5 second gap between cycles is when imaging system is off
tMesoscopeStart = zeros(1,length(Cycle_Border)+1); % Imaging sessions = gaps + 1
tMesoscopeEnd = tMesoscopeStart;
tMesoscopeStart(1) = Cycle_Start(1);
tMesoscopeEnd(end) = Cycle_Start(end);
for index = 1:length(Cycle_Border)
    tMesoscopeStart(index+1) = Cycle_Start(Cycle_Border(index)+1);
    tMesoscopeEnd(index) = Cycle_Start(Cycle_Border(index));
end
tMesoscopeEnd = tMesoscopeEnd+settings.cycleTime;
tBasler = tDAQ(diff(digitalInput.BaslerTrigger)==-1);
First_Run_Frames = find(tBasler > tMesoscopeStart(1) & tBasler < tMesoscopeEnd(1));
Basler_Imaging_Frames = zeros(length(tMesoscopeEnd),length(First_Run_Frames));
Basler_Imaging_Frames(1,:) = First_Run_Frames;
for index = 2:length(tMesoscopeEnd)
    Basler_Imaging_Frames(index,:) = find(tBasler > tMesoscopeStart(index) & tBasler < tMesoscopeEnd(index));
end
end