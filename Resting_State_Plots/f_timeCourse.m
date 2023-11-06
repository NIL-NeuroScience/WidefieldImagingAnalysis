function [tc] = f_timeCourse(data,mask)
% Version 1.0 Patrick Doran 09/27/2023
% This makes a time course from a stimulus averaged 3 dimensional ratio 
% image matrix and a mask
nPoints = size(data,3);
tc = zeros(nPoints,1);
for iPoint = 1:nPoints
    tmp = data(:,:,iPoint).*mask;
    tc(iPoint) = mean(tmp,'all','omitnan');
end
end