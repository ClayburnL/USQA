% reorder_by_InstanceNumber.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 11-09-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net), 
%-------------------------------------------------------------------------

% Issue: when I open stack in ImageJ file 000003 comes after 0000004 for test data:
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Feb test data\GE_2018-00856\02')
% This seems to be the correct way around, so this function reorders files according to View Number DICOM Tag.

% Note that ViewNumber misses numbers that have been removed due to duplication - e.g. in test data:
% cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Feb test data\GE_2018-00857\02');
% code is written to catch this exception

% Instance number available across vendors, ViewNumber not available on Tosh

function [folders_reordered] = reorder_by_InstanceNumber(folders)

    for i=3:length(folders)
        info=dicominfo(folders(i).name);
        instance(i)=info.InstanceNumber;
        [~,new_idx]=sort(instance);
    end
    for i=3:length(folders)
        folders_reordered(i)=folders(new_idx(i));
    end

end