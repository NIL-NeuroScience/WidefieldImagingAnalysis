function movie=f_makeMovie(movie,threshold,bitDepth)
%MARTIN THUNEMANN 01/28/2023
%This converts a structure into images with a defined bit depth 
%For example for thresholds -2 to 2 and a bit depth of 16, pixels with a
%value of -2 or less will have a value of 0 (black) in the image and pixels
%with a value of 2 or more will have a value of 65535 (white) in the image
movie(movie<threshold(1))=threshold(1);
movie(movie>threshold(2))=threshold(2);
switch bitDepth
    case 8
        movie=uint8((movie-threshold(1))/(threshold(2)-threshold(1)).*(2^8-1));
    case 16
        movie=uint16((movie-threshold(1))/(threshold(2)-threshold(1)).*(2^16-1));
    case 32
        movie=uint32((movie-threshold(1))/(threshold(2)-threshold(1)).*(2^32-1));
end
end