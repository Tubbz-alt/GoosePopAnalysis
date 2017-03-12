%% Part 5: Identifying the nesting pairs

% List all geese

k = 1;
for i = 1:size(bwimage,1)
    for j = 1:size(bwimage,2)
        if bwimage(i,j) == 1
            geesearray(k,1) = i;
            geesearray(k,2) = j;
            k = k + 1;
        end 
    end
end

% calculate 3 metres

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

bwnests = false(size(bwimage,1),size(bwimage,2));
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
figure;
plot(t,k);

