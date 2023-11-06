function [Start_Pupil_Matrix] = f_Pupil_Matrix(tNew,Basler_Imaging_Frames,pupil)
nReps = size(Basler_Imaging_Frames,1);
[~,IndexZero] = min(abs(tNew));
TimePoints = length(tNew);
Start_Frame_Matrix = zeros(nReps,TimePoints);
Start_Pupil_Matrix = Start_Frame_Matrix;
for iRep = 1:nReps
    Start_Frame_Matrix(iRep,IndexZero) = Basler_Imaging_Frames(iRep,1)-1; % Make t = 0 the frame before imaging starts
    Start_Pupil_Matrix(iRep,IndexZero) = pupil(Start_Frame_Matrix(iRep,IndexZero));
    for index = IndexZero+1:TimePoints
        Start_Frame_Matrix(iRep,index) = Start_Frame_Matrix(iRep,index-1)+1;
        Start_Pupil_Matrix(iRep,index) = pupil(Start_Frame_Matrix(iRep,index));
    end
    for index = fliplr(1:IndexZero-1)
        Start_Frame_Matrix(iRep,index) = Start_Frame_Matrix(iRep,index+1)-1;
        Start_Pupil_Matrix(iRep,index) = pupil(Start_Frame_Matrix(iRep,index));
    end
end
end