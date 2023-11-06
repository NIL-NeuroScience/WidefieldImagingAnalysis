function [regions] = f_ReformatRegionTable(regions_file)

% Reformat the table of region information for easier use in matlab 

regions = readtable(regions_file);
% convert the format of the stored arrays 
for r = 1:height(regions)
    
    tmp = strsplit(regions.left_x{r},{' ','[',']'});
    tmp2 = cellfun(@str2num,tmp(2:end-1));
    regions.left_x{r} = tmp2';
    
    tmp = strsplit(regions.left_y{r},{' ','[',']'});
    tmp2 = cellfun(@str2num,tmp(2:end-1));
    regions.left_y{r} = tmp2';
    
    tmp = strsplit(regions.right_x{r},{' ','[',']'});
    tmp2 = cellfun(@str2num,tmp(2:end-1));
    regions.right_x{r} = tmp2';

    tmp = strsplit(regions.right_y{r},{' ','[',']'});
    tmp2 = cellfun(@str2num,tmp(2:end-1));
    regions.right_y{r} = tmp2';
    
    tmp = strsplit(regions.left_center{r},{' ','[',']'});
    tmp2 = cellfun(@str2num,tmp(2:end-1));
    regions.left_center{r} = tmp2';
    
    tmp = strsplit(regions.right_center{r},{' ','[',']'});
    tmp2 = cellfun(@str2num,tmp(2:end-1));
    regions.right_center{r} = tmp2';

    tmp = strsplit(regions.allen_rgb{r},{' ','[',']'});
    tmp2 = cellfun(@str2num,tmp(2:end-1));
    regions.allen_rgb{r} = tmp2';
    
end
