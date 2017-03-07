function ind = findClosestCentroid(clickx, clicky, centroids)
minDist = calDistance(clickx, clicky, centroids(1).Centroid(1),centroids(1).Centroid(2));
ind = 1;
for i=2:size(centroids,1)
    if minDist > calDistance(clickx, clicky, centroids(i).Centroid(1),centroids(i).Centroid(2))
        ind = i;
    end
end