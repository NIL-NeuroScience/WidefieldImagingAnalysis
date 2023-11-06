% Patrick Doran VERSION 11/06/2023
% This is used to analyze the effect that strobing the LEDs has on pupil
% size. This script determines during whch behavior frames the LEDs
% turn on and then makes a matrix of pupil size change around this off
% to on transition. The size right before the LEDs turn on is taken as the
% baseline and subtracted from each run and then the runs are averaged
% together to plot average change in pupil diameter. Pupil ratio is
% calculated as the ratio of pupil size right after LEDs are on to the
% pupil size right before. 

clear
clc
close all
%% load data
% Where is the data located?
date = '23-10-19';
mouse = 'Thy1_152_No_Cone';
Run = 3;
root = fullfile('/projectnb/devorlab/pdoran/1P',date,mouse);

f_Test_Folder(fullfile(root,'mat'));

% Define File Names
fname.behavior =  fullfile(root,'mat',sprintf('Run%02i_Behavior.mat',Run));
fname.triggers =  fullfile(root,'Triggers',sprintf('Run%03i.mat',Run));
fname.Save = fullfile(root,'mat','Pupil_Matrix.mat');
fname.Figures = fullfile(root,'Figures','8');
f_Test_Folder(fname.Figures);

% Load data
load(fname.behavior);
load(fname.triggers);
t = 0:1/10:(length(pupil_raw)-1)/10;
%% Make tNew. This is time relative to imaging start you want to make time course
Time_Before = -31; % seconds: How long before imaging start do you want to go. Make this negative
Time_After = 91; % seconds: How long after Imaging start do you want to go
fs = 10; % Hz: Acqusition frequency 
tNew = Time_Before:1/fs:Time_After;
%% Find which behavior frames the LEDs are on for
Basler_Imaging_Frames = f_Imaging_Frames(digitalInput,settings);
nReps = size(Basler_Imaging_Frames,1);

%% Make pupil matrix
Start_Pupil_Matrix = f_Pupil_Matrix(tNew,Basler_Imaging_Frames,pupil_smooth);
Start_Pupil_Avg = mean(Start_Pupil_Matrix);

%% Remove Baseline
Start_Pupil_Matrix2 = zeros(size(Start_Pupil_Matrix));
Baseline_Times = [-1,-0.2];
[~,Baseline_Index(1)] = min(abs(tNew-Baseline_Times(1)));
[~,Baseline_Index(2)] = min(abs(tNew-Baseline_Times(2)));
BaselineValues = zeros(1,nReps);
for iRep = 1:nReps
    tmpStart = Start_Pupil_Matrix(iRep,:);
    BaselineValues(iRep) = mean(tmpStart(Baseline_Index(1):Baseline_Index(2)));
    Start_Pupil_Matrix2(iRep,:) = tmpStart - BaselineValues(iRep);
end
Start_Pupil_Avg2 = mean(Start_Pupil_Matrix2);
Start_Pupil_STD2 = std(Start_Pupil_Matrix2);

%% Make Pupil Ratio Distribution
Before_Times = [-1.5,-0.5]; % Times before LED on for pupil ratio
After_Times = [2,3]; % Times after LED on for pupil ratio
[~,Before_Index(1)] = min(abs(tNew-Before_Times(1)));
[~,Before_Index(2)] = min(abs(tNew-Before_Times(2)));
[~,After_Index(1)] = min(abs(tNew-After_Times(1)));
[~,After_Index(2)] = min(abs(tNew-After_Times(2)));
Before_Avg = zeros(1,nReps);
After_Avg = zeros(1,nReps);
Pupil_Ratio =  zeros(1,nReps);
for index = 1:nReps
    Before_Avg(index) = mean(squeeze(Start_Pupil_Matrix(index,Before_Index(1):Before_Index(2))));
    After_Avg(index) = mean(squeeze(Start_Pupil_Matrix(index,After_Index(1):After_Index(2))));
    Pupil_Ratio(index) = After_Avg(index)/Before_Avg(index);
end

%%
save(fname.Save,'Start_Pupil_Matrix','Start_Pupil_Matrix2','BaselineValues','tNew','Pupil_Ratio');

%% Plot average change after imaging start
TimesStart = [-1,10]; % Times to plot
LineWidth = 2;
FontSize = 15;
Start_NsD2 = Start_Pupil_Avg2 + Start_Pupil_STD2;
Start_PsD2 = Start_Pupil_Avg2 - Start_Pupil_STD2;

% Imaging Start Average
tmphandle = figure;
plot(tNew,Start_Pupil_Avg2,'k','LineWidth',LineWidth);
hold on;
patch([tNew fliplr(tNew)],[Start_PsD2 fliplr(Start_NsD2)],'k','FaceAlpha',0.1,'EdgeColor','none');
title("Cone Imaging Start");
xlabel("Time (s)");
ylabel("A.U.");
set(gca,'FontSize',FontSize);
xlim(TimesStart);
ylim([-0.7,0.1])
tmpname = fullfile(fname.Figures,'Imaging_Start_Pupil_Avg_STDEV');
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);
saveas(tmphandle,[tmpname '.svg']);


%% Plot individual Runs
Run = 1;
tmphandle = figure('Position',[59,246,1650,240]);
plot(tNew,Start_Pupil_Matrix2(Run,:),'k');
xlim([-30,90]);
title(sprintf("Run %i Pupil",Run))
xlabel("Time (s)");
tmpname = fullfile(fname.Figures,sprintf("Run%i_Pupil_Change",Run));
savefig(tmphandle,tmpname);

