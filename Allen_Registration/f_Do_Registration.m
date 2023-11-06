function [] = f_Do_Registration(dat,brain_mask)
% Version 1.0 Harrison Fisher 12/19/2021
% Version 1.1 Patrick Doran   03/31/2022
% Load Atlas file
atlas_file = 'allen_proj.mat';
load(atlas_file);

% Load regions table
regions_file = 'regions_matlab.mat';
regions_struct = load(regions_file);
regions_table = struct2table(regions_struct);

outline_file = 'allen_proj_outline.mat';
load(outline_file)


fixed = AllenAtlas;

time_series2 = double(dat);
moving = 65535 *(time_series2-min(min(min(time_series2))))/(max(max(max(time_series2)))-min(min(min(time_series2))));

%% Registration 
% set registration parameters
    % similarity - rotation, scaling, and translation
    % affine     - similarity + shearing 
RegType = 'similarity';  
rotate_first = 0;   % set to 1 to automatically rotate 90 degrees first 
N_points = 2;       % number of points to use in landmark registration 
threshold = 1;     % grayscale threshold to increase contrast for registration  
New_Registration = 1; % Turns to 0 when user is satisfied with registration


    % pick landmark / control points to speed up the manual registration
    InitialTform = f_InitialRegistration(moving,fixed,N_points,rotate_first,'nonreflectivesimilarity',threshold);
        % this function computes an initial transformation based on the control
        % points that can be editted with the app below:
%     moving = moving.*brain_mask;
    % Refine registration interactively 
    app = InteractiveImageRegistration(moving,fixed,regions_table,AllenOutline,InitialTform,threshold);

    while isvalid(app)
        pause(0.1);
    end

    
end
