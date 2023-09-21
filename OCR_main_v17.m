% OCR_main_v17.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 10-05-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% Code dir: C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Code
% Inputs: target folder, outputs: .xls with results

%% v17
% In GetReverb - added some if length() statements to catch errors.
% Moved Append2csv into if statement

%% Further work:
% Add confidence level checking and missing data catching to probe number
% Get decompression and iteration through file structure working
% read csv and flag up out of tolerance values

% standardise error catching and attempts at resolution through code modules
% move each module and its error catching into separate fns?
% catch duplicates? - e.g. by recognising reverb has dist text, CG has CG data... - big job

%% Jan test data - counting manual data inputs as successes - evaluation 200923
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\GE_2018-00856\01'); %  no errors, 21/21 accuracy 
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\GE_2018-00857\01'); %  no errors, 21/21 accuracy
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\GE_2018-00858\01'); % fail - resolved in GetReverb, then no errors, 21/21 accuracy
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\IU22_2009-10800\01'); % fail - incorrect number of files - error also resolved by moving append2csv into if statement
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\Toshiba_2011-02498\01'); % fail - incorrect number of files
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\Toshiba_2011-02499\01'); 201404738 - incorrect QA colour gain - error not caught, 20/21 accuracy
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\Toshiba_2012-00122\01'); 201800753 should be 201800759 - and a missing probe ID - 2 missed errors and 19/21 accuracy
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Jan test data\Jan test data\Toshiba_2012-00123\01'); three probes - figure after dp missing in two reverb depths - 6 uncaught errors and 15/21 accuracy

% initialise
invert=1; % black on white easiest to read, and sometimes text is highlighted (inverted)
binarise=0; % threshold to increase contrast
layout='auto'; % text layout parameter can influence results

folders=dir('*.*');
scannerID=split(folders(1).folder, '\');
scannerID=scannerID{length(scannerID)-1};

scannerModel=dicominfo(folders(3).name).ManufacturerModelName;
date=dicominfo(folders(3).name).StudyDate;
folders=Check4Reseats_v2(folders, scannerModel); % check for reseats and remove them from consideration
folders=reorder_by_InstanceNumber(folders);

if mod(length(folders)-2,8)~=0 % Current system relies on reliable file structure
    disp 'incorrect number of files';
else
    results=cell((length(folders)-2)/8,7); % probe#, reverb, gain, cgain, reverb, gain, cgain

    for probe=1:(length(folders)-2)/8 % for each probe
       
        % Get Probe Number
        i=(probe*8)-5;
        results{probe,1}=GetProbeNumber_v3(i, folders, scannerModel);
        
        % Get QACLIN reverb depth
        i=i+1;
        results{probe,2}=GetReverb_v4(i, folders, scannerModel, binarise);
        if(strcmp(results{probe,2}, 'Error')) % if error, try again with different parameters
            results{probe,2}=GetReverb_v4(i, folders, scannerModel, 1);
        end
        if(strcmp(results{probe,2}, 'Error')) % if error, prompt for manual input
            image_data=dicomread(folders(i).name);
            disp('read reverb depth');
            pause(1)
            figure;imshow(image_data);
            pause(1)
            close(gcf);
            results{probe,2}=num2str(input('Please enter QAClin reverb depth without units: \n'));
        end

        % Get QACLIN gain
        i=i+1;
        results{probe,3}=GetGain_v5(i, folders, scannerModel, invert, binarise);
        if(strcmp(results{probe,3}, 'Error'))
            results{probe,3}=GetGain_v5(i, folders, scannerModel, 0, binarise);
        end
        if(strcmp(results{probe,3}, 'Error'))
            results{probe,3}=GetGain_v5(i, folders, scannerModel, invert, 1);
        end
        if(strcmp(results{probe,3}, 'Error'))
            image_data=dicomread(folders(i).name);
            disp('read gain');
            pause(1)
            figure;imshow(image_data);
            pause(1)
            close(gcf);
            results{probe,3}=num2str(input('Please enter QAClin gain without units: \n'));
        end
        
        % Get QACLIN colour gain
        i=i+1;
        results{probe,4}=GetColourGain_v5(i, folders, scannerModel, invert, binarise, layout);
        if(strcmp(results{probe,4}, 'Error'))
            results{probe,4}=GetColourGain_v5(i, folders, scannerModel, 0, binarise, layout);
        end
        if(strcmp(results{probe,4}, 'Error'))
            results{probe,4}=GetColourGain_v5(i, folders, scannerModel, invert, 1, layout);
        end
        if(strcmp(results{probe,4}, 'Error'))
            results{probe,4}=GetColourGain_v5(i, folders, scannerModel, invert, 1, 'line');
        end
        if(strcmp(results{probe,4}, 'Error'))
            image_data=dicomread(folders(i).name);
            disp('read colour gain');
            pause(1)
            figure;imshow(image_data);
            pause(1)
            close(gcf);           
            results{probe,4}=num2str(input('Please enter QAClin colour gain without units: \n'));
        end
        
        % Get QAPHYS reverb depth
        i=i+2;
        results{probe,5}=GetReverb_v4(i, folders, scannerModel, binarise);
        if(strcmp(results{probe,5}, 'Error'))
            results{probe,5}=GetReverb_v4(i, folders, scannerModel, 1);
        end
        if(strcmp(results{probe,5}, 'Error')) % if error, prompt for manual input
            image_data=dicomread(folders(i).name);
            disp('read reverb depth');
            pause(1)
            figure;imshow(image_data);
            pause(1)
            close(gcf);
            results{probe,5}=num2str(input('Please enter QAClin reverb depth without units: \n'));
        end
        
        % Get QAPHYS gain
        i=i+1;
        results{probe,6}=GetGain_v5(i, folders, scannerModel, invert, binarise);
        if(strcmp(results{probe,6}, 'Error'))
            results{probe,6}=GetGain_v5(i, folders, scannerModel, 0, binarise);
        end
        if(strcmp(results{probe,6}, 'Error'))
            results{probe,6}=GetGain_v5(i, folders, scannerModel, invert, 1);
        end
        if(strcmp(results{probe,6}, 'Error'))
            image_data=dicomread(folders(i).name);
            disp('read gain');
            pause(1)
            figure;imshow(image_data);
            pause(1)
            close(gcf);
            results{probe,6}=num2str(input('Please enter QAPhys gain without units: \n'));
        end

        % Get QAPHYS colour gain
        i=i+1;
        results{probe,7}=GetColourGain_v5(i, folders, scannerModel, invert, binarise, layout);
        if(strcmp(results{probe,7}, 'Error'))
            results{probe,7}=GetColourGain_v5(i, folders, scannerModel, 0, binarise, layout);
        end
        if(strcmp(results{probe,7}, 'Error'))
            results{probe,7}=GetColourGain_v5(i, folders, scannerModel, invert, 1, layout);
        end
        if(strcmp(results{probe,7}, 'Error'))
            results{probe,7}=GetColourGain_v5(i, folders, scannerModel, invert, 1, 'line');
        end
        if(strcmp(results{probe,7}, 'Error'))
            image_data=dicomread(folders(i).name);
            disp('read colour gain');
            pause(1)
            figure;imshow(image_data);
            pause(1)
            close(gcf);
            results{probe,7}=num2str(input('Please enter QAPhys colour gain without units: \n'));
        end
    end
    % Append results to xls
    Append2xls(results, date, scannerID, scannerModel);
end

%% Read data from file for analysis
% filename='Toshiba_2011-02499_Aplio MX.xls';
% C = readcell(filename);
