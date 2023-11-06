% Patrick Doran version 09/25/2023
%
% Must be run AFTER: MAIN_pre_rocessing.m, Draw_Cranial_Window_Mask.m
%
% Use this script to interprolate timiming of data relative to stimulus
% onset. Whenever the data was collected, this will interprolate the data
% at exact stimulus onset, 0.1 seconds after stimulus onset, 0.2 seconds
% after stimulus onset etc for each stimulus presentation. Only use this
% for airpuff stimuli with triggers created by mesoscope acquisition code.
% This is for raw data before detrending
clear;
clc;
%% Load Data
% Parmaeters Requiring User Input
Interp_Parameters.TimeBeforeStim = 5; % s Time to interprolate before stimulus onset
Interp_Parameters.TimeAfterStim = 15; % s Time to interprolate after stimulus onset
date = 'Raw-23-07-18';
mouse = 'Thy1_153';
root = fullfile('/projectnb/devorlab/pdoran/1P',date,mouse);
Run = 10;

% Define File Names
fname.Data = fullfile(root,'processed',sprintf('run%04i.h5',Run));
fname.Time = fullfile(root,'Triggers',sprintf('Run%03i.mat',Run));
fname.Mask = fullfile(root,'mat','Brain_Mask.mat');
fname.save = fullfile(root,'mat',sprintf('Run%i_Interporlated_TC.mat',Run));

% Load Data
load(fname.Mask);
load(fname.Time);
rfp_norm=h5read(fname.Data,'/rfp/norm');
gfp_normHD=h5read(fname.Data,'/gfp/normHD');
HbO=h5read(fname.Data,'/hemodynamics/HbO');
HbR=h5read(fname.Data,'/hemodynamics/Hb');
%% Get times of when each measurement and each stimulus occurs
% This function gets timing for each wavelength and stimulus
[tHb,tGRAB,tjRGECO,Interp_Parameters.tStim] = fTime_Calculation(digitalInput,settings);

% Define number of repetitions and image size
Interp_Parameters.iRep = size(Interp_Parameters.tStim,1);
Interp_Parameters.SizeY = size(HbO,1);
Interp_Parameters.SizeX = size(HbO,2);
clear tmp*
%% Apply Brain Mask
for index = 1:size(HbO,3)
    HbO(:,:,index) = HbO(:,:,index).*brain_mask;
    HbR(:,:,index) = HbR(:,:,index).*brain_mask;
    rfp_norm(:,:,index) = rfp_norm(:,:,index).*brain_mask;
    gfp_normHD(:,:,index) = gfp_normHD(:,:,index).*brain_mask;
end
%% Do Interprolation 
% Define T New: These time points will be interprelated from actual measurments
tNew = (-1*Interp_Parameters.TimeBeforeStim):(1/settings.fs):Interp_Parameters.TimeAfterStim;
Interp_Parameters.tNew = tNew;

% RFP
fprintf('\nBeggining RFP Interprolation\n');
Ca_All_Runs = fInterprolation(rfp_norm,tjRGECO,'RFP',Interp_Parameters);

% GFP
fprintf('\nDone with RFP Interprolation\nBeggining GFP Interprolation\n');
GRAB_All_Runs = fInterprolation(gfp_normHD,tGRAB,'GFP',Interp_Parameters);

% HbO
fprintf('\nDone with GFP Interprolation\nBeggining HbO Interprolation\n');
HbO_All_Runs = fInterprolation(HbO,tHb,'HbO',Interp_Parameters);

% HbR
fprintf('\nDone with HbO Interprolation\nBeggining HbR Interprolation\n');
HbR_All_Runs = fInterprolation(HbR,tHb,'HbR',Interp_Parameters);
fprintf('\nDone with all Interprolation!\nSaving\n');

%% Save Intreprolated data
save(fname.save,"HbR_All_Runs","HbO_All_Runs","GRAB_All_Runs",'Ca_All_Runs','tNew','-v7.3');


