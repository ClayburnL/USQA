% GetGain_v5.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 11-05-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% v5 check confidences only for relevant characters

function [Gain] = GetGain_v5(i, folders, scanner, invert, binarise)

    X=dicomread(folders(i).name);
    X = imresize(X,3);
    if invert == 1
        X=255-X;
    end
    if binarise==1
        X=rgb2gray(X);  % might be optimal for all?
        X=imbinarize(X);
    end
    if strcmp(scanner, 'Voluson E8')
        roi=1.0e+03 *[3.1186    0.4190    0.2899    0.0758];
    elseif strcmp(scanner, 'iU22')
        roi=[ 44.1431  469.7981   82.2764   75.8914];
    elseif strcmp(scanner, 'Aplio MX')
        roi =1.0e+03 *[ 2.0464    0.7058    0.1021    0.0731];
    end
    
    if strcmp(scanner, 'iU22') % not optimal for all!
        ocrResults = ocr(X,roi, LayoutAnalysis="line");
    else
        ocrResults = ocr(X,roi);
    end
    
    str=ocrResults.Text;
    % find 'Gn' in text - can this be simplified like e.g. GetReverb logic?
    if strcmp(scanner, 'Voluson E8')
        idx=0;
        for c=1:length(str)-1
            if str(c:c+1)=='Gn'
                idx=c;
            end
        end
        if idx>0
            str=str(idx+3:idx+4);
        else
            X=dicomread(folders(i+1).name);
            X = imresize(X,3);
            X=255-X;
            ocrResults= ocr(X,roi);
            str=ocrResults.Text;
            % find 'Gn' in text
            for c=1:length(str)-1
                if str(c:c+1)=='Gn'
                    idx=c;
                end
            end
            if idx>0
                str=str(idx+3:idx+4);
            else
                str='Error';
            end
        end
    elseif strcmp(scanner, 'iU22')
        if isempty(str)
            str='Error';
        elseif contains(str,'%')  % remove %
            str(str=='%')=[];
        end
    end
    % only accept numbers
    if isempty(str2num(str))
        str='Error';
    end

    if ~strcmp(str,'Error') % if str is not already Error
        str=num2str(str2num(str)); % workaround to get rid of some weird extra characters
        idx=strfind(ocrResults.Text,str); % find identified text within ocrResults.Text
        % Replace text with 'Error' if confidence for any character within identified text <0.95
        % ocrResults.Text(idx:idx+length(str)-1)
        for i=idx:idx+length(str)-1
            if ocrResults.CharacterConfidences(i)<0.95
                % ocrResults.CharacterConfidences(i)
                str='Error';
            end
        end
    end

    Gain=str;
end