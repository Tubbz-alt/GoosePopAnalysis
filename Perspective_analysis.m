function [] = Perspective_analysis(handles)

image_string = get(handles.popupmenu1, 'String');
image_num = get(handles.popupmenu1,'Value');
image = imread(image_string{image_num});
axes(handles.axes1);
imshow(image);

focLength = str2double(get(handles.edit1, 'String'));
flyHeight = str2double(get(handles.edit2, 'String'));

[imgWidthPix,imgHeightPix] = size(image);
imgWidth = imgWidthPix * flyHeight / (focLength/ 1000);
imgHeight = imgHeightPix * flyHeight / (focLength / 1000);
pixWidth = imgWidth / imgWidthPix;
pixHeight = imgHeight / imgHeightPix;

image_properties = [imgWidth, imgHeight; pixWidth, pixHeight];
Rows = ({'Image', 'Pixel'});
Columns = ({'Width', 'Height'});
set(handles.uitable1, 'Data', image_properties,...
    'RowName', Rows, 'ColumnName', Columns);
end

