function w = meanshiftWeights(X,q_model,p_test)
bins = size(q_model,1);
w = zeros(size(X,1),1);
for i = 1:size(X,1)
    l = round(floor(X(i,3)*bins/256))+uint8(1);     %RED
    m = round(floor(X(i,4)*bins/256))+uint8(1);     %BLUE
    n = round(floor(X(i,5)*bins/256))+uint8(1);     %GREEN
    w(i) =((q_model(l,m,n)/p_test(l,m,n))^0.5);
end
