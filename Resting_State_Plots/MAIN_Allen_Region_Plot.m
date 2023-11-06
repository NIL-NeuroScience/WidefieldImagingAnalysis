% Version 1.0 Patrick Doran 09/28/2023
%
% Must be run AFTER: MAIN_pre_rocessing.m, Draw_Cranial_Window_Mask.m,
% MAIN_Allen_Registration.m
%
% This code can be used to plot resting state time courses from a region of
% the Allen Atlas
clear;
clc;

%% Load Data
% Parameters changed by user. Where is the data
date = 'Raw-23-07-18';
mouse = 'Thy1_153';
Side = "Left"; % Choose hemisphere of the Allen Atlas region
ROI = "Primary Somatosensory Area: Barrel Field"; % Choose the Allen Atlas region
gfp_HD = 1; % We use GFP with hemodynamic correction when this is 1
Run = 10;
Correction_Version = 0; % Set to 0 to run without detrending or photobleaching correction
root = fullfile('/projectnb/devorlab/pdoran/1P/',date,mouse);

% Define file names
fname.DataCorrected = fullfile(root,'processed',sprintf('run%04i_CorrectedV%i.h5',Run,Correction_Version));
fname.DataUncorrected = fullfile(root,'processed',sprintf('run%04i.h5',Run));
fname.Triggers = fullfile(root,'Triggers',sprintf('Run%03i.mat',Run));
fname.Mask = fullfile(root,'mat','Brain_Mask.mat');
fname.CorrectionSettings = fullfile(root,'mat',sprintf('CorrectionSettings_Run%i_V%i',Run,Correction_Version));
fname.Allen = fullfile(root,'mat','Allen_Parcellation_Small.mat');
fname.dataIn = fullfile(root,'dataIn.mat');
fname.Figures = fullfile(root,'Figures','1');
f_Test_Folder(fname.Figures);
f_Test_Folder(fullfile(root,'mat'));

% Load data
load(fname.Triggers);
load(fname.Mask);
load(fname.Allen);
load(fname.dataIn);
if Correction_Version ~= 0
    load(fname.CorrectionSettings);
    if Correction_Settings.rfp.Correct
        rfp_norm=h5read(fname.DataCorrected,'/rfp/norm');
    else
        rfp_norm=h5read(fname.DataUncorrected,'/rfp/norm');
    end
    if Correction_Settings.gfp.Correct
        if gfp_HD
            gfp_norm = h5read(fname.DataCorrected,'/gfp/normHD');
        else
            gfp_norm = h5read(fname.DataCorrected,'/gfp/norm');
        end
    else
        if gfp_HD
            gfp_norm = h5read(fname.DataUncorrected,'/gfp/normHD');
        else
            gfp_norm = h5read(fname.DataUncorrected,'/gfp/norm');
        end
    end
else
    rfp_norm=h5read(fname.DataUncorrected,'/rfp/norm');
    if gfp_HD
        gfp_norm = h5read(fname.DataUncorrected,'/gfp/normHD');
    else
        gfp_norm = h5read(fname.DataUncorrected,'/gfp/norm');
    end
end
HbO=h5read(fname.DataUncorrected,'/hemodynamics/HbO');
HbR=h5read(fname.DataUncorrected,'/hemodynamics/Hb');
HbT = HbO+HbR;
Raw_Images = dataIn(Run).template;
%% Make hemodymaics micromollar and fluorescence percentage
HbO = HbO * 1e6;
HbR = HbR * 1e6;
HbT = HbT * 1e6;
rfp_norm = rfp_norm * 100;
gfp_norm = gfp_norm * 100;
%% Apply Brain Mask
for index = 1:size(HbO,3)
    HbO(:,:,index) = HbO(:,:,index).*brain_mask;
    HbR(:,:,index) = HbR(:,:,index).*brain_mask;
    HbT(:,:,index) = HbT(:,:,index).*brain_mask;
    rfp_norm(:,:,index) = rfp_norm(:,:,index).*brain_mask;
    gfp_norm(:,:,index) = gfp_norm(:,:,index).*brain_mask;
end
%% Find Index of LED you want for plotting the region you choose
% LED 525 reccomended 
nLED = size(dataIn(Run).settings.LEDOrder,1);
LED_to_Use = '525';
for iLED = 1:nLED
    if strcmp(LED_to_Use,dataIn(Run).settings.LEDOrder(iLED,:))
        Index = iLED;
    end
end

%% Make poly and plot desired ROI 
% Make ROI no space for file names
ROI_No_Space = ROI;
for letter = 1:strlength(ROI)
    if strcmp(ROI{1}(letter),' ')
        ROI_No_Space{1}(letter) = '_';
    end
end

% Find mask in parcellation structure
[mask,ROIShort] = f_Find_Allen_Mask(Side,ROI,parcellation);

% Create polynomial from mask using mask2poly function from Matlab Central
% https://www.mathworks.com/matlabcentral/fileexchange/32112-mask2poly
Poly = mask2poly(mask,'Exact');
Poly = Poly(2:end,:);
X_Points = Poly(:,1);
Y_Points = Poly(:,2);

% Make points outside mask NaN for extracting time series
mask = double(mask);
mask(mask==0) = NaN;

% Make figure showing the region 
tmphandle = figure;
imagesc(Raw_Images(:,:,iLED).*brain_mask);
colormap("gray")
hold on;
plot(X_Points,Y_Points,'r','LineWidth',2)
tmpname = fullfile(fname.Figures,sprintf("%s_%s_LED_%s",Side,ROI_No_Space,LED_to_Use));
savefig(tmphandle,tmpname);
saveas(tmphandle,strcat(tmpname,".tif"));
saveas(tmphandle,strcat(tmpname,".svg"));

%% Make Time Courses
t = 0:(1/settings.fs):((size(HbO,3)/settings.fs)-(1/settings.fs));
GRABTC = f_timeCourse(gfp_norm,mask);
CaTC = f_timeCourse(rfp_norm,mask);
HbOTC = f_timeCourse(HbO,mask);
HbRTC = f_timeCourse(HbR,mask);
HbTTC = f_timeCourse(HbT,mask);

%% Make Plots
LineWidth= 1;
% Full Hemodynamics
tmphandle = figure('Position',[75,36,1727,211]);
plot(t,HbTTC,'k-','LineWidth',LineWidth);
hold on;
plot(t,HbRTC,'b-','LineWidth',LineWidth);
plot(t,HbOTC,'r-','LineWidth',LineWidth);
ylabel('\DeltaC (\muM)')
xlim([t(1),t(end)]);
title(sprintf('Run %i %s %s Full Time Course',Run,Side,ROIShort));
xlabel('Time (s)')
set(gca,'FontSize',18);
legend('\DeltaHbT','\DeltaHbR','\DeltaHbO','FontSize',12)
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%sTC_Full',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

% Based on the full hemodynamic plot, ask what times you want to see a smaller
% time course for
time_points = input('\nWhich time points would you like to see short graph for?\n Put in this format: 100 250\n','s');
time_points = str2num(time_points);


%Full gfp rfp in subplots
tmphandle = figure('Position',[107,-162,1732,567]);
tile_plot = tiledlayout(2,1);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,1);
ax(1) = nexttile(1);
plot(t,CaTC,'m-','LineWidth',LineWidth);
title(sprintf('Run %i %s %s Calcium Time Course',Run,Side,ROIShort));
xlabel('Time (s)')
set(gca,'FontSize',18)
xlim([t(10),t(end)]);
ylabel('\DeltaF/F','FontSize',18);
ax(2) = nexttile(2);
plot(t,GRABTC,'g-','LineWidth',LineWidth)
title(sprintf('Run %i %s %s ACh Time Course',Run,Side,ROIShort));
xlabel('Time(s)');
set(gca,'FontSize',18);
xlim([t(1),t(end)]);
ylabel('\DeltaF/F','FontSize',18);
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%s_TC_ACh_Ca_Full',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

% Short Everything on the same plot
tmphandle = figure('Position',[77,119,1492,237]);
ax = gca;
ax.YColor = 'k';
yyaxis right;
plot(t,HbTTC,'k-','LineWidth',LineWidth);
hold on;
yyaxis right;
plot(t,HbRTC,'b-','LineWidth',LineWidth);
yyaxis right;
plot(t,HbOTC,'r-','LineWidth',LineWidth);
ax = gca;
ax.YColor = 'k';
ax = gca;
ax.YColor = 'k';
ylabel('\DeltaC (\muM)')
yyaxis left;
ylabel('\DeltaF/F','FontSize',18);
plot(t,CaTC,'m-','LineWidth',LineWidth);
yyaxis left
plot(t,GRABTC,'g-','LineWidth',LineWidth)
xlim(time_points);
title(sprintf('Run %i %s %s Short Time Course',Run,Side,ROIShort));
xlabel('Time (s)')
set(gca,'FontSize',18);
legend('Ca2+','ACh','\DeltaHbT','\DeltaHbR','\DeltaHbO','FontSize',12)
ax = gca;
ax.YColor = 'k';
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%s_TC_Short',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

%Short gfp rfp in subplots
tmphandle = figure('Position',[140,-157,1027,496]);
tile_plot = tiledlayout(2,1);
tile_plot.TileSpacing = 'tight';
tile_plot.Padding = 'tight';
ax = gobjects(2,1);
ax(1) = nexttile(1);
plot(t,CaTC,'m-','LineWidth',LineWidth);
title(sprintf('Run %i %s %s Calcium Time Course',Run,Side,ROIShort));
xlabel('Time (s)')
set(gca,'FontSize',18)
xlim(time_points);
ylabel('\DeltaF/F','FontSize',18);
ax(2) = nexttile(2);
plot(t,GRABTC,'g-','LineWidth',LineWidth)
title(sprintf('Run %i %s %s ACh Time Course',Run,Side,ROIShort));
xlabel('Time(s)');
set(gca,'FontSize',18);
xlim(time_points);
ylabel('\DeltaF/F','FontSize',18);
tmpname = fullfile(fname.Figures,sprintf('Run%i_%s_%s_ACh_Ca_Short',Run,Side,ROI_No_Space));
savefig(tmphandle,tmpname);
saveas(tmphandle,[tmpname '.tif']);

