% Version 1.0 Patrick Doran 09/27/2023
%
% Must be run AFTER: MAIN_pre_rocessing.m, Draw_Cranial_Window_Mask.m,
% MAIN_Allen_Registration.m, MAIN_Interprolation_Corrected.m or MAIN_Interprolation_Uncorrected.m
%
% This code is meant to make plots for stimuli by extracting time courses
% from a brain region defined in the Allen Atlas. 
% This code is meant to be run BY SECTION. Do not run the entire script,
% run each section individually
clear
close all;
clc
%% Load Data
% Define where data is stored
Run = 10;
date = 'Raw-23-07-18';
mouse = 'Thy1_153';
root = fullfile('/projectnb/devorlab/pdoran/1P',date,mouse);
Neuromodulator = 'ACh';
Side = "Left"; % What hemisphere is stimulus response in?
ROI = "Primary Somatosensory Area: Barrel Field"; % What Allen region is the stimulus response in?

% Define file names
fname.Data = fullfile(root,'mat',sprintf('Run%i_Interporlated_TC.mat',Run));
fname.Mask = fullfile(root,'mat','Brain_Mask.mat');
fname.Allen = fullfile(root,'mat','Allen_Parcellation_Small.mat');
fname.DataIn = fullfile(root,'dataIn.mat');
fname.Figures = fullfile(root,'Figures','4');
f_Test_Folder(fname.Figures);

% Load data
load(fname.Data);
load(fname.Mask);
load(fname.Allen);
load(fname.DataIn);

% Only HbO and HbR are saved in interprolated data to save space because
% HbT = HbR + HbO
HbT_All_Runs = HbO_All_Runs+HbR_All_Runs;

% Here we get the custom colormap
cmap = colormap_blueblackred();
%% Subtract baseline Images
% For each repetition, the second before stimulus onset is defined as baseline.
% Baseline images are subtracted from each interprolated image in the data
% The cranial window mask is also applied here

% Here we are determining indicies for 1 second before stimulus onset and
% 0.1 seconds before stimulus onset. These times will be baseline
[~,Index1] = min(abs(tNew - (-1)));
[~,Index2] = min(abs(tNew-(-0.1)));

HbT_All_Runs = f_Subtract_Baseline_Apply_Mask(HbT_All_Runs,brain_mask,Index1,Index2);
HbR_All_Runs = f_Subtract_Baseline_Apply_Mask(HbR_All_Runs,brain_mask,Index1,Index2);
HbO_All_Runs = f_Subtract_Baseline_Apply_Mask(HbO_All_Runs,brain_mask,Index1,Index2);
Ca_All_Runs = f_Subtract_Baseline_Apply_Mask(Ca_All_Runs,brain_mask,Index1,Index2);
GRAB_All_Runs = f_Subtract_Baseline_Apply_Mask(GRAB_All_Runs,brain_mask,Index1,Index2);
%% Make micromollar and precentage
HbT_All_Runs = HbT_All_Runs*1e6;
HbO_All_Runs = HbO_All_Runs*1e6;
HbR_All_Runs = HbR_All_Runs*1e6;
Ca_All_Runs = Ca_All_Runs*100;
GRAB_All_Runs = GRAB_All_Runs*100;

%% Average across Stim
Ca_Avg = mean(Ca_All_Runs,4);
GRAB_Avg = mean(GRAB_All_Runs,4);
HbO_Avg = mean(HbO_All_Runs,4);
HbR_Avg = mean(HbR_All_Runs,4);
HbT_Avg = mean(HbT_All_Runs,4);

%% Define Allen region we want to extract time courses from
% Making ROI no space for file names
ROI_No_Space = ROI;
for letter = 1:strlength(ROI)
    if strcmp(ROI{1}(letter),' ')
        ROI_No_Space{1}(letter) = '_';
    end
end

% Find mask in parcellation structure
mask = f_Find_Allen_Mask(Side,ROI,parcellation);

% Create polynomial from mask using mask2poly function from Matlab Central
% https://www.mathworks.com/matlabcentral/fileexchange/32112-mask2poly
Poly = mask2poly(mask,'Exact');
Poly = Poly(2:end,:);
X_Points = Poly(:,1);
Y_Points = Poly(:,2);

% Make points outside mask NaN for extracting time series
mask = double(mask);
mask(mask==0) = NaN;

% Make figure showing the region we are using
tmphandle = figure;
imagesc(dataIn(Run).template(:,:,3).*brain_mask);
colormap("gray")
hold on;
plot(X_Points,Y_Points,'r','LineWidth',2)
tmpname = fullfile(fname.Figures,sprintf("%s_%s_LED525",Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,strcat(tmpname,".tif"));
saveas(tmphandle,strcat(tmpname,".svg"));

%% Plot stimulus averaged ratio maps at a certain time after stimulus start 
% This defines color scales that will be used in subsequent sections. Run
% this section one plot at a time with the rest of the plots commented out.
close all

% Calcium
% time_to_plot = 0.2;
% [~,tmpIndex] = min(abs(tNew-time_to_plot));
% tmphandle = figure;
% imagesc(Ca_Avg(:,:,tmpIndex));
% c = colorbar;
% c.Label.String = '\DeltaF/F';
% colormap(cmap);
% colors.Ca = [-10,10];
% caxis(colors.Ca);
% title(sprintf('%cCa t = %.1fs',916,time_to_plot));
% set(gca,'XTick',[],'YTick',[],'FontSize',18);
% hold on;
% plot(X_Points,Y_Points,'g','LineWidth',1.5)
% tmpname = fullfile(fname.Figures,sprintf('T%i%iRun%iCalciumMap',floor(time_to_plot),round(10*(time_to_plot-floor(time_to_plot))),Run));
% savefig(tmphandle,tmpname);
% saveas(tmphandle,[tmpname '.tif']);
% saveas(tmphandle,[tmpname '.svg']);

% % HbO
% time_to_plot = 2;
% [~,tmpIndex] = min(abs(tNew-time_to_plot));
% tmphandle = figure;
% imagesc(HbO_Avg(:,:,tmpIndex));
% c = colorbar;
% c.Label.String = '\muM';
% colormap(cmap);
% colors.HbO = [-5,5];
% caxis(colors.HbO);
% title(sprintf('%cHbO t = %0.1f s',916,time_to_plot));
% set(gca,'XTick',[],'YTick',[],'FontSize',18);
% tmpname = fullfile(fname.Figures,sprintf('T%i%iRun%iHbOMap',floor(time_to_plot),round(10*(time_to_plot-floor(time_to_plot))),Run));
% savefig(tmphandle,tmpname);
% saveas(tmphandle,[tmpname '.tif']);
% saveas(tmphandle,[tmpname '.svg']);
% 
% % HbT
% time_to_plot = 2;
% [~,tmpIndex] = min(abs(tNew-time_to_plot));
% tmphandle = figure;
% imagesc(HbT_Avg(:,:,tmpIndex));
% c = colorbar;
% c.Label.String = '\muM';
% colormap(cmap)
% colors.HbT = [-3,3];
% caxis(colors.HbT);
% title(sprintf('%cHbT t = %0.1fs',916,time_to_plot));
% set(gca,'XTick',[],'YTick',[],'FontSize',18);
% tmpname = fullfile(fname.Figures,sprintf('T%i%iRun%iHbTMap',floor(time_to_plot),round(10*(time_to_plot-floor(time_to_plot))),Run));
% savefig(tmphandle,tmpname);
% saveas(tmphandle,[tmpname '.tif']);
% saveas(tmphandle,[tmpname '.svg']);

% % -1 * HbR = BOLD Proxy
% close all
% time_to_plot = 2;
% [~,tmpIndex] = min(abs(tNew-time_to_plot));
% tmphandle = figure;
% imagesc(-1*HbR_Avg(:,:,tmpIndex));
% c = colorbar;
% c.Label.String = '\muM';
% colormap(cmap)
% colors.BOLD = [-6,6];
% caxis(colors.BOLD);
% title(sprintf('BOLD Proxy t = %0.1fs',time_to_plot));
% set(gca,'XTick',[],'YTick',[],'FontSize',18);
% tmpname = fullfile(fname.Figures,sprintf('T%i%iRun%iBOLDMap',floor(time_to_plot),round(10*(time_to_plot-floor(time_to_plot))),Run));
% savefig(tmphandle,tmpname);
% saveas(tmphandle,[tmpname '.tif']);
% 
% % GRAB
% close all
time_to_plot = 2;
[~,tmpIndex] = min(abs(tNew-time_to_plot));
tmphandle = figure;
imagesc(GRAB_Avg(:,:,tmpIndex));
c = colorbar;
c.Label.String = '\DeltaF/F';
colormap(cmap)
colors.GRAB = [-4,4];
caxis(colors.GRAB);
title(sprintf('%s t = %.1fs',Neuromodulator,time_to_plot));
set(gca,'XTick',[],'YTick',[],'FontSize',18);
tmpname = fullfile(fname.Figures,sprintf('T%i%iRun%iGRABMap',floor(time_to_plot),round(10*(time_to_plot-floor(time_to_plot))),Run));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);
saveas(tmphandle,[tmpname '.svg']);
%% Plot Stimuli across time (6 time points per figure)

% Define time points to plot here. Short time points for calcium that is
% faster. Long time points for hemodynamics
Times.Long = 0.1:0.8:4.1;
Times.Short = 0.1:0.1:0.6;

%Plot HbT Time Points Long
tmphandle = figure('Units','normalized','Position',[0.0021,0.0809,0.8831,0.7613]);
cntr = 1;
tile_plot = tiledlayout(2,3);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,3);
for time = Times.Long
    [~,tmpIndex] = min(abs(tNew-(time)));
    ax(cntr) = nexttile(cntr);
    cntr = cntr+1;
    imagesc(HbT_Avg(:,:,tmpIndex));
    c = colorbar;
    c.Label.String = '\muM';
    colormap(cmap)
    caxis(colors.HbT);
    title(sprintf('%cHbT t = %0.1fs',916,time));
    set(gca,'XTick',[],'YTick',[],'FontSize',18);
end
tmpname = fullfile(fname.Figures,sprintf('Run%iHbTMuliMaps',Run));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

% % 
% % % Plot HbO Time Points Long
tmphandle = figure('Units','normalized','Position',[0.0021,0.0809,0.8831,0.7613]);
cntr = 1;
tile_plot = tiledlayout(2,3);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,3);
for time = Times.Long
    [~,tmpIndex] = min(abs(tNew-(time)));
    ax(cntr) = nexttile(cntr);
    cntr = cntr+1;
    imagesc(HbO_Avg(:,:,tmpIndex));
    c = colorbar;
    c.Label.String = '\muM';
    colormap(cmap)
    caxis(colors.HbO);
    title(sprintf('%cHbO t = %0.1fs',916,time));
    set(gca,'XTick',[],'YTick',[],'FontSize',18);
end
tmpname = fullfile(fname.Figures,sprintf('Run%iHbOMuliMaps',Run));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

% % 
% % % Plot HbR (BOLD Proxy) Time Points Long
tmphandle = figure('Units','normalized','Position',[0.0021,0.0809,0.8831,0.7613]);
cntr = 1;
tile_plot = tiledlayout(2,3);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,3);
for time = Times.Long
    [~,tmpIndex] = min(abs(tNew-(time)));
    ax(cntr) = nexttile(cntr);
    cntr = cntr+1;
    imagesc(-1.*HbR_Avg(:,:,tmpIndex));
    c = colorbar;
    c.Label.String = '\muM';
    colormap(cmap)
    caxis(colors.BOLD);
    title(sprintf('BOLD Proxy t = %0.1fs',time));
    set(gca,'XTick',[],'YTick',[],'FontSize',18);
end
tmpname = fullfile(fname.Figures,sprintf('Run%iBOLDMuliMaps',Run));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

% Plot GRAB Time Points Long
tmphandle = figure('Units','normalized','Position',[0.0021,0.0809,0.8831,0.7613]);
cntr = 1;
tile_plot = tiledlayout(2,3);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,3);
for time = Times.Long
    [~,tmpIndex] = min(abs(tNew-(time)));
    ax(cntr) = nexttile(cntr);
    cntr = cntr+1;
    imagesc(GRAB_Avg(:,:,tmpIndex));
    c = colorbar;
    c.Label.String = '\DeltaF/F';
    colormap(cmap)
    caxis(colors.GRAB);
    title(sprintf('%s t = %0.1fs',Neuromodulator,time));
    set(gca,'XTick',[],'YTick',[],'FontSize',18);
end
tmpname = fullfile(fname.Figures,sprintf('Run%iGRABMuliMaps',Run));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

% % % Plot Calcium Time Points Long
tmphandle = figure('Units','normalized','Position',[0.0021,0.0809,0.8831,0.7613]);
cntr = 1;
tile_plot = tiledlayout(2,3);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,3);
for time = Times.Long
    [~,tmpIndex] = min(abs(tNew-(time)));
    ax(cntr) = nexttile(cntr);
    cntr = cntr+1;
    imagesc(Ca_Avg(:,:,tmpIndex));
    c = colorbar;
    c.Label.String = '\DeltaF/F';
    colormap(cmap);
    caxis(colors.Ca);
    title(sprintf('Ca2+ t = %0.1fs',time));
    set(gca,'XTick',[],'YTick',[],'FontSize',18);
end
tmpname = fullfile(fname.Figures,sprintf('Run%iCalciumMuliMapsLong',Run));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

% % % Plot Calcium Time Points short
tmphandle = figure('Units','normalized','Position',[0.0021,0.0809,0.8831,0.7613]);
cntr = 1;
tile_plot = tiledlayout(2,3);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,3);
for time = Times.Short
    [~,tmpIndex] = min(abs(tNew-(time)));
    ax(cntr) = nexttile(cntr);
    cntr = cntr+1;
    imagesc(Ca_Avg(:,:,tmpIndex));
    c = colorbar;
    c.Label.String = '\DeltaF/F';
    colormap(cmap)
    caxis(colors.Ca);
    title(sprintf('Ca2+ t = %0.1fs',time));
    set(gca,'XTick',[],'YTick',[],'FontSize',18);
end
tmpname = fullfile(fname.Figures,sprintf('Run%iCalciumMuliMapsShort',Run));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);
%% Make Time Courses for Allen Region
% Stimulus averaged time course
GRABTC = f_timeCourse(GRAB_Avg,mask);
CaTC = f_timeCourse(Ca_Avg,mask);
HbTTC = f_timeCourse(HbT_Avg,mask);
HbOTC = f_timeCourse(HbO_Avg,mask);
HbRTC = f_timeCourse(HbR_Avg,mask);

% Individual Stimulus Presentation Time Courses
All_TCs.GRAB = f_timeCourse_Stimuli(GRAB_All_Runs,mask);
All_TCs.Ca = f_timeCourse_Stimuli(Ca_All_Runs,mask);
All_TCs.HbO = f_timeCourse_Stimuli(HbO_All_Runs,mask);
All_TCs.HbR = f_timeCourse_Stimuli(HbR_All_Runs,mask);
All_TCs.HbT = f_timeCourse_Stimuli(HbT_All_Runs,mask);

%% plot Stimulus Averaged Time Courses
tmphandle = figure;
ax = gca;
yyaxis right;
plot(tNew,HbTTC,'k-','LineWidth',2);
hold on;
yyaxis right;
plot(tNew,HbRTC,'b-','LineWidth',2);
yyaxis right;
plot(tNew,HbOTC,'r-','LineWidth',2);
ax.YColor = 'k';
ylabel('\DeltaC (\muM)')
ylim([-3,6]) % Ylimit for hemodynamics
yyaxis left;
ylabel('\DeltaF/F','FontSize',18);
plot(tNew,CaTC,'m-','LineWidth',2);
yyaxis left
plot(tNew,GRABTC,'g-','LineWidth',2)
 ylim([-3,6]) % Ylimit for fluorescence 
 xlim([-1,8]);
title('Hemodynamic Response To Stimulus')
xlabel('Time (s)')
set(gca,'FontSize',18);
legend('Ca2+',Neuromodulator,'\DeltaHbT','\DeltaHbR','\DeltaHbO','FontSize',12)
ax = gca;
ax.YColor = 'k';
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%s_TC',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);
saveas(tmphandle,[tmpname '.svg']);

%% 2D Waterfalls sorted by Similarity
% Sort stimulus presentations by maximum calcium df/f between start time
% and end time relative to stimulus (ie. 0-5 is within 5 sec after
% sitmulus)
StartTime = 0;
[~,tmpIndex1] = min(abs(tNew-StartTime));
EndTime = 8;
[~,tmpIndex2] = min(abs(tNew-EndTime));
tmp = max(All_TCs.Ca(:,tmpIndex1:tmpIndex2)');
[~,Similarity_Index] = sort(tmp);
nRep = size(HbR_All_Runs,4);

% Calcium Plots
LineWidth = 0.5; % For all figures
Offset = 3;
tmphandle = figure('Units','normalized','Position',[0.3883,-0.0633,0.563,0.8717]);
plot(tNew,All_TCs.Ca(Similarity_Index(1),:),'m','LineWidth',LineWidth);
hold on;
for iRep = 2:nRep
    plot(tNew,All_TCs.Ca(Similarity_Index(iRep),:)+(iRep*Offset),'m','LineWidth',LineWidth);
end
xlim([-1,8])
title("Calcium Waterfall Plots");
xlabel("Time (s)")
set(gca,'YTick',[],'FontSize',18);
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%s_Calcium_Waterfall_Similarity_Sorted',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);
saveas(tmphandle,[tmpname '.svg'])

% GRAB Plots
Offset = 3;
tmphandle = figure('Units','normalized','Position',[0.3883,-0.0633,0.563,0.8717]);
plot(tNew,All_TCs.GRAB(Similarity_Index(1),:),'g','LineWidth',LineWidth);
hold on;
for iRep = 2:nRep
    plot(tNew,All_TCs.GRAB(Similarity_Index(iRep),:)+(iRep*Offset),'g','LineWidth',LineWidth);
end
xlim([-1,8])
title("ACh Waterfall Plots");
xlabel("Time (s)")
set(gca,'YTick',[],'FontSize',18);
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%s_ACh_Waterfall_Similarity_Sorted',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);
saveas(tmphandle,[tmpname '.svg']);

% HbT Plots
Offset = 1.5;
tmphandle = figure('Units','normalized','Position',[0.3883,-0.0633,0.563,0.8717]);
plot(tNew,All_TCs.HbT(Similarity_Index(1),:),'k','LineWidth',LineWidth);
hold on;
for iRep = 2:nRep
    plot(tNew,All_TCs.HbT(Similarity_Index(iRep),:)+(iRep*Offset),'k','LineWidth',LineWidth);
end
xlim([-1,8])
title("HbT Waterfall Plots");
xlabel("Time (s)")
set(gca,'YTick',[],'FontSize',18);
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%s_HbT_Waterfall_Similarity_Sorted',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);
saveas(tmphandle,[tmpname '.svg']);

