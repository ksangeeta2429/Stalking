function [outX, outY] = meanShift(x,y, frame, prev)
colors = 16;
radius = 15;
X = circularNeighbors(prev,x,y,radius);
q_model = colorHistogram(X,colors,x,y,radius);
outX = x; outY = y;
for i=1:25
    N = circularNeighbors(frame,outX,outY,radius);
    p_test = colorHistogram(N,colors,outX,outY,radius);
    w = meanshiftWeights(N,q_model,p_test);
    xVal = 0;
    yVal = 0;
    wVal = 0;
    for j=1:size(N,1)
        wVal = wVal + w(j);
        xVal = xVal + (N(j,1) * w(j));
        yVal = yVal + (N(j,2) * w(j));
    end
    outX = xVal/wVal;
    outY = yVal/wVal;
end