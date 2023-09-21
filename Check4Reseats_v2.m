% Check4Reseats_v2.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 11-05-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% v2: renamed variable

function [folders] = Check4Reseats_v2(folders, scanner)
    
    reseats=0; % initialise
    for i=3:length(folders) % check for probe reseat files
        X=dicomread(folders(i).name);
        X = imresize(X,2);
        X=255-X;
        if strcmp(scanner, 'Voluson E8')
            roi=1.0e+03 *[0.7225    1.4947    0.6519    0.1711];
        elseif strcmp(scanner, 'iU22')
            roi=1.0e+03 *[0.5963    1.2802    0.8062    0.2352];
        elseif strcmp(scanner, 'Aplio MX')
            roi =[4.0000  707.7500  118.5000   48.0000];
        end
        ocrResults = ocr(X,roi);
        str=ocrResults.Text;
        if contains(str,'seat')
            reseats(i)=1;
        end
    end
    folders(reseats==1)=[];

end