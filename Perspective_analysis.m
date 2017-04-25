function [] = Perspective_analysis(handles)

image_string = get(handles.popupmenu1, 'String');
image_num = get(handles.popupmenu1,'Value');
image = imread(image_string{image_num});
axes(handles.axes1);
imshow(image);

focLength = str2double(get(handles.edit1, 'String'));
flyHeight = str2double(get(handles.edit2, 'String'));

[imgWidthPix,imgHeightPix] = size(image);
% imgWidth = imgWidthPix * flyHeight / (focLength/ 1000);
% imgHeight = imgHeightPix * flyHeight / (focLength / 1000);
% pixWidth = imgWidth / imgWidthPix;
% pixHeight = imgHeight / imgHeightPix;
% <<<<<<< Updated upstream
% imgWidth = 8;
% imgHeight = 4.88;
% pixWidth = 4.88/488;
% pixHeight = 8/800;
% =======

pixWidth = 2 * flyHeight * tan(31.09 * pi / 180) / imgWidthPix;
pixHeight = 2 * flyHeight * tan(18.71 * pi / 180) / imgHeightPix;
% >>>>>>> Stashed changes

image_properties = [imgWidth, imgHeight; pixWidth, pixHeight];
Rows = ({'Image', 'Pixel'});
Columns = ({'Width', 'Height'});
set(handles.uitable1, 'Data', image_properties,...
    'RowName', Rows, 'ColumnName', Columns);
end

