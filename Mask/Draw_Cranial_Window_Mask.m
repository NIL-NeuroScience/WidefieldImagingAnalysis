% Version 1.0 Patrick Doran 09/27/2023
clear;
clc;
close all

%% Load Data
Run = 10; % The image from this run will be used for drawing the window
LED = 525; % LED to use for drawing mask
date = 'Raw-23-07-18';
mouse = 'Thy1_153';
root = fullfile('/projectnb/devorlab/pdoran/1P',date,mouse);

fname.Save = fullfile(root,'mat','Brain_Mask.mat');
fname.Data = fullfile(root,'dataIn.mat');

f_Test_Folder(fullfile(root,'mat')); % Make sure this folder exists

load(fname.Data);
%% Get Image
nLED = size(dataIn(Run).led,2);
for iLED = 1:nLED
    if dataIn(Run).led(iLED).type == LED
        image = dataIn(Run).template(:,:,iLED);
    end
end
%% Draw brain hemisphere masks
nHemisphere = 2;
% Make masks of each hemisphere and then add them together
hemisphere_masks = zeros(size(image,1),size(image,2),nHemisphere);
brain_mask = zeros(size(image,1),size(image,2));
for hemisphere = 1:nHemisphere
    input_value = 0;
    % This while loop allows you to redraw the mask as many times as you
    % want if you make a mistake
    while input_value == 0
        imshow(image,[]);
        if hemisphere ==1
            title('Draw Left Hemisphere','FontSize',18);
            % It doesn't matter which order you draw the
            % hemispheres 
        else
            title('Draw Right Hemisphere','FontSize',18)
        end
        roi = drawpolygon;
        hemisphere_masks(:,:,hemisphere) = createMask(roi);
        tmp = 1;
        while tmp
            answer = input("Are you satisfied with mask? 0 = no, 1 = yes\n");
            % If you don't put 1 or 0 it will keep asking the question
            if answer == 0
                tmp = 0;
            end
            if answer == 1
                input_value = 1;
                tmp = 0;
            end
        end
    end
    brain_mask = brain_mask + hemisphere_masks(:,:,hemisphere); % Conbine hemisphere masks to make final mask
end

% Here we make everything outside the mask NaN
brain_mask = double(brain_mask);
brain_mask(brain_mask==0) = NaN;

save(fname.Save,'brain_mask');



