function [mask] = f_Hemisphere_Mask(Image)
% Version 1.0 Patrick Doran   03/31/2022
% This creates hemisphere masks in a new space after an image that
% Already had hemisphere masks is transformed
% This function only works on a mask that has two unconnected hemispheres
% arranged horizontally. It will not work if the hemispheres are arranged
% vertically
index = [];

% Get indicies of columns that have brain
for x = 1:size(Image,2)
    temp = Image(:,x);
    if ~isempty(find(temp>0))
        index = [index x];
    end
end

% Find columns where hemisphere masks begin and end
Left_Start = index(1);
Right_Finish = index(end);
boundaries = find(diff(index)>1);
Left_Finish = index(boundaries(1));
Right_Start = index(boundaries(1)+1);

mask.left = zeros(size(Image,1),size(Image,2));
mask.right = zeros(size(Image,1),size(Image,2));

for x = Left_Start:Left_Finish
    for y = 1:size(Image,1)
        if ~isnan(Image(y,x)) && Image(y,x) ~= 0
            mask.left(y,x) = 1;
        end
    end
end

for x = Right_Start:Right_Finish
    for y = 1:size(Image,1)
        if ~isnan(Image(y,x)) && Image(y,x) ~= 0
            mask.right(y,x) = 1;
        end
    end
end


end