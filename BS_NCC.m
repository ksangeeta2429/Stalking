background = double(imread('bgvideo5.jpg'));
videoObject = VideoReader('video5_small.avi');
frame = struct('data',zeros(videoObject.height,videoObject.width,'double'));
frameRGB = struct('data',zeros(videoObject.height,videoObject.width,3,'double'));
outputObject = VideoWriter('output5.avi');
open(outputObject);
objThresh = 150; 
upperThresh = 0;
lowerThresh = 0;
sqDilate = 3;
bwArea = 300;
counter = 1;
NCCThresh = 0;
NCCThreshPerc = 0.9;
padding = 50;
windowSize = 20;
while hasFrame(videoObject)
    f = readFrame(videoObject);
    frame(counter).data = double(rgb2gray(f));
    frameRGB(counter).data = double(f);
    if counter == 1
        background = frame(1).data;
    else
        frame(counter).data = double(imdilate(bwareaopen(bwmorph(abs(...
            frame(counter).data - background) > objThresh, 'clean'),...
            bwArea),strel('square',sqDilate)));
    end
    counter = counter + 1;
end
centroids = [];
counter = 2;
while size(centroids,1) < 2
    centroids = regionprops(logical(frame(counter).data),'Centroid', 'BoundingBox');
    if size(centroids,1) > 0
        frame(counter).data = insertShape(frame(counter).data, 'circle', ...
            [centroids(1).Centroid(1) centroids(1).Centroid(2) 2], 'Color', ...
            'red', 'LineWidth', 5);
    end
    counter = counter + 1;
end
imshow(frame(counter).data);
disp('Tag person');
[clickx, clicky] = ginput(1);
ind = findClosestCentroid(clickx,clicky, centroids); 
%could use check for click inside bounding box instead
mainX = centroids(ind).Centroid(1);
mainY = centroids(ind).Centroid(2);
mainVector = [0 0];
disp(mainX);
disp(mainY);
mainPatch = frameRGB(counter).data(round(centroids(ind).BoundingBox(2))...
    :round(centroids(ind).BoundingBox(2))+centroids(ind).BoundingBox(4),...
    round(centroids(ind).BoundingBox(1)):round(centroids(ind).BoundingBox(1))...
    +centroids(ind).BoundingBox(3),:);
k = 1;
otherObjects = zeros(size(centroids,1)-1,2);
for i=1:size(centroids,1)
    if i~=ind
        otherObjects(k,:) = [centroids(i).Centroid];
        %for tracking everyone:
        %otherPatches(:,:,k) = frameRGB(counter).data(round(centroids(i).BoundingBox(1)):...
        %    round(centroids(i).BoundingBox(1)+centroids(i).BoundingBox(3)), ...
        %    round(centroids(i).BoundingBox(2):centroids(i).BoundingBox(2))+...
        %    round(centroids(i).BoundingBox(4)));
        k = k + 1;
    end
end
frame(counter).data = insertShape(frame(counter).data, 'circle', [mainX ...
    mainY 10], 'Color', 'red', 'LineWidth', 5);
prev = frame(counter).data;
counter = counter + 1;
mainXNew = 0; mainYNew = 0;
while counter < size(frame,2)
    centroids = regionprops(logical(frame(counter).data),'Centroid', 'BoundingBox');
    upperThresh = upperThresh + sqrt(sum(mainVector.*mainVector));
    probabilities = zeros(size(otherObjects,1),1);
    otherVectors = zeros(size(otherObjects,1),2);
    otherObjectsNew = zeros(size(otherObjects,1),2);
    maxVal = 0; maxInd = 0;
    refPatch = zeros(2*padding+videoObject.height,2*padding+videoObject.width,3);
    refPatch(padding+1:padding+videoObject.height,padding+1:...
        padding+videoObject.width,:) = frameRGB(counter).data;
    NCCThresh = maxVal;
    for i=1:size(centroids,1)
        NCCMat = calNCCMat(mainPatch,refPatch(...
            round(centroids(i).Centroid(2)+padding-windowSize):...
            round(centroids(i).Centroid(2)+padding+windowSize), ...
            round(centroids(i).Centroid(1)+padding-windowSize):...
            round(centroids(i).Centroid(1)+padding+windowSize),:));
        if max(NCCMat) > maxVal
            [maxVal, maxInd] = max(NCCMat);
        end
    end
    if maxVal > NCCThreshPerc* NCCThresh 
        mainXNew = ceil(maxInd/size(NCCMat,1));
        mainNew = maxInd - (mainXNew-1)*size(NCCMat,1);
        mainPatch = frame(counter).data(round(centroids(maxInd).BoundingBox(2))...
            :round(centroids(maxInd).BoundingBox(2))+centroids(maxInd).BoundingBox(4),...
            round(centroids(maxInd).BoundingBox(1)):round(centroids(maxInd).BoundingBox(1))...
            +centroids(maxInd).BoundingBox(3));
    end
    mainVector = [mainXNew - mainX mainYNew - mainY];
    otherObjectNew = [0 0];
    for i=1:size(otherObjects,1)
        otherVectors = [otherObjectsNew(i,1)-otherObjects(i,1) ...
            otherObjectsNew(i,2)-otherObjects(i,2)];
        probabilities(i) = probabilities(i) + dot(mainVector, otherVectors);
    end
    frame(counter).data = insertShape(frame(counter).data, 'line', [mainX ...
        mainY mainXNew mainYNew], 'Color', 'red', 'LineWidth', 2);
    frame(counter).data = insertShape(frame(counter).data, 'circle', ...
        [mainXNew mainYNew 2], 'Color', 'red', 'LineWidth', 5);
    frame(counter).data = insertShape(frame(counter).data, 'line', ...
        [otherObjects(:,1) otherObjects(:,2) otherObjectsNew(:,1) ...
        otherObjectsNew(:,2)], 'Color', 'green', 'LineWidth', 2);
    frame(counter).data = insertShape(frame(counter).data, 'circle', ...
        [otherObjects(:,1) otherObjects(:,2) 2], 'Color', 'green', ...
        'LineWidth', 5);
        
    [maxVal, maxInd] = max(probabilities);
    [minVal, minInd] = min(probabilities);
    if maxVal > upperThresh && counter > 240 %at least 4 seconds
        frame(counter).data = insertShape(frame(counter).data, 'circle', ...
            [otherObjects(maxInd,1) otherObjects(maxInd,2) 15], 'Color', ...
            'red', 'LineWidth', 5);
        disp('Stalker highlighted');
        for i=1:counter
                writeVideo(outputObject,mat2gray(frame(i).data));
        end
        close(outputObject);
        exit;
    end
    if minVal < lowerThresh
        otherObjectsNew(minInd,:) = [];
        probabilities(minInd) = [];
    end
    %Instead of finding orthogonal vectors and checking sides:
    for i=1:size(otherObjectsNew,1)
        if (mainYNew > mainY && otherObjectsNew(i,2) > mainYNew)||...
                (mainYNew < mainY && otherObjectsNew(i,2) < mainYNew)
            otherObjectsNew(i,:) = [];
            probabilities(i) = [];
        elseif (mainXNew > mainX && otherObjectsNew(i,1) > mainXNew)||...
                (mainXNew < mainX && otherObjectsNew(i,1) < mainXNew)
            otherObjectsNew(i,:) = [];
            probabilities(i) = [];
        end
    end
    prev = frame(counter).data;
    counter = counter+1;
    mainX = mainXNew; mainY = mainYNew;
    otherObjects = otherObjectsNew;
end
for i=1:counter-1
    writeVideo(outputObject,mat2gray(frame(i).data));
end
close(outputObject);