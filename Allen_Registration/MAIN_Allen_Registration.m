%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                   Allen Atlas Registration
%
% Version 1.0 Harrison Fisher 12/19/2021
% Version 1.1 Patrick Doran   03/31/2022
% Version 1.2 Sreekanth Kura  07/19/2023
% Version 1.3 Patrick Doran   09/26/2023
%
% Must be run AFTER: MAIN_pre_rocessing.m, Draw_Cranial_Window_Mask.m
%
% To Use this code, in the first window pick Bregma as marked on the skull
% by the surgeon then pick any point on the Allen atlas brain. Then pick
% lambda as marked by the surgeon and pick any point on the Allen atlas
% brain. The locations of bregma and lambda in the Allen atals are hard
% coded into the code. An App allows refinement of the registration. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
clc;
close all
%% Load Data
% Define file locations
Tolerence = 0.25; % Percentage of region that must be in cranial window
% ie. if tolerence is 0.25 then a region will be included in the
% parcelation if at least 25% of it is in the cranial window defined by the
% mask
date = 'Raw-23-07-18';
mouse = 'Thy1_153';
root = fullfile('/projectnb/devorlab/pdoran/1P',date,mouse);
Run = 10;
fname.Triggers = fullfile(root,'Triggers',sprintf('Run%03i.mat',Run));
fname.dataIn = fullfile(root,'dataIn.mat');
fname.Mask = fullfile(root,'mat','Brain_Mask.mat');
fname.Save = fullfile(root,'mat','Allen_Parcellation_Small.mat');

% Load Data
load(fname.Triggers);
load(fname.dataIn);
load(fname.Mask);
%% Find Index of LED you want to use for registration
% LED 625 reccomended becasue it is easiest to see Bregma and Lambda marks
nLED = size(dataIn(Run).settings.LEDOrder,1);
LED_to_Use = '625';
for iLED = 1:nLED
    if strcmp(LED_to_Use,dataIn(Run).settings.LEDOrder(iLED,:))
        Index = iLED;
    end
end

tmpIn = double(dataIn(Run).template(:,:,Index));
tmpIn = uint16(tmpIn);

%% Overlay Allen atlas regions
new_registration = 1;

% This loop allows the user to repeat registration if they are not
% satisfied
while new_registration
% Need to have tmpIn without mask for initial registration because Bregma
% and lambda marks would be covered by the mask of the window. This
% function aligns the data to the Allen atlas
f_Do_Registration(tmpIn,brain_mask);

% Registration finishes with the mask applied so that region boundaries
% will end at the boundry of the cranial window 
tmpIn = double(tmpIn).*brain_mask;
tmpIn = uint16(tmpIn);
% This function makes masks of the Allen atlas regions based on the
% registration done in the previous function
parcellation = f_Finish_Registration(tmpIn,FinalTform,Tolerence);
x = questdlg('Are you Satisfied with the registration?','Redo Registration','Yes','No','Yes');
if length(x) == 3   
    new_registration = 0;
end
end
clearvars tmp* i*


save(fname.Save,"parcellation");
