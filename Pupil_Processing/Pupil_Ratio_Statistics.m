% Patrick Doran VERSION 11/06/2023
% This compares the pupil ratio between runs with and without the aluminum
% hemisphere installed on the imaging system. A T test is run to test if
% the distributions of pupil ratios are significantly different. 

clear
close all
clc

%%  Load data
Cone.date = "23-10-19";
Cone.Mouse = "Thy1_152";
Cone.Root = fullfile("/projectnb/devorlab/pdoran/1P",Cone.date,Cone.Mouse);
Cone.fname = fullfile(Cone.Root,'mat','Pupil_Matrix.mat');
Cone.data = load(Cone.fname);
Cone.Figures = fullfile(Cone.Root,'Figures','5');
f_Test_Folder(Cone.Figures);

NoCone.date = "23-10-19";
NoCone.Mouse = "Thy1_152_No_Cone";
NoCone.Root = fullfile("/projectnb/devorlab/pdoran/1P",NoCone.date,NoCone.Mouse);
NoCone.fname = fullfile(NoCone.Root,'mat','Pupil_Matrix.mat');
NoCone.data = load(NoCone.fname);
NoCone.Figures = fullfile(NoCone.Root,'Figures','5');
f_Test_Folder(NoCone.Figures)

%% Do T Test
[h,p] = ttest2(Cone.data.Pupil_Ratio,NoCone.data.Pupil_Ratio);

%% Plot Bars with Data points
Cone.avg = mean(Cone.data.Pupil_Ratio);
Cone.stdev = std(Cone.data.Pupil_Ratio);
NoCone.avg = mean(NoCone.data.Pupil_Ratio);
NoCone.stdev = std(NoCone.data.Pupil_Ratio);
Cone.Reps =  length(Cone.data.Pupil_Ratio);
NoCone.Reps =  length(NoCone.data.Pupil_Ratio);

x = categorical(["With Frustrum","Without Frustum"]);
y = [Cone.avg,NoCone.avg];
stdev = [Cone.stdev,NoCone.stdev];
errhigh = y+stdev;
errlow = y;

tmphandle = figure;
h = bar(x,y,'BaseValue',1);
h.FaceColor = 'b';
h.FaceAlpha = 0.5;
hold on;
err = errorbar(x,y,stdev,stdev,'k','LineWidth',2);
err.LineStyle = 'none';
scatter(repmat(h(1).XEndPoints(1),Cone.Reps,1),Cone.data.Pupil_Ratio,'MarkerFaceColor','g','MarkerEdgeColor','k','XJitter','randn','XJitterWidth',0.2)
scatter(repmat(h(1).XEndPoints(2),NoCone.Reps,1),NoCone.data.Pupil_Ratio,'MarkerFaceColor','r','MarkerEdgeColor','k','XJitter','randn','XJitterWidth',0.2)

hold off;

title("Pupil Ratio")

set(gca,'FontSize',12)

tmpname = fullfile(NoCone.Figures,'Pupil_Ratio_Bar_Graph_With_Scatter');
savefig(tmphandle,tmpname);
