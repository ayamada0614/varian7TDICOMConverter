function varian7TDicomConverter(dcmFileName, numberOfGradient)
% DICOM Converter for Varian 7T MR Scanner
%
% Scripted by Atsushi Yamada, PhD
% Assistant Professor
% Bio Medical Innovation Center and Department of Surgery
% Shiga University of Medical Science 
%
% ************ Notification for Diffusion Toolkit *************
% check 'Apply Spline Filter'
% check 'Swap Y/Z'
% *************************************************************

% get header information 
hdr_info = dicominfo(dcmFileName);

% modify file name to read sequential files
dotNumber = strsplit(dcmFileName, '1.'); % for Matlab 2013b
[fName, ext]=dotNumber{1,1:2};
%fName = strtok(dcmFileName, '1.'); % for Matlab 2012b
%ext = 'dcm';

for j = 1:1:str2num(numberOfGradient)

    % create file name to read files sequentially
    seqNumber = j;
    seqNumberStr = num2str(seqNumber);
    seqFileName = [fName, seqNumberStr, '.', ext];

    % Obtain geometry information from DICOM header 
    hdr_info = dicominfo(seqFileName);
    
    numberOfSlices = hdr_info.('NumberOfSlices');
    initialSliceLocation = hdr_info.('SliceLocation');
    sliceThickness = hdr_info.('SliceThickness');
    spacingBetweenSlices = hdr_info.('SpacingBetweenSlices');

    % avoid getting an error (only numbers are permitted for this ID.)
    hdr_info.StudyInstanceUID = '2014';     

    % Read DICOM data
    seriesImage = dicomread(hdr_info);

    fprintf('++++++++++++++++++++++++++++++++++\n')
    fprintf('Splitting series of DICOM files...\n')
    fprintf('++++++++++++++++++++++++++++++++++\n')
    
    for i = 1:1:numberOfSlices
        
        f = (i-1)*str2num(numberOfGradient)+j;
        
        tmpValue1 = double(f)*(sliceThickness);
        
        %tmpValue = initialSliceLocation + tmpValue1 + tmpValue2;
        tmpValue = tmpValue1;
        hdr_info.NumberOfFrames = numberOfSlices;
        hdr_info.SliceLocation = i; %double(tmpValue);
        hdr_info.ImagePositionPatient(3) = i; %double(tmpValue);

        singleImage = seriesImage(:,:,1,i);
    
        hdr_info.InstanceNumber = f;
        hdr_info.InStackPositionNumber = i;
        hdr_info.ImagesInAcquisition = str2num(numberOfGradient)*hdr_info.NumberOfFrames;
    
        % write DICOM file
        if(f<10)
            saveFileName = [fName, 'ForVarian7T-0000%d.dcm'];
        elseif(f<100)
            saveFileName = [fName, 'ForVarian7T-000%d.dcm'];
        elseif(f<1000)
            saveFileName = [fName, 'ForVarian7T-00%d.dcm'];
        elseif(f<10000)
            saveFileName = [fName, 'ForVarian7T-0%d.dcm'];
        elseif(f<100000)
            saveFileName = [fName, 'ForVarian7T-%d.dcm'];            
        end
        
        convertedFileName = sprintf(saveFileName, f);
        dicomwrite(singleImage, convertedFileName, hdr_info, 'CreateMode', 'copy');
    end
end

fprintf('Done.\n')

