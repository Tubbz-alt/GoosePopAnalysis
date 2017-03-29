function [meanHSV, centr, numberOfBlobs] = MeasureBlobs(maskImage, hImage, sImage, vImage)
try
	[labeledImage, numberOfBlobs] = bwlabel(maskImage, 8);     % Label each blob so we can make measurements of it
	
    
    if numberOfBlobs == 0
		% Didn't detect any blobs of the specified color in this image.
		meanHSV = [0 0 0];
		areas = 0;
		return;
	end
    
	% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
	blobMeasurementsHue = regionprops(labeledImage, hImage, 'area', 'MeanIntensity','Centroid');
	blobMeasurementsSat = regionprops(labeledImage, sImage, 'area', 'MeanIntensity','Centroid');
	blobMeasurementsValue = regionprops(labeledImage, vImage, 'area', 'MeanIntensity','Centroid');  
	
    %Using CC instead of BW
    CC = bwconncomp(maskImage,8);
    Blob_info = regionprops('table',maskImage,'Centroid','MajorAxisLength','MinorAxisLength');
    centr = Blob_info.Centroid;
    y = size(maskImage);
    y=y(1);
    centr(:,2) = -1*centr(:,2) + y;

%     figure(14);
%     hold on
%     viscircles(centr,radii);
%     hold off
%     
%     cent = regionprops(CC,'Centroid');
%     centr = zeros(numberOfBlobs,2);
%     c = struct2cell(cent);
%     cr= cell2mat(c)';
%     num=1;
%     for p=1:numberOfBlobs*2
%        if mod(p,2)~=0 %p is odd
%        centr(num,1)=cr(p,1); 
%        centr(num,2)=cr(p+1,1);
%        num=num+1;
%        end
%     end
%     centr
    %     for p = 1:numberOfBlobs
%         centr(p,:) = cent(p,1);
%     end

    
	meanHSV = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	meanHSV(:,1) = [blobMeasurementsHue.MeanIntensity]';
	meanHSV(:,2) = [blobMeasurementsSat.MeanIntensity]';
	meanHSV(:,3) = [blobMeasurementsValue.MeanIntensity]';
	
	% Now assign the areas.
	areas = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	areas(:,1) = [blobMeasurementsHue.Area]';
	areas(:,2) = [blobMeasurementsSat.Area]';
	areas(:,3) = [blobMeasurementsValue.Area]';
    
    %Assigning centroids
    centroidsHue = zeros(numberOfBlobs,2);
	centroidsHue(:) = [blobMeasurementsHue.Centroid];
   
    centroidsSat = zeros(numberOfBlobs,2);
	centroidsSat(:) = [blobMeasurementsSat.Centroid];
    
    centroidsValue = zeros(numberOfBlobs,2);
	centroidsValue(:) = [blobMeasurementsValue.Centroid];
    centroids = [centroidsHue];
%         ; centroidsSat; centroidsValue]
    
catch ME
	errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end
return; % from MeasureBlobs()