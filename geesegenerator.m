bwimage = true(300,300);

for i = 1:size(bwimage,1)
    for j = 1:size(bwimage,2)
        r = rand;
        if r >= 0.001
            bwimage(i,j) = false;
            k = 2;
        end
    end
end

pixWidth = 0.25;
pixheigth = 0.25;
imgWidth = 1200;
imgHeight = 1200;