function  f_ParcelPlot(parcellation,image)
% Version 1.0 Patrick Doran   03/31/2022
% Version 1.1 Patrick Doran   10/03/2023
% This function plots the location of parcels on an image

value = max(max(image));

matrix = parcellation.LeftROIs(:,:,1);
tmp = double(image);
tmp(matrix>0.5) = value;
f = figure;
img = imagesc(tmp,[0,value]);
colormap('gray');
title(['Left ' sprintf(char(parcellation.LeftValidFull(1)))],'FontSize',18);
y = input('Press enter for next parcel\n');

for x = 2:length(parcellation.LeftValid)
    matrix = parcellation.LeftROIs(:,:,x);
    tmp = double(image);
    tmp(matrix > 0.5) = value;
    set(img,'CData',tmp);
    title(['Left ' sprintf(char(parcellation.LeftValidFull(x)))],'FontSize',18);
    y = input('Press enter for next parcel\n');
end

for x = 1:length(parcellation.RightValid)
    matrix = parcellation.RightROIs(:,:,x);
    tmp = double(image);
    tmp(matrix > 0.5) = value;
    set(img,'CData',tmp);
    title(['Right ' sprintf(char(parcellation.RightValidFull(x)))],'FontSize',18);
    y = input('Press enter for next parcel\n');
end
    
end