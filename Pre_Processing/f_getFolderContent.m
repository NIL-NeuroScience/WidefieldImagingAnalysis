function [folders, files] = f_getFolderContent(in,filetype)
%Martin Thunemann, 12/16/2021
%This function lists the files and sub-directories inside the input directory
%If a file type is input, the output only lists files of that type
tmpList=dir(in);
for i=1:size(tmpList,1)
    if tmpList(i).isdir && tmpList(i).name(1) ~= '.'
        tmpFolders{i}=tmpList(i).name;
    elseif ~tmpList(i).isdir && tmpList(i).name(1) ~= '.'
        if strcmp(filetype,'*')
            tmpFiles{i}=tmpList(i).name;
        else
            if strcmp(tmpList(i).name(end-2:end),filetype)
                tmpFiles{i,1}=tmpList(i).name;
            end
        end
    end
end
if exist('tmpFolders','var')
    folders=tmpFolders(~cellfun('isempty',tmpFolders));
else
    folders={};
end
if exist('tmpFiles','var')
    files=tmpFiles(~cellfun('isempty',tmpFiles));
else
    files={};
end
