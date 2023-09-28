% Tutorial_for_CBD.m--
% Developed in Matlab 9.14.0.2206163 (R2023a) on PCWIN64
% Copyright Sheffield Teaching Hospitals NHS Foundation Trust 16-09-2023.
% Lloyd Clayburn (lloyd.clayburn@nhs.net)
%-------------------------------------------------------------------------

%% PART 1

% Open folder that contains QA data
cd('C:\Users\clayb\OneDrive\Documents\STP\US\OCR\Feb test data\GE_2018-00856\02');

% Read DICOM image from first file in folder
i=1;
files=dir('*.*');
filename=files(i+2).name;
image=dicomread(filename);

% Plot image data and overlay rectangular ROI
imshow(image)
rectangle = drawrectangle(gca,'Position',[10 10 100 100]);

%----------------------------------------------------------

% %% PART 2

% Set ROI to position of rectangular box
roi = rectangle.Position;

% Read text from roi
ocr_results = ocr(image,roi);