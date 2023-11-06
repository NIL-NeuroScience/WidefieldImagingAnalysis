function f_saveMovie(in,range,bitDepth,fileName)
%MARTIN THUNEMANN 01/28/2023
%This saves a video as a tiff stack
tmpImageOut=f_makeMovie(in,range,bitDepth);
objTiff=Tiff(fileName,'w');


for iFrame=1:size(tmpImageOut,3)
    if iFrame>1;writeDirectory(objTiff);end

    setTag(objTiff,'Photometric',Tiff.Photometric.MinIsBlack)
    setTag(objTiff,'Compression',Tiff.Compression.None)
    setTag(objTiff,'PlanarConfiguration',Tiff.PlanarConfiguration.Chunky)
    setTag(objTiff,'BitsPerSample',bitDepth)
    setTag(objTiff,'SamplesPerPixel',1)
    setTag(objTiff,'SampleFormat',Tiff.SampleFormat.UInt)
    setTag(objTiff,'ImageLength',size(tmpImageOut,1));
    setTag(objTiff,'ImageWidth',size(tmpImageOut,2));
    write(objTiff,tmpImageOut(:,:,iFrame));
end
close(objTiff);
end