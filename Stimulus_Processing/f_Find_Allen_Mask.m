% Version 1.0 Patrick Doran 09/28/2023
% This function finds the mask of an Allen region from the parcellation
% structure
function [mask] = f_Find_Allen_Mask(Side,ROI,parcellation)
if strcmp(Side,"Right")
    tmpnROI = size(parcellation.RightValid,2);
    tmpNames = parcellation.RightValidFull;
elseif strcmp(Side,"Left")
    tmpnROI = size(parcellation.LeftValid,2);
    tmpNames = parcellation.LeftValidFull;
else
    error("Side must be Left or Right!");
end
for iROI = 1:tmpnROI
    if strcmp(tmpNames(iROI),ROI)
        if strcmp(Side,"Right")
            mask = parcellation.RightROIs(:,:,iROI);
            break
        elseif strcmp(Side,'Left')
            mask = parcellation.LeftROIs(:,:,iROI);
            break
        end
    end
end
end