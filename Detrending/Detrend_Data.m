% Version 1.0 Patrick Doran 09/27/2023
%
% Must be run AFTER: MAIN_pre_rocessing.m, Draw_Cranial_Window_Mask.m
%
% This corrects for photobleaching for every pixel RFP and GFP
% Choose from Type 1 = fit exponential decay function to each pixel and
% regress out
% Type 2 = matlab detrend function on each pixel. 
%
% This script uses parrallel processing!

%% load data
% Define where data is located
clear;
clc;
date = 'Raw-23-07-18';
mouse = 'Thy1_153';
Run = 10;
root = fullfile('/projectnb/devorlab/pdoran/1P',date,mouse);

% Define Correction Settings
Correction_Settings.Version = 1; % If multiple corrections increase version
Correction_Settings.rfp.Correct = 1; % Set to 1 to correct Calcium
Correction_Settings.gfp.Correct = 1;% Set to 1 to correct GRAB
Correction_Settings.rfp.Type = 1; % Type 1 is Exponential Decay fit, type 2 is detrending
Correction_Settings.gfp.Type = 1;

% Define File Names
fname.Triggers = fullfile(root,'Triggers',sprintf('Run%03i.mat',Run));
fname.Data = fullfile(root,'processed',sprintf('run%04i.h5',Run));
fname.Mask = fullfile(root,'mat','Brain_Mask.mat');
fname.SaveData = fullfile(root,'processed',sprintf('run%04i_CorrectedV%i.h5',Run,Correction_Settings.Version));
fname.SaveSettings = fullfile(root,'mat',sprintf('CorrectionSettings_Run%i_V%i',Run,Correction_Settings.Version));

% Load data 
load(fname.Triggers);
load(fname.Mask);
rfp_norm = h5read(fname.Data,'/rfp/norm');
gfp_normHD = h5read(fname.Data,'/gfp/normHD');
%% Calculate Timing of GRAB and jRGECO frames 
[tGRAB,tjRGECO] = fTime_Calculation_Detrend(digitalInput,settings);
%% Apply Brain Mask
for index = 1:size(rfp_norm,3)
    rfp_norm(:,:,index) = rfp_norm(:,:,index).*brain_mask;
    gfp_normHD(:,:,index) = gfp_normHD(:,:,index).*brain_mask;
end
%% Correction
fprintf('\nBeggining Correction\n');
% RFP Correction
rfp_norm = f_Correct(rfp_norm,tjRGECO,Correction_Settings,'rfp');
fprintf('\nDone with RFP correction!\n');

% Do GFP correction
gfp_normHD = f_Correct(gfp_normHD,tGRAB,Correction_Settings,'gfp');
%% Save
fprintf('\nCorrection Finished\nSaving now\n');
h5create(fname.SaveData,'/gfp/normHD',size(gfp_normHD),'Deflate',0,'Chunksize',[size(gfp_normHD,1) size(gfp_normHD,2) 100])
h5create(fname.SaveData,'/rfp/norm',size(rfp_norm),'Deflate',0,'Chunksize',[size(rfp_norm,1) size(rfp_norm,2) 100])
h5write(fname.SaveData,'/rfp/norm',rfp_norm);
h5write(fname.SaveData,'/gfp/normHD',gfp_normHD)
save(fname.SaveSettings,'Correction_Settings');


