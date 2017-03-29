function [handles] = Identify_geeseV2(handles)

    [rgbImage, storedColorMap] = imread('Filtered_img.bmp'); 
    [rows, columns, numberOfColorBands] = size(rgbImage);
 
	if strcmpi(class(rgbImage), 'uint8')
		% Flag for 256 gray levels.
		eightBit = true;
	else
		eightBit = false;
    end
    if numberOfColorBands == 1
		if isempty(storedColorMap)
			% Just a simple gray level image, not indexed with a stored color map.
			% Create a 3D true color image where we copy the monochrome image into all 3 (R, G, & B) color planes.
			rgbImage = cat(3, rgbImage, rgbImage, rgbImage);
		else
			% It's an indexed image.
			rgbImage = ind2rgb(rgbImage, storedColorMap);
			% ind2rgb() will convert it to double and normalize it to the range 0-1.
			% Convert back to uint8 in the range 0-255, if needed.
			if eightBit
				rgbImage = uint8(255 * rgbImage);
			end
		end
    end 
    
    % Display the original image.
% 	subplot(3, 4, 1);
	% Set up an infor panel so you can mouse around and inspect the value values.
% 	hrgbPI = impixelinfo(hRGB);
% 	set(hrgbPI, 'Units', 'Normalized', 'Position',[.15 .69 .15 .02]);

    % Convert RGB image to HSV
	hsvImage = rgb2hsv(rgbImage);
	% Extract out the H, S, and V images individually
	hImage = hsvImage(:,:,1);
	sImage = hsvImage(:,:,2);
	vImage = hsvImage(:,:,3);
    
    % Compute and plot the histogram of the "hue" band.
	[hueCounts, hueBinValues] = imhist(hImage); 
	maxHueBinValue = find(hueCounts > 0, 1, 'last'); 
	maxCountHue = max(hueCounts); 
    
    % Compute and plot the histogram of the "saturation" band.
	[saturationCounts, saturationBinValues] = imhist(sImage); 
	maxSaturationBinValue = find(saturationCounts > 0, 1, 'last'); 
	maxCountSaturation = max(saturationCounts); 
    
    % Compute and plot the histogram of the "value" band.
	[valueCounts, valueBinValues] = imhist(vImage); 
	maxValueBinValue = find(valueCounts > 0, 1, 'last'); 
	maxCountValue = max(valueCounts); 
    
    for j=1:3
    if j==1 %Green
    hueThresholdLow = 0.15;
	hueThresholdHigh = 0.60;
	saturationThresholdLow = 0.36;
	saturationThresholdHigh = 1;
	valueThresholdLow = 0;
	valueThresholdHigh = 0.8;
    elseif j==2 %Green
    hueThresholdLow = 0.15;
	hueThresholdHigh = 0.60;
	saturationThresholdLow = 0.36;
	saturationThresholdHigh = 1;
	valueThresholdLow = 0;
	valueThresholdHigh = 0.8;
    elseif j==3 %Green
    hueThresholdLow = 0.15;
	hueThresholdHigh = 0.60;
	saturationThresholdLow = 0.36;
	saturationThresholdHigh = 1;
	valueThresholdLow = 0;
	valueThresholdHigh = 0.8;
    end
    
    % This will apply the color band's particular thresholds to the color band
	hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
	saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
	valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

%     figure(25);
%     imshow(hueMask);
%     figure(26);
%     imshow(saturationMask);
%     figure(27);
%     imshow(valueMask);
    
   
    %combine the masks
   	coloredObjectsMask = uint8(hueMask & saturationMask & valueMask);
   
    % filter out small objects, may not be necessary due to other filter
	smallestAcceptableArea = 0; % Keep areas only if they're bigger than this.
    % Get rid of small objects.  Note: bwareaopen returns a logical.
	coloredObjectsMask = uint8(bwareaopen(coloredObjectsMask, smallestAcceptableArea));
    
    % Smooth the border using a morphological closing operation, imclose().
	structuringElement = strel('disk', 4);
	coloredObjectsMask = imclose(coloredObjectsMask, structuringElement);
    
    % Fill in any holes in the regions, since they are most likely red also.
	coloredObjectsMask = imfill(logical(coloredObjectsMask), 'holes');
    %plot the geese bw 
    if j==1
    axes(handles.axes6);
    elseif j==2
    axes(handles.axes7);
    elseif j==3
    axes(handles.axes8);
    end
    imshow(coloredObjectsMask, []);
    
   
    % You can only multiply integers if they are of the same type.
	% (coloredObjectsMask is a logical array.)
	% We need to convert the type of coloredObjectsMask to the same data type as hImage.
%     coloredObjectsMask = cast(coloredObjectsMask, 'like', rgbImage); 
%     
%     % Use the colored object mask to mask out the colored-only portions of the rgb image.
%     maskedImageR = coloredObjectsMask .* rgbImage(:,:,1);
% 	maskedImageG = coloredObjectsMask .* rgbImage(:,:,2);
% 	maskedImageB = coloredObjectsMask .* rgbImage(:,:,3);
%    
     %Supporting function for measuring areas of geese MeasuringBlobs in a
    %different file
%     [meanHSV, areas, centroids, numberOfBlobs] = MeasureBlobs(coloredObjectsMask, hImage, sImage, vImage);
    
    [meanHSV, centroids, numberOfBlobs] = MeasureBlobs(coloredObjectsMask, hImage, sImage, vImage);
% figure(14);
%     hold on
%     viscircles(centroids,radii);
%     hold off
    geese_locations_bw = false(size(coloredObjectsMask));
    img_size = size(coloredObjectsMask);
    rows_y = img_size(1);
    columns_x = img_size(2);
    for i=1:numberOfBlobs
       column_x = floor(centroids(i,1));
       row_y = rows_y - floor(centroids(i,2));
       geese_locations_bw(row_y,column_x)=true;
%        for p =1:3
%            geese_locations_bw(row_y+p, column_x+p)=true;
%            geese_locations_bw(row_y-p, column_x+p)=true;
%            geese_locations_bw(row_y+p, column_x-p)=true;
%            geese_locations_bw(row_y-p, column_x-p)=true;
%        end
    end
    
    
   %plot the nest locations
   if j==1
%    axes(handles.axes9);
% figure(18);
   handles.geese1_locations = geese_locations_bw;
   elseif j==2
%    axes(handles.axes10);
   handles.geese2_locations = geese_locations_bw;
   elseif j==3
%    axes(handles.axes11);
   handles.geese3_locations = geese_locations_bw;
   end
%    imshow(geese_locations_bw);
%    
    end
end

