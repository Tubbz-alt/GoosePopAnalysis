function [] = part5kfactorcalc(handles)
%% Part 5: Identifying the nesting pairs

% List all geese
bwimage1 = handles.geese1_locations;
% bwimage2 = handles.geese2_location_bw;
% bwimage3 = handles.geese2_location_bw;


k = 1;
for i = 1:size(bwimage1,1)
    for j = 1:size(bwimage1,2)
        if bwimage1(i,j) == 1
            geesearray(k,1) = i;
            geesearray(k,2) = j;
            k = k + 1;
        end 
    end
end

% calculate 3 metres in pixels
% formula: pixWidth = meters per pixel -> (pixels in 3m)= 3m / ( n meters per pixel)
pix = get(handles.uitable1);
pixHeight = pix.Data(2,2);
pixWidth = pix.Data(2,1);
imgWidth = pix.Data(1,2);
imgHeight = pix.Data(1,1);
pixels3m = 3 / pixWidth;


% identify nests
k = 1;
for i = 1:size(geesearray,1)
    for j = i:size(geesearray,1)
        if sqrt(((geesearray(i,1)-geesearray(j,1))^2)+((geesearray(i,2)-geesearray(j,2))^2)) < pixels3m
            nests(k,1) = round((geesearray(i,1) + geesearray(j,1))/2);
            nests(k,2) = round((geesearray(i,2) + geesearray(j,2))/2);
            k = k + 1;
        end
    end
end

bwnests = false(size(bwimage1,1),size(bwimage1,2));
for i = 1:size(nests,1)
    if bwnests(nests(i,1),nests(i,2)) == 1
        bwnests(nests(i,1),nests(i,2)) = 0;
    else
        bwnests(nests(i,1),nests(i,2)) = 1;
    end
end


m = round(imgWidth);
n = size(nests,1);
t = 0:1:m;
A = imgWidth * imgHeight;
lambda = n/A;
sizes = size(t);
sum = zeros(1,sizes(2));
for i = 1:sizes(2)
    for j = 1:size(nests,1)
        for p = 1:size(nests,1)
            distvect(1) = nests(p,1) - nests(j,1);
            distvect(2) = nests(p,2) - nests(j,2);
            distance = sqrt(distvect(1)^2 + distvect(2)^2);
            if distance < t(1,i)
                sum(1,i) = sum(1,i) + 1;
            end
        end
    end
end
k = sum/(lambda * n);
axes(handles.axes12);
figure(15)
plot(t,k);

end