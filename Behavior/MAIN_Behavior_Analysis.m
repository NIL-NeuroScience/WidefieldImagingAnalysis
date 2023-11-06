%% Behavior Analysis Code
% This code calculates whisking as the motion energy of whisker pad and
% long whiskers. It also calculates changes in pupil diameter
% This code can be run by section or as an entire script

close all
clear all
clc

% Version 1.0 7/14/2023 - Dora Balog %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version 1.1 9/29/2023 - Patrick Doran

%% Mouse data - adjust info!

date = 'Raw-23-07-18'; 
mouse = 'Thy1_153';
run = 10;

%% Set up directories
root = fullfile('/projectnb/devorlab/pdoran/1P/',date,mouse,'basler',sprintf('Run%02i',run));% adjust root directory
save_folder = fullfile('/projectnb/devorlab/pdoran/1P/',date,mouse);% adjust save folder

%%
f_Test_Folder(save_folder)

%% Sort Files

% Natural-Order Filename Sort - MATLAB FCN
% alphanumeric sort of filenames
filenames = natsortfiles(dir(root));

%% Pupil
[pupil_raw, pupil_smooth] = pupil1P(root);

%% Whisker

[whisker_raw_pad, whisker_smooth_pad, whisker_raw_long, whisker_smooth_long] = whisking(root, save_folder, mouse, date, run);

%% Save
fname = fullfile(save_folder,sprintf('Run%02i_Behavior.mat',run));
save(fname,'pupil_raw','pupil_smooth','whisker_smooth_long','whisker_smooth_pad','whisker_raw_long','whisker_raw_pad');
