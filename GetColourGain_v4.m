% GetColourGain_v4.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 11-05-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% Perhaps difficult to read gain values when number is highlighted

function [ColourGain] = GetColourGain_v4(i, folders, scanner, invert, binarise, layout)
    
    X=dicomread(folders(i).name);
    X = imresize(X,2);
    if invert == 1
        X=255-X;
    end
    if binarise==1
        X=rgb2gray(X);  % might be optimal for all?
        X=imbinarize(X);
    end
    if strcmp(scanner, 'Voluson E8')
        roi =1.0e+03 *[2.1315    0.4517    0.1410    0.0586];
    elseif strcmp(scanner, 'iU22')
        % roi=[0.5000  554.3848  225.8429   48.2513];
        roi=[30.7855  554.3112   54.9732   46.1270];
    elseif strcmp(scanner, 'Aplio MX')
        roi =1.0e+03 *[1.3780    0.6300    0.0545    0.0410];
    end
    
    if strcmp(scanner, 'iU22') || strcmp(scanner, 'Aplio MX') % not optimal for all!
        ocrResults = ocr(X,roi, LayoutAnalysis="line");
    elseif strcmp(layout,'line') % also use line mode if explicitly specified
       ocrResults = ocr(X,roi, LayoutAnalysis="line");
    else
        ocrResults = ocr(X,roi);
    end

    if strcmp(scanner, 'Voluson E8')
        str=ocrResults.Text(4:end);
        % only accept if decimal point is read
        if ~contains(str,'.')
            str='Error';
        end
    elseif strcmp(scanner, 'iU22')
        str=ocrResults.Text;
        str(str=='%')=[];
    elseif strcmp(scanner, 'Aplio MX')
        str=ocrResults.Text;
    end

    % only accept numbers
    if isempty(str2num(str))
        str='Error';
    end

    % Call error if confidence for any character <0.95
    for i=1:length(ocrResults.CharacterConfidences)
        if ocrResults.CharacterConfidences(i)<0.95
            str='Error';
        end
    end

    ColourGain=str;

end