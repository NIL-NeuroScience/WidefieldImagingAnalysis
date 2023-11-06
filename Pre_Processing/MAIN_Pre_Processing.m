%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                   Single photon data pre-processing
%
% Version 0.1 MARTIN THUNEMANN 12/16/2021
% Version 0.2 Patrick Doran  01/28/2022
% Version 0.3 Patrick Doran  03/31/2022
% Version 1.0 MARTIN THUNEMANN 01/28/2023
% Version 1.1 MARTIN THUNEMANN 03/20/2023 processing of multiple files/deactivated mask
% Version 1.2 MARTIN THUNEMANN 03/20/2023 rearranged save and clearvars to avoid error 
%                            for very large files
% Version 1.3 MARTIN THUNEMANN 04/26/2023 improved handling of series w/o 4 channels
%                            turned off try catch for debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script reads .dat files created by the Andor solis acquisition software
% and creates an image matrix for each channel. For the fluorescence channels 
% it divides each image by an average image to calculate the normalized change
% in fluorescnece (dF/F). It uses the two reflectance channels to calculate 
% changes in the concentration of oxyhemoglobin and deoxyhemolobin using a 
% modified Beer-Lambert law. Correction of hemodynamic artifacts in the 
% fluorescence channels due to the absorption of light by hemoglobin is implemented. 
%
% If any imaging runs did not run to completion it is essential that they
% are listed in commonSettings.badRuns and that commonSettings.allRuns is
% set to 0!
%
% This script uses parrallel processing! 

clearvars;
close all;
%% Select root folder. This is the data that will be pre-processed
rootFolderList={'/projectnb/devorlab/pdoran/1P/23-07-18/Thy1_153'};
%% IMPORTANT THINGS TO CHANGE
% Here you need to list "Bad Runs" that did not run to completion. For
% example if runs 2,3 and 7 did not run to completion
% commonSettings.badRuns = [2,3,7]; If there are bad runs not to be
% processed, commonSettings.allRuns MUST = 0. If commonSettings.allRuns is
% 1 then the code will disregard the values in commonSettings.badRuns
commonSettings.allRuns = 0;      % Set to 1 to do all runs or 0 to only do certain runs
commonSettings.badRuns = [3,5,6,7];% Vector of runs not To Process. Only used if All runs is 0

% Here you must add the path to the folder that has the pre-processing code
% in it. The Andor data importer will automatically change the folder to
% where the data is so the folder with all of the functions for 
% pre-processing must be added to the path
addpath('/projectnb/devorlab/pdoran/1P_Analysis_Scripts/Widefield_Imaging_CodeV2/Pre_Processing')

%% Define settings for data pre-processing
commonSettings.templateSize=10;             % number of frames loaded to generate template image
commonSettings.hasBehavior = false;            % True when there are pylon recordings
commonSettings.doMovie = false;             % Makes \DeltaR/R or \DeltaF/F movies and exports them as tiff stack
commonSettings.saveHDF5 = true;         % Stores data as h5 file
commonSettings.compression=0;
commonSettings.chunkSize=[2^4 2^4 2^4];          % optimized for L2 cache of mesoscope computer  


%%
for rootFolderCounter=1:size(rootFolderList,1)
    %%
    clearvars dataIn commonFolders
    commonFolders.root=rootFolderList{rootFolderCounter};
    %try
        %% Reads root folder and returns folder structure
        commonFolders.folderIn=f_returnFolderStructure(commonFolders.root,4);
        commonFolders.folderList=f_findFoldersMaster(commonFolders.folderIn,{'onephoton','daq','behaviorCam','processed'});

        %% Lists all runs from solis input with tif files and sorts
        clearvars tmp*
        tmpSolis=find(strcmp({commonFolders.folderIn.type},'1photon'));
        if isempty(tmpSolis);return;end
        if size(tmpSolis,2)==1
            for folderCounter=1:size(commonFolders.folderIn(tmpSolis).folders,2)
                clearvars tmp1 tmp2 tmp3 tmpNum
                commonFolders.solis(folderCounter).runnum=commonFolders.folderIn(tmpSolis).folders(folderCounter).runnum;
                commonFolders.solis(folderCounter).name=commonFolders.folderIn(tmpSolis).folders(folderCounter).name;
                if isfield(commonFolders.folderIn(tmpSolis).folders(folderCounter),'folders') && ~isempty(commonFolders.folderIn(tmpSolis).folders(folderCounter).folders)
                    tmpSifx=find(strcmp(commonFolders.folderIn(tmpSolis).folders(folderCounter).files(:,2),'sifx'));
                    tmpDat=find(strcmp(commonFolders.folderIn(tmpSolis).folders(folderCounter).files(:,2),'dat'));
                    tmpIni=find(strcmp(commonFolders.folderIn(tmpSolis).folders(folderCounter).files(:,2),'ini'));
                    if size(tmpSifx,2)==1 && strcmp(commonFolders.folderIn(tmpSolis).folders(folderCounter).files{tmpSifx,1},'Spooled files.sifx')
                        tmp0(1)=true;
                    end
                    if size(tmpIni,2)==1 && strcmp(commonFolders.folderIn(tmpSolis).folders(folderCounter).files{tmpIni,1},'acquisitionmetadata.ini')
                        tmp0(2)=true;
                    end
                end
                if all(tmp0)
                    commonFolders.solis(folderCounter).isSifx=true;
                else
                    commonFolders.solis(folderCounter).isSifx=false;
                end
                commonFolders.solis(folderCounter).folder=[commonFolders.folderIn(tmpSolis).folders(folderCounter).parentFolder,filesep,commonFolders.folderIn(tmpSolis).folders(folderCounter).name];
                commonFolders.solis(folderCounter).isSona=false;
                commonFolders.solis(folderCounter).isZyla=false;
                commonFolders.solis(folderCounter).isDualCam=false;
            end
        elseif size(tmpSolis,2)>1
            for iFolder=1:size(tmpSolis,2)
                for folderCounter=1:size(commonFolders.folderIn(tmpSolis(iFolder)).folders,2)
                    clearvars tmp1 tmp2 tmp3 tmpNum
                    commonFolders.solis(iFolder,folderCounter).runnum=commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).runnum;
                    commonFolders.solis(iFolder,folderCounter).name=commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).name;
                    if isfield(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter),'folders') && ~isempty(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).folders)
                        tmpSifx=find(strcmp(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).files(:,2),'sifx'));
                        tmpDat=find(strcmp(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).files(:,2),'dat'));
                        tmpIni=find(strcmp(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).files(:,2),'ini'));
                        if size(tmpSifx,2)==1 && strcmp(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).files{tmpSifx,1},'Spooled files.sifx')
                            tmp0(1)=true;
                        end
                        if size(tmpIni,2)==1 && strcmp(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).files{tmpIni,1},'acquisitionmetadata.ini')
                            tmp0(2)=true;
                        end
                    end
                    if all(tmp0)
                        commonFolders.solis(iFolder,folderCounter).isSifx=true;
                    else
                        commonFolders.solis(iFolder,folderCounter).isSifx=false;
                    end
                    commonFolders.solis(iFolder,folderCounter).folder=[commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).parentFolder,filesep,commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).name];

                    if contains(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).parentFolder,'Sona','IgnoreCase',true) && ~contains(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).parentFolder,'Zyla','IgnoreCase',true)
                        commonFolders.solis(iFolder,folderCounter).isSona=true;
                        commonFolders.solis(iFolder,folderCounter).isZyla=false;
                        commonFolders.solis(iFolder,folderCounter).isDualCam=true;
                    elseif contains(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).parentFolder,'Zyla','IgnoreCase',true) && ~contains(commonFolders.folderIn(tmpSolis(iFolder)).folders(folderCounter).parentFolder,'Sona','IgnoreCase',true)
                        commonFolders.solis(iFolder,folderCounter).isZyla=true;
                        commonFolders.solis(iFolder,folderCounter).isSona=false;
                        commonFolders.solis(iFolder,folderCounter).isDualCam=true;
                    else
                        commonFolders.solis(iFolder,folderCounter).isSona=false;
                        commonFolders.solis(iFolder,folderCounter).isZyla=false;
                    end
                end
            end
        end

                clearvars i* tmp*

        %% Lists all mat files generated with DAQ/Triggermaster control code
        tmpDAQ=find(strcmp({commonFolders.folderIn.type},'daq'));
        if isempty(tmpDAQ);return;end
        if isfield(commonFolders.folderIn(tmpDAQ),'files') && ~isempty(commonFolders.folderIn(tmpDAQ).files)
            for iFile=1:size(commonFolders.folderIn(tmpDAQ).files,1)
                if ~isempty(commonFolders.folderIn(tmpDAQ).files(iFile,3))
                    commonFolders.daq(iFile).runnum=commonFolders.folderIn(tmpDAQ).files{iFile,3};
                    commonFolders.daq(iFile).folder=[commonFolders.folderIn(tmpDAQ).parentFolder,filesep,commonFolders.folderIn(tmpDAQ).name];
                    commonFolders.daq(iFile).name=commonFolders.folderIn(tmpDAQ).files{iFile,1};
                else
                    commonFolders.daq(iFile).runnum=NaN;
                end
            end
        end
        clearvars i* tmp*

        %% Generates dataIn variable with individual runs and references DAQ/behavior recording to the runs
        tmpTable=[];
        for iEntry=1:size(commonFolders.solis,1)
            for iEntry2=1:size(commonFolders.solis,2)
            if commonFolders.solis(iEntry,iEntry2).isSifx
                tmpFind=find([commonFolders.daq.runnum]==commonFolders.solis(iEntry,iEntry2).runnum);
                if ~isempty(tmpFind) && size(tmpFind,2)==1
                    tmpTable(end+1).runnum=commonFolders.solis(iEntry,iEntry2).runnum;
                    tmpTable(end).solis=commonFolders.solis(iEntry,iEntry2);
                    tmpTable(end).isSona=commonFolders.solis(iEntry,iEntry2).isSona;
                    tmpTable(end).isZyla=commonFolders.solis(iEntry,iEntry2).isZyla;
                    tmpTable(end).isDualCam=commonFolders.solis(iEntry,iEntry2).isDualCam;
                    tmpTable(end).daq=commonFolders.daq(tmpFind);
                else
                    tmpTable(end+1).daqID=[];
                end
                if commonSettings.hasBehavior
                    tmpFind=find([commonFolders.pylon.runnum]==commonFolders.solis(iEntry).runnum);
                    if ~isempty(tmpFind) && size(tmpFind,2)==1
                        tmpTable(end).pylon=commonFolders.pylon(tmpFind);
                    else
                        tmpTable(end).pylon=[];
                    end
                end
            end
            end
        end
        dataIn=tmpTable;
        clearvars tmp* i*

        %% Loads parameters from DAQ/Triggermaster control file and performs consistency checks
        for folderCounter=1:size(dataIn,2)
            if ~isempty(dataIn(folderCounter).daq)
                tmpDAQFile=[dataIn(folderCounter).daq.folder,filesep,dataIn(folderCounter).daq.name];
                tmpWhos=whos('-file',tmpDAQFile); %this is slow, better way of doing this?
                if any(strcmp({tmpWhos.name},'settings'))
                    tmpIn=load(tmpDAQFile,'settings');
                    dataIn(folderCounter).settings=tmpIn.settings;
                    dataIn(folderCounter).frameNumberConistent=true;
                    if commonSettings.hasBehavior
                        if ~isempty(dataIn(folderCounter).pylon) && dataIn(folderCounter).settings.nCycles==dataIn(folderCounter).pylon.tifN
                            dataIn(folderCounter).cycleNumberConistent=true;
                        else
                            dataIn(folderCounter).cycleNumberConistent=false;
                        end
                    end
                else
                    dataIn(folderCounter).settings=[];
                end
            end
        end
        clearvars tmp* i*

        %% Add quality control
        for folderCounter=1:size(dataIn,2)
            if dataIn(folderCounter).frameNumberConistent
                dataIn(folderCounter).goodRun=true;
            else
                dataIn(folderCounter).goodRun=false;
            end
        end
        if ~commonSettings.allRuns
            for iRun=1:size(dataIn,2)
                if ismember(dataIn(iRun).runnum,commonSettings.badRuns)
                    dataIn(iRun).goodRun=false;
                end
            end
        end
        clearvars tmp* i*

        %% Matches frames with LED and loads some images as template
        tmpSettings.mp = 1;tmpSettings.cores= 8;tmpSettings.doNorm = 0;tmpSettings.doCat=0;
        tmpSettings.nImport=commonSettings.templateSize;
        for folderCounter=find([dataIn.goodRun])
            tmpSettings.nChannels=size(dataIn(folderCounter).settings.LEDOrder,1);
            [~,dataIn(folderCounter).metadata,tmpRaw,~]=f_AndorDATImporter(dataIn(folderCounter).solis.folder,tmpSettings);
            for iLED=1:size(dataIn(folderCounter).settings.LEDOrder,1)
                dataIn(folderCounter).led(iLED).type=str2double(dataIn(folderCounter).settings.LEDOrder(iLED,:));
                dataIn(folderCounter).led(iLED).time=dataIn(folderCounter).settings.ExposureTimes(iLED);
                dataIn(folderCounter).led(iLED).power=dataIn(folderCounter).settings.LEDPower(iLED);
                dataIn(folderCounter).template(:,:,iLED)=mean(tmpRaw(:,:,:,iLED),3);
            end
        end
        clearvars tmp* i*

        %% Generates folder 'processed' and folder 'images' for output
        tmpProcessed=find(strcmp({commonFolders.folderIn.name},'processed'));
        if isempty(tmpProcessed)
            [~,~]=mkdir([commonFolders.root,filesep,'processed']);
        end
        commonFolders.processed=[commonFolders.root,filesep,'processed'];
        tmpImages=find(strcmp({commonFolders.folderIn.name},'images'));
        if isempty(tmpImages)
            [~,~]=mkdir([commonFolders.root,filesep,'images']);
        end
        commonFolders.images=[commonFolders.root,filesep,'images'];
        clearvars tmp* i*

        %% Store dataIn variable with information in root folder
        save([commonFolders.root filesep 'dataIn.mat'],'dataIn')
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % Preprocessing is finished. Start the image processing run-by-run
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        for folderCounter=find([dataIn.goodRun])
%             try
            if dataIn(folderCounter).isDualCam;disp('Sorry, this code does not work with dual-camera recordings!');return;end

            if commonSettings.saveHDF5
                if exist([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'file')
                    delete([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5']);
                end
            end

                %%
            clearvars settings* tmp* gfp* rfp* Hb*
            tic;
            settings=dataIn(folderCounter);
            settings.hdChannel1=find([dataIn(folderCounter).led.type]==525);
            settings.hdChannel2=find([dataIn(folderCounter).led.type]==625);
            settings.gfpChannel=find([dataIn(folderCounter).led.type]==470);
            settings.rfpChannel=find([dataIn(folderCounter).led.type]==565);
            settings.hd=f_defineHemodynamicParameters(525,625);


            %% Importing the entire image dataset
            tmpSettings.mp = 1;tmpSettings.cores= 8;tmpSettings.doNorm = 0;tmpSettings.nChannels = size(dataIn(folderCounter).settings.LEDOrder,1);tmpSettings.doCat=0;tmpSettings.nImport=0;
            [~,~,rawImageChannel,~]=f_AndorDATImporter(dataIn(folderCounter).solis.folder,tmpSettings);
            clearvars tmpSettings;
            toc;
% PROCESSING BEGINS
            %% Process reflectance images to estimate [Hb]
            fprintf('\nCalculate Hb, HbO...')

            %optional: add filter and other pp

            tmpA0Hb=settings.hd.cLambda2Hb*log(mean(rawImageChannel(:,:,:,settings.hdChannel2),3))-settings.hd.cLambda1Hb*log(mean(rawImageChannel(:,:,:,settings.hdChannel1),3));
            tmpA0HbO=settings.hd.cLambda2HbO*log(mean(rawImageChannel(:,:,:,settings.hdChannel2),3))-settings.hd.cLambda1HbO*log(mean(rawImageChannel(:,:,:,settings.hdChannel1),3));
            HbO=(tmpA0HbO+settings.hd.cLambda1HbO*log(double(rawImageChannel(:,:,:,settings.hdChannel1)))-settings.hd.cLambda2HbO*log(double(rawImageChannel(:,:,:,settings.hdChannel2))));
            Hb=(tmpA0Hb+settings.hd.cLambda1Hb*log(double(rawImageChannel(:,:,:,settings.hdChannel1)))-settings.hd.cLambda2Hb*log(double(rawImageChannel(:,:,:,settings.hdChannel2))));
            clearvars tmp* i*
            toc;
            
            if commonSettings.saveHDF5
                fprintf('\nSaving Hb and HbO data (h5)...')
                h5create([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/hemodynamics/Hb',size(Hb),'Deflate',commonSettings.compression,'Chunksize',commonSettings.chunkSize,'Datatype','double')
                h5create([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/hemodynamics/HbO',size(HbO),'Deflate',commonSettings.compression,'Chunksize',commonSettings.chunkSize,'Datatype','double')
                h5write([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/hemodynamics/Hb',Hb)
                h5write([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/hemodynamics/HbO',HbO)
                fprintf('done.\n');toc
            end
            if commonSettings.doMovie
                fprintf('\nPreparing Hb, HbO, HbT movies (tiff)...')
                f_saveMovie(Hb,[-10e-6,10e-6],8,[commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'_Hb.tif']);
                f_saveMovie(HbO,[-10e-6,10e-6],8,[commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'_HbO.tif']);
                f_saveMovie(Hb+HbO,[-10e-6,10e-6],8,[commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'_HbT.tif']);
                fprintf('done.\n');toc
            end

            %% process gfp
             if ~isempty(settings.gfpChannel)
            fprintf('\nProcess green fluorescence...')
            
            %optional: add filter and other pp

            tmpWL = [470 515];
            tmpExtinction = f_GetExtinctions(tmpWL);     % in cm
            tmpPathEx = f_pathlengths(tmpWL(1))/2;       % pathlengths returns in cm
            tmpPathEm = f_pathlengths(tmpWL(2))/2;
            tmpMuaEx = (tmpExtinction(1,1).*HbO) + (tmpExtinction(1,2).*Hb);
            tmpMuaEm = (tmpExtinction(2,1).*HbO) + (tmpExtinction(2,2).*Hb);
            clearvars HbO Hb
            gfp_norm = (double(rawImageChannel(:,:,:,settings.gfpChannel))-mean(rawImageChannel(:,:,:,settings.gfpChannel),3))./mean(rawImageChannel(:,:,:,settings.gfpChannel),3);
            gfp_norm_HD = (gfp_norm+1)./exp(-(tmpMuaEx.*tmpPathEx + tmpMuaEm.*tmpPathEm))-1;
            clearvars tmp* i*
            toc;
            if commonSettings.saveHDF5
                fprintf('\nSaving green fluorescence data (h5)...')
                h5create([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/gfp/norm',size(gfp_norm),'Deflate',commonSettings.compression,'Chunksize',commonSettings.chunkSize,'Datatype','double');
                h5write([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/gfp/norm',gfp_norm)
                h5create([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/gfp/normHD',size(gfp_norm_HD),'Deflate',commonSettings.compression,'Chunksize',commonSettings.chunkSize,'Datatype','double');
                h5write([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/gfp/normHD',gfp_norm_HD)
                fprintf('done.\n');toc
            end
            if commonSettings.doMovie
                fprintf('\nPreparing green fluorescence movie (tiff)...')
                f_saveMovie(gfp_norm_HD,[-0.2,0.2],8,[commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'_egfp.tif']);
                fprintf('done.\n');toc
            end
            clearvars gfp_norm gfp_norm_HD
             end
            toc;
            %% process rfp
            if ~isempty(settings.rfpChannel)
                fprintf('\nProcess red fluorescence...')
                %optional: add filter and other pp
                rfp_norm = (double(rawImageChannel(:,:,:,settings.rfpChannel))-mean(rawImageChannel(:,:,:,settings.rfpChannel),3))./mean(rawImageChannel(:,:,:,settings.rfpChannel),3);
                clearvars tmp* i
                toc;
                if commonSettings.saveHDF5
                    fprintf('\nSaving red fluorescence data (h5)...')
                    h5create([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/rfp/norm',size(rfp_norm),'Deflate',commonSettings.compression,'Chunksize',commonSettings.chunkSize,'Datatype','double')
                    h5write([commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'.h5'],'/rfp/norm',rfp_norm)
                    fprintf('done.\n');toc
                end
                if commonSettings.doMovie
                    fprintf('\nPreparing red fluorescence movie (tiff)...')
                    f_saveMovie(rfp_norm,[-0.2,0.2],8,[commonFolders.processed,filesep,'run',num2str(dataIn(folderCounter).runnum,'%04.0f'),'_rfp.tif']);
                    fprintf('done.\n');toc
                end
                clearvars rfp_norm rawImageChannel
            end
        end

end
return;