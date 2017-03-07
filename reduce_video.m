videoObject = VideoReader('samples\video4.mp4');
outputObject = VideoWriter('video4_small.avi');
frame = struct('data',zeros(videoObject.height/2,videoObject.width/2,3,'uint8'));
counter = 1;
open(outputObject);
while hasFrame(videoObject)
    f = readFrame(videoObject); 
    frame(counter).data = imresize(f, [480 640]);
    writeVideo(outputObject,frame(counter).data);
    counter = counter + 1;
end
close(outputObject);
