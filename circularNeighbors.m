function [ X ]=circularNeighbors(img,x,y,radius)
c=1;
for i = 1:size(img,1)
    for j = 1:size(img,2)
        if(calDistance(i,j,x,y)<radius)
            X(c,:) = [i j img(j,i,1) img(j,i,2) img(j,i,3)];
            c = c+1;
        end
    end
end
