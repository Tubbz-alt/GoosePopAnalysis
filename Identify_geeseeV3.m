function [handles] = Identify_geeseV3(handles)
%% Part 1: Goose Identification
%Setup for RGB mask for later
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

    
% Detect edges
image = handles.image_filter;
image = rgb2gray(image);
[~, threshold] = edge(image, 'sobel');
fudgeFactor = .5;
BWs = edge(image,'sobel', threshold * fudgeFactor);

% Dilate

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil = imdilate(BWs, [se90 se0]);

% Fill

BWdfill = imfill(BWsdil, 'holes');

% Smoothen

BWnobord = imclearborder(BWdfill, 4);
seD = strel('diamond',1);
BWfinal = imerode(BWnobord,seD);
BWfinal = imerode(BWfinal,seD);

coloredObjectsMask = cast(BWfinal, 'like', rgbImage);
maskedRGB=coloredObjectsMask.*rgbImage;
handles.maskedRGB = maskedRGB;


%% Part 2: Goose Classification
gooseprops = regionprops(BWfinal,image,'MeanIntensity','Centroid','MajorAxisLength','MinorAxisLength');
gooseprops = struct2cell(gooseprops);
gooseprops = gooseprops.';
gooseintensities = cell2mat(gooseprops(:,2));
goosecentroids = cell2mat(gooseprops(:,1));
goosemajlength = cell2mat(gooseprops(:,3));
gooseminlength = cell2mat(gooseprops(:,4));
goosetype = kmeans(gooseintensities,3);
j = 1;
k = 1;
l = 1;

for i = 1:size(goosetype,1)
    if goosetype(i) == 1
        geesearray1(j,1) = goosecentroids(i,1);
        geesearray1(j,2) = goosecentroids(i,2);
        radius1(j) = goosemajlength(i)*0.5;
        j = j + 1;
    elseif goosetype(i) == 2
        geesearray2(k,1) = goosecentroids(i,1);
        geesearray2(k,2) = goosecentroids(i,2);
        radius2(k) = goosemajlength(i)*0.5;
        k = k + 1;
    elseif goosetype(i) == 3
        geesearray3(l,1) = goosecentroids(i,1);
        geesearray3(l,2) = goosecentroids(i,2);
        radius3(l) = goosemajlength(i)*0.5;
        l = l + 1;
    end
end

%visualizing the grouped geese
imgsize = size(image);
axes(handles.axes18);
cla(handles.axes18);
viscircles([geesearray1(:,1) -geesearray1(:,2)],radius1);
xlim([0, imgsize(2)]);
ylim([-imgsize(1),0]);

axes(handles.axes19);
cla(handles.axes19);
viscircles([geesearray2(:,1) -geesearray2(:,2)],radius2);
xlim([0, imgsize(2)]);
ylim([-imgsize(1),0]);

axes(handles.axes20);
cla(handles.axes20);
viscircles([geesearray3(:,1) -geesearray3(:,2)],radius3);
xlim([0, imgsize(2)]);
ylim([-imgsize(1),0]);

geesearray1
geesearray2
geesearray3


handles.geese1_array = geesearray1;
handles.geese2_array = geesearray2;
handles.geese3_array = geesearray3;

%generate BW image with geese locations
geese_locs1_bw = false(imgsize);
rows_y=imgsize(1);
columns_x = imgsize(2);
for i = 1:size(geesearray1,1)
    column_x = floor(geesearray1(i,1));
    row_y = floor(geesearray1(i,2));
    geese_locs1_bw(row_y, column_x) = true;
end
handles.geese1_locations = geese_locs1_bw;

geese_locs2_bw = false(imgsize);
for i = 1:size(geesearray2,1)
    column_x = floor(geesearray2(i,1));
    row_y = floor(geesearray2(i,2));
    geese_locs2_bw(row_y, column_x) = true;
end
handles.geese2_locations = geese_locs2_bw;

geese_locs3_bw = false(imgsize);
for i = 1:size(geesearray3,1)
    column_x = floor(geesearray3(i,1));
    row_y = floor(geesearray3(i,2));
    geese_locs3_bw(row_y, column_x) = true;
end
handles.geese3_locations = geese_locs3_bw;
