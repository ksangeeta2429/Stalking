function histo = colorHistogram(X,bins,x,y,h)
histo = zeros(bins,bins,bins);
for i = 1:size(X,1)
    r = (sqrt((x-X(i,1))^2+(y-X(i,2))^2)/h)^2;
    if(r<1)     %Epanechnikov kernel 
       l = round(floor(X(i,3)*bins/256))+uint8(1);     %RED
       m = round(floor(X(i,4)*bins/256))+uint8(1);     %BLUE
       n = round(floor(X(i,5)*bins/256))+uint8(1);     %GREEN
       histo(l,m,n) = histo(l,m,n) + (1-r);
    end
end
histo = histo/sum(histo(:));