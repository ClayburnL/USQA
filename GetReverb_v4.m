% GetReverb_v4.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 11-05-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% v4: added some if length() statements to catch errors.

function [Reverb] = GetReverb_v4(i, folders, scanner, binarise)

        X=dicomread(folders(i).name);
        X = imresize(X,2);
        X=255-X;
        if binarise==1
            X=rgb2gray(X);  % might be optimal for all?
            X=imbinarize(X);
        end
        if strcmp(scanner, 'Voluson E8')
            roi=[0.5000  135.3439  225.4030   51.4945];
        elseif strcmp(scanner, 'iU22')
            roi=1.0e+03 *[0.0495    1.4365    0.3640    0.1000];
        elseif strcmp(scanner, 'Aplio MX')
            roi =1.0e+03 *[0.0370    1.0330    0.2955    0.0415];
        end
        ocrResults = ocr(X,roi);

        str=ocrResults.Text;
        % remove spaces
        str(str==' ')=[];
        % remove cm and mm
        str(str=='c')=[];
        str(str=='m')=[];
        if isempty(str)
            str='Error';
        % remove other rubbish
        elseif length(str)>2
            if strcmp(str(1:2),'1D')
                str(1:2)=[];
            end
        elseif length(str)>5
            if strcmp(str(1:5),'DistA')
                str(1:5)=[];
            end
        elseif length(str)>4
            if strcmp(str(1:4),'Ut-H') || strcmp(str(1:4),'Ut-L')
                str(1:4)=[];
            elseif strcmp(str(1:4),'Dist')
                str(1:4)=[];
            end
        end

        % only accept numbers
        if isempty(str2num(str))
            str='Error';
        end
        % only accept if decimal point is read
        if ~contains(str,'.')
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

        Reverb=str;
end