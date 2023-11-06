function [NewData] = f_Subtract_Baseline_Apply_Mask(data,mask,index1,index2)
% Version 1.0 Patrick Doran 09/27/2023
% This function subtracts baseline images from the 4D interprolated data
% matrix. The time that is baseline is index1:index2 on the tNew vector
% (relative to stimulus onset). A mask of the cranial window is also
% applied to the data
NewData = data;
reps = size(data,4);
for irep = 1:reps
    Baseline = squeeze(data(:,:,index1:index2,irep));
    Baseline = mean(Baseline,3);
    for t = 1:size(data,3)
        NewData(:,:,t,irep) = (data(:,:,t,irep) - Baseline).*mask;
    end
end
end