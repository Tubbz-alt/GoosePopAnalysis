function [] = Scan_for_Images(handles)
%Scan jpg and png files in directory

png_files = struct2cell(dir('*.png'));
jpg_files = struct2cell(dir('*.jpg'));
image_files = [png_files, jpg_files];
[rows, columns]= size(image_files);

if columns > 0
   image_files = image_files(1,1:columns);
   set(handles.popupmenu1, 'String', image_files); 
else
   set(handles.popupmenu1,'String', 'No files found');
end
end

