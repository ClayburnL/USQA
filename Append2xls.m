% Append2xls.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 16-09-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% Write results to .xls

% Matlab 2019a does not support append to excel spreadsheet
% read and write seems a bit complex, due to the format
% recommend moving to simple format and using read and write if 2019a req.

function [] = Append2xls(results, date, scannerID, scannerModel)

    cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR');
    
    scanner=strcat(scannerID, strcat('_', scannerModel));

    headings=cell(1,10);
    headings{1,1}='Date reported';
    headings{1,2}='Date tested';
    headings{1,3}='Probe ID';
    headings{1,4}='QAClin reverb depth [mm]';
    headings{1,5}='QAClin gain [%]';
    headings{1,6}='QAClin colour gain [%]';
    headings{1,7}='QAPhys reverb depth [mm]';
    headings{1,8}='QAPhys gain [%]';
    headings{1,9}='QAPhys colour gain [%]';
    headings{1,10}='Comments';
    headings2=cell(1,10);
    for i=1:10
        headings2{1,i}='--';
    end

    if ~isfile(strcat(scanner,'.xls'))
        for probe=1:3
            writecell(headings,strcat(scanner,'.xls'),'Sheet',probe);
            writecell(headings2,strcat(scanner,'.xls'),'Sheet',probe, 'WriteMode','append');
        end
    end

    for probe=1:3
        result=cell(1,10);
        result{1,1}=cell2mat(cellstr(cellstr(datetime("today"))));
        result{1,2}=cell2mat(cellstr(datetime(date,'InputFormat','yyyyMMdd')));
        for j=1:7
            result{1,j+2}=str2num(results{probe,j});
        end
        writecell(result,strcat(scanner,'.xls'),'Sheet',probe, 'WriteMode','append');
    end

end