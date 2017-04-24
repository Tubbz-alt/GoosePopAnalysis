%% Part 1: Goose Identification
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

%% Part 2: Goose Classification

gooseprops = regionprops(BWfinal,image,'MeanIntensity','Centroid');
gooseprops = struct2cell(gooseprops);
gooseprops = gooseprops.';
gooseintensities = cell2mat(gooseprops(:,2));
goosecentroids = cell2mat(gooseprops(:,1));
goosetype = kmeans(gooseintensities,3);
j = 1;
k = 1;
l = 1;

for i = 1:size(goosetype,1)
    if goosetype(i) == 1
        geesearray1(j,1) = goosecentroids(i,1);
        geesearray1(j,2) = goosecentroids(i,2);
        j = j + 1;
    elseif goosetype(i) == 2
        geesearray2(k,1) = goosecentroids(i,1);
        geesearray2(k,2) = goosecentroids(i,2);
        k = k + 1;
    elseif goosetype(i) == 3
        geesearray3(l,1) = goosecentroids(i,1);
        geesearray3(l,2) = goosecentroids(i,2);
        l = l + 1;
    end
end

handles.geese1_locations = geesearray1;
handles.geese2_locations = geesearray2;
handles.geese3_locations = geesearray3;

