function [handles] = Identify_Geese( handles )

cform = makecform('srgb2lab');
lab_image = applycform(handles.maskedRGB,cform);
ab = double(lab_image(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

nColors = str2double(get(handles.edit4,'String'));

% repeat the clustering 3 times to avoid local minima
[cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
pixel_labels = reshape(cluster_idx,nrows,ncols);


% create 4 binary image masks
geese1 = pixel_labels == 1;
size1 = sum(sum(geese1));
geese2 = pixel_labels == 2;
size2 = sum(sum(geese2));
geese3 = pixel_labels == 3;
size3 = sum(sum(geese3));
geese4 = pixel_labels == 4;
size4 = sum(sum(geese4));


%compare sizes and find the three geese
[Y,largestInd] = max([size1,size2,size3,size4]);

switch largestInd
    case 1
        geese1 = pixel_labels == 4;
    case 2
        geese2 = pixel_labels == 4;
    case 3
        geese3 = pixel_labels == 4;
end

clear largestInd size1 size2 size3 size4 Y geese4;



% Dilate
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
BWsdil1 = imdilate(geese1, [se90 se0]);
BWsdil2 = imdilate(geese2, [se90 se0]);
BWsdil3 = imdilate(geese3, [se90 se0]);

% Fill
BWdfill1 = imfill(BWsdil1, 'holes');
BWdfill2 = imfill(BWsdil2, 'holes');
BWdfill3 = imfill(BWsdil3, 'holes');

% Smoothen
BWnobord1 = imclearborder(BWdfill1, 4);
BWnobord2 = imclearborder(BWdfill2, 4);
BWnobord3 = imclearborder(BWdfill3, 4);

seD = strel('diamond',1);
BWfinal1 = imerode(BWnobord1,seD);
BWfinal1 = imerode(BWfinal1,seD);

BWfinal2 = imerode(BWnobord2,seD);
BWfinal2 = imerode(BWfinal2,seD);

BWfinal3 = imerode(BWnobord3,seD);
BWfinal3 = imerode(BWfinal3,seD);





%object classification by object size

% SUGGESTION:
% By finding the actual area of a rubber goose we can determine
% which objects are actual geese and which are not. By creating an
% object-size histogram we can locate exactly where on the histogram the 
% average goose should be (and also double check our pixel to meter 
% conversion). Objects that are too large or too small to be a goose will
% be classified as noise


% if the colour of the geese is previously known we can pre code the colour
% of the geese to identify them

%first goose
objects = bwconncomp(BWfinal1,4);
n1 = objects.NumObjects;
dataGeese1 = regionprops(objects,'basic');

Geesedata1 = struct2cell(dataGeese1);
Geesedata1 = Geesedata1.';
centroids1 = cell2mat(Geesedata1(:,2));
area1 = cell2mat(Geesedata1(:,1));

geese_locs1_bw = false(size(BWfinal1));
for i = 1:size(centroids1,1)
    column_x = floor(centroids1(i,1));
    row_y = floor(centroids1(i,2));
    geese_locs1_bw(row_y, column_x) = true;
end
handles.geese1_locations = geese_locs1_bw;
axes(handles.axes2);
cla(handles.axes2);
viscircles([centroids1(:,1) , -centroids1(:,2)], sqrt(area1/pi));
xlim([0, size(BWfinal1,2)]);
ylim([-size(BWfinal1,1),0]);

%second goose
objects = bwconncomp(BWfinal2,4);
n2 = objects.NumObjects;
dataGeese2 = regionprops(objects,'basic');

Geesedata2 = struct2cell(dataGeese2);
Geesedata2 = Geesedata2.';
centroids2 = cell2mat(Geesedata2(:,2));
area2 = cell2mat(Geesedata2(:,1));

geese_locs2_bw = false(size(BWfinal1));
for i = 1:size(centroids2,1)
    column_x = floor(centroids2(i,1));
    row_y = floor(centroids2(i,2));
    geese_locs2_bw(row_y, column_x) = true;
end
handles.geese2_locations = geese_locs2_bw;
axes(handles.axes3);
cla(handles.axes3);
viscircles([centroids2(:,1) , -centroids2(:,2)], sqrt(area2/pi));
xlim([0, size(BWfinal1,2)]);
ylim([-size(BWfinal1,1),0]);


%third goose
objects = bwconncomp(BWfinal3,4);
n3= objects.NumObjects;
dataGeese3 = regionprops(objects,'basic');

Geesedata3 = struct2cell(dataGeese3);
Geesedata3 = Geesedata3.';
centroids3 = cell2mat(Geesedata3(:,2));
area3 = cell2mat(Geesedata3(:,1));

geese_locs3_bw = false(size(BWfinal1));
for i = 1:size(centroids3,1)
    column_x = floor(centroids3(i,1));
    row_y = floor(centroids3(i,2));
    geese_locs3_bw(row_y, column_x) = true;
end
handles.geese3_locations = geese_locs3_bw;
axes(handles.axes4);
cla(handles.axes4);
viscircles([centroids3(:,1) , -centroids3(:,2)], sqrt(area3/pi));
xlim([0, size(BWfinal1,2)]);
ylim([-size(BWfinal1,1),0]);


histData = zeros(2,1);
for i = 1:size(dataGeese1,1)
    histData(i) = dataGeese1(i).Area;
end
histSize = size(histData);
for i = 1:size(dataGeese2,1)
    histData(i + histSize) = dataGeese2(i).Area;
end
histSize = size(histData);
for i = 1:size(dataGeese3,1)
    histData(i + histSize) = dataGeese3(i).Area;
end

BW = mean(histData)/10;
axes(handles.axes5);
areaHist = histogram(histData,'Binwidth',BW);
[Y,I] = max(areaHist.Values);
I = (I + 0.5) * BW;


% %% Part 5: Statistical Analysis
% %apply the Ripleys K factor to the 'clean version' of the image
% 
% objects = bwconncomp(geese1,4);
% n = objects.NumObjects;
% data = regionprops(objects,'basic');
% [m,o] = size(maskedImg1);
% t = 0:1:m;
% A = m * o;
% lambda = n/A;
% sizes = size(t);
% sum1 = zeros(1,sizes(2));
% for i = 1:sizes(2)
%     for j = 1:size(data,1)
%         for p = 1:size(data,1)
%             distvect = data(p).Centroid - data(j).Centroid;
%             distance = sqrt(distvect(1)^2 + distvect(2)^2);
%             if distance < t(1,i)
%                 sum1(1,i) = sum1(1,i) + 1;
%             end
%         end
%     end
% end
% k = sum1/(lambda * n);
% axes(handles.axes2);
% plot(t,k);
% 
% objects = bwconncomp(geese2,4);
% n = objects.NumObjects;
% sum2 = zeros(1,sizes(2));
% for i = 1:sizes(2)
%     for j = 1:size(data,1)
%         for p = 1:size(data,1)
%             distvect = data(p).Centroid - data(j).Centroid;
%             distance = sqrt(distvect(1)^2 + distvect(2)^2);
%             if distance < t(1,i)
%                 sum2(1,i) = sum2(1,i) + 1;
%             end
%         end
%     end
% end
% k = sum2/(lambda * n);
% axes(handles.axes3);
% plot(t,k);
% 
% objects = bwconncomp(geese3,4);
% n = objects.NumObjects;
% sum3 = zeros(1,sizes(2));
% for i = 1:sizes(2)
%     for j = 1:size(data,1)
%         for p = 1:size(data,1)
%             distvect = data(p).Centroid - data(j).Centroid;
%             distance = sqrt(distvect(1)^2 + distvect(2)^2);
%             if distance < t(1,i)
%                 sum3(1,i) = sum3(1,i) + 1;
%             end
%         end
%     end
% end
% k = sum3/(lambda * n);
% axes(handles.axes4);
% plot(t,k);
% 






end

