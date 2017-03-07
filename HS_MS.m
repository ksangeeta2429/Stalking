videoObject = VideoReader('samples\sample2.m4v');
outputObject = VideoWriter('output4.avi');
outputFile = fopen('output.txt','wt');
open(outputObject);
counter = 1;
detect = vision.PeopleDetector;
boxes = [];
click = 0;
frame = struct('data',zeros(videoObject.height,videoObject.width,3,'uint8'));
frameVid = struct('data',zeros(videoObject.height,videoObject.width,3,'uint8'));
while hasFrame(videoObject)
    frame(counter).data = readFrame(videoObject); 
    counter = counter + 1;
end
counter = 1;
k = 1;
while size(boxes,1) < 2
    disp('Finding people'); 
    boxes = step(detect,frame(counter).data);
    boxCenters = zeros(size(boxes,1),2);
    for i = 1:size(boxes,1)
        boxCenters(i,:) = [(boxes(i,1)+boxes(i,3)/2) (boxes(i,2)+boxes(i,4)/2)];
    end
    %Display image:
    imshow(frame(counter).data);
    hold on
    for i = 1: size(boxes,1)
        rectangle('Position', boxes(i,:), 'EdgeColor', 'r', 'LineWidth', 5);
    end
    hold off
    %Write as video:
    frameVid(k).data = frame(counter).data;
    for i = 1: size(boxes,1)
        frameVid(k).data = insertShape(frameVid(k).data,'Rectangle',boxes(i,:),...
            'Color', 'red', 'LineWidth', 5);
    end  
    counter = counter+1;
    k= k+1;
end
while counter < size(frame,2) && (click==0 || size(secCenters,1)~=0)        
    if click == 0
        disp('Tag person');
        click = 1;
        [clickx, clicky] = ginput(1);
        minDist = calDistance(clickx, clicky, boxCenters(1,1), boxCenters(1,2));
        ind = 1;
        for i=2:size(boxes,1)
            if minDist > calDistance(clickx, clicky, boxCenters(i,1), boxCenters(i,2))
                ind = i;
            end
        end
        secCenters = zeros(size(boxes,1)-1,2); 
        j=1;
        for i=1:size(boxes,1)
            if i~=ind
                secCenters(j,:) = boxCenters(i,:);
                j = j+1;
            end
        end
        clickx = boxCenters(ind,1);
        clicky = boxCenters(ind,2);
        disp(clickx); disp(clicky);
        probabilities = zeros(size(secCenters,1),1);
        upperThresh = 0;
        frameVid(k).data = insertShape(frame(counter).data, 'circle', [clickx clicky 15], ...
            'Color', 'red', 'LineWidth', 5);
    else
        [clickx2, clicky2] = meanShift(clickx, clicky, double(frame(counter).data), double(prev));
        mainVector = [clickx2-clickx clicky2-clicky];
        frameVid(k).data = insertShape(frame(counter).data, 'line', [clickx clicky...
            clickx2 clicky2], 'Color', 'red', 'LineWidth', 2);
        frameVid(k).data = insertShape(frameVid(k).data, 'circle', [clickx clicky 2], ...
            'Color', 'red', 'LineWidth', 5);
        secCenters2 = zeros(size(boxes,1)-1,2); 
        secVectors = zeros(size(boxes,1)-1,2);
        for i=1:size(boxes,1)-1
            [secCenters2(i,1), secCenters2(i,2)] = meanShift(secCenters(i,1), ...
                secCenters(i,2), double(frame(counter).data), double(prev));
            secVectors = [secCenters2(i,1)-secCenters(i,1) secCenters2(i,2)-secCenters(i,2)];
            probabilities(i) = probabilities(i) + dot(mainVector, secVectors);
            frameVid(k).data = insertShape(frameVid(k).data, 'line', [secCenters(i,1) secCenters(i,2) ...
                secCenters2(i,1) secCenters2(i,2)], 'Color', 'green', 'LineWidth', 2);
            frameVid(k).data = insertShape(frameVid(k).data, 'circle', [secCenters(i,1) secCenters(i,2)...
                2], 'Color', 'green', 'LineWidth', 5);
        end
        clickx = clickx2; clicky = clicky2;
        secCenters = secCenters2;
        fprintf(outputFile,'%d main: %f %f others: ', counter, clickx, clicky);
        for i = 1:size(secCenters,1)
            fprintf(outputFile,'%f %f ',secCenters(i,1), secCenters(i,2));
        end
        [maxVal, maxInd] = max(probabilities);
        [minVal, minInd] = min(probabilities);
        if maxVal>upperThresh && counter > 240 %at least 4 seconds
            frameVid(k).data = insertShape(frameVid(k).data, 'circle', [secCenters(maxInd,1)...
                secCenters(maxInd,2) 15], 'Color', 'red', 'LineWidth', 5);
            disp('Stalker highlighted');
            for i=1:k-1
                writeVideo(outputObject,frameVid(i).data);
            end
            close(outputObject);
            fclose(outputFile);
            exit
        end
        if minVal<0
            %Remove from secCenters
            %%Added with BG Subtraction code
        end
        %Code for overtaking
        %%Added with BG Subtraction code
    end
    prev = frame(counter).data;
    counter = counter+5;
    k = k+1;
end
for i=1:k-1
    writeVideo(outputObject,frameVid(i).data);
end
close(outputObject);
fclose(outputFile);