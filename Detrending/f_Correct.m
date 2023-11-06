% Patrick Doran Version 09/27/2023
% This function calculates does detrending and photobleaching correction
% Type must be either gfp or rfp
function [dataOut] = f_Correct(dataIn,t,settings,type)
% Determine what settings to use
if strcmp(type,'gfp')
    Specific_Settings = settings.gfp;
elseif strcmp(type,'rfp')
    Specific_Settings = settings.rfp;
else
    error("Type must be gfp or rfp for correction function")
end

NaNVector = nan(1,size(dataIn,3));
dataOut = dataIn;
% Only do any correction if settings say so
if Specific_Settings.Correct
    % Loop through pixels
    for y = 1:size(dataIn,1)
        parfor x = 1:size(dataIn,2)
            tmpTC = squeeze(dataIn(y,x,:));
            % Do not proceed if pixel is outside brain mask
            if ~isnan(tmpTC(1))
                % If we fit exponential decay function
                if Specific_Settings.Type == 1
                    tmp_exp = fit(t,tmpTC,'exp1','StartPoint',[10,-.002]);
                    tmp_regress = tmp_exp(t);
                    tmpTC = tmpTC - tmp_regress;
                    tmpTC = tmpTC - mean(tmpTC);
                    dataOut(y,x,:) = tmpTC;
                % If we detrend
                elseif Specific_Settings.Type == 2
                    dataOut(y,x,:) = detrend(tmpTC);
                else
                    error("Correction type must be 1 or 2!")
                end
            else
                % If we are outside the mask
                dataOut(y,x,:) = NaNVector;
            end
        end
        % Give messages when an incrament of 10% of the image is done
        switch floor((y/size(dataIn,1))*10)
            case 1
                % Only the first time you enter the percentile
                if floor(((y-1)/size(dataIn,1))*10) ~= 1
                    fprintf('\n10%% done with %s correction\n',type)
                end
            case 2
                if floor(((y-1)/size(dataIn,1))*10) ~= 2
                    fprintf('\n20%% done with %s correction\n',type)
                end
            case 3
                if floor(((y-1)/size(dataIn,1))*10) ~= 3
                    fprintf('\n30%% done with %s correction\n',type)
                end
            case 4
                if floor(((y-1)/size(dataIn,1))*10) ~= 4
                    fprintf('\n40%% done with %s correction\n',type)
                end
            case 5
                if floor(((y-1)/size(dataIn,1))*10) ~= 5
                    fprintf('\n50%% done with %s correction\n',type)
                end
            case 6
                if floor(((y-1)/size(dataIn,1))*10) ~= 6
                    fprintf('\n60%% done with %s correction\n',type)
                end
            case 7
                if floor(((y-1)/size(dataIn,1))*10) ~= 7
                    fprintf('\n70%% done with %s correction\n',type)
                end
            case 8
                if floor(((y-1)/size(dataIn,1))*10) ~= 8
                    fprintf('\n80%% done with %s correction\n',type)
                end
            case 9
                if floor(((y-1)/size(dataIn,1))*10) ~= 9
                    fprintf('\n90%% done with %s correction\n',type)
                end
        end
    end
end

end