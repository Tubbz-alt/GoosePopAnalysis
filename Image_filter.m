function [ image_filter ] = Image_filter( handles )

sigma = str2double(get(handles.edit3, 'String'));

image_string = get(handles.popupmenu1, 'String');
image_num = get(handles.popupmenu1,'Value');
image_filter = imread(image_string{image_num});
image = image_filter;

image_filter(:,:,1) = imgaussfilt(image(:,:,1),sigma);
image_filter(:,:,2) = imgaussfilt(image(:,:,2),sigma);
image_filter(:,:,3) = imgaussfilt(image(:,:,3),sigma);

axes(handles.axes1);
imshow(image_filter);
% colorThresholder(image_filter);
end

