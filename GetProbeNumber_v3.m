% GetProbeNumber_v3.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 11-05-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% v2: catch errors
% v3: adjusted roi for Voluson E8, Aplio MX, error if < 9 digits

function [ProbeNumber] = GetProbeNumber_v3(i, folders, scanner)
    
    X=dicomread(folders(i).name);
    X = imresize(X,2);
    X=255-X;
    if strcmp(scanner, 'Voluson E8')
        roi =1.0e+03 *[0.6940    1.5340    0.8550    0.1705];
    elseif strcmp(scanner, 'iU22')
        roi=1.0e+03 *[0.6495    1.3775    0.6740    0.1340];
    elseif strcmp(scanner, 'Aplio MX')
        % roi =[389.5000  947.7500  643.5000   49.5000];
        roi=[389.5000  947.7500  643.5000  126.7500];

    end 

    ocrResults = ocr(X,roi);
    str=ocrResults.Text;
    
    if length(str)>8
        str=str(end-10:end-2); % probs want the whole thing here too - to identify spreadsheet sheet
        str(str==' ')=[];
        if length(str)<9 % Error if <9 digits
            str='Error';
        end
    else
        str='Error';
    end
    ProbeNumber=str;
end