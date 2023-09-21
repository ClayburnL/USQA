% GetDate.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 11-05-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

function [Date] = GetDate(i, folders)
    
    X=dicomread(folders(i).name);
    X = imresize(X,2);
    X=255-X;
    roi =1.0e+03 *[2.0410    0.0005    0.2315    0.0555];
    ocrResults = ocr(X,roi); 
    Date=ocrResults.Text(1:10);

end