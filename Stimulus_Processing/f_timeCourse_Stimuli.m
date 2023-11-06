function [tc] = f_timeCourse_Stimuli(data,mask)
% Version 1.0 Patrick Doran 09/27/2023
% This makes a time course from a stimulus averaged 3 dimensional ratio 
% image matrix and a mask
nPoints = size(data,3);
nReps = size(data,4);
tc = zeros(nReps,nPoints);
for iRep = 1:nReps
    for iPoint = 1:nPoints
        tmp = data(:,:,iPoint,iRep).*mask;
        tc(iRep,iPoint) = mean(tmp,'all','omitnan');
    end
end
end