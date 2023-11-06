% Patrick Doran Version 09/25/2023
% This function calculates the timing of red (jRGECO), green (GRAB) and
% hemoglobin frames. It also determines the time of stimulus onset
function [Interp_Data] = fInterprolation(Raw_Data,tMeasurment,Label,parameters)
% Set up output matrix
Interp_Data = zeros(parameters.SizeY,parameters.SizeX,length(parameters.tNew),parameters.iRep);
NaNVector = nan(1,length(parameters.tNew));

% First loop through stimulus presentations
for istim = 1:parameters.iRep
    % Find out timing of measurments relative to stimulus
    tmptime = tMeasurment - parameters.tStim(istim);
    [~,Index1] = min(abs(tmptime-(-1*parameters.TimeBeforeStim)));
    Index1 = Index1 - 1;
    [~,Index2] = min(abs(tmptime-parameters.TimeAfterStim));
    Index2 = Index2 + 1;
    tmptime = tmptime(Index1:Index2);
    tmpData = Raw_Data(:,:,Index1:Index2);
    tmpDataInterp = zeros(parameters.SizeY,parameters.SizeX,length(parameters.tNew));
    % Loop through pixels
    for y = 1:parameters.SizeY
        parfor x = 1:parameters.SizeX
            tmpVector = squeeze(tmpData(y,x,:))
            % Don't do interprolation if pixel is outside brain mask
            if ~isnan(tmpVector(1))
                tmpInterp = interp1(tmptime,tmpVector,parameters.tNew);
                tmpDataInterp(y,x,:) = tmpInterp;
            else
                tmpDataInterp(y,x,:) = NaNVector;
            end
        end
    end
    Interp_Data(:,:,:,istim) = tmpDataInterp;
    % Provide output when half way done
    if istim == round(parameters.iRep/2)
        fprintf('\n50%% done with %s Interprolation\n',Label);
    end
    clear tmp*
end
end