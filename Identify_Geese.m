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

objects = bwconncomp(geese1,4);
n1 = objects.NumObjects;
axes(handles.axes2);
imshow(geese1);

dataGeese1 = regionprops(objects,'basic');
objects = bwconncomp(geese2,4);
n2 = objects.NumObjects;
axes(handles.axes3);
imshow(geese2);

dataGeese2 = regionprops(objects,'basic');
objects = bwconncomp(geese3,4);
n3= objects.NumObjects;
dataGeese3 = regionprops(objects,'basic');
axes(handles.axes4);
imshow(geese3);


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

