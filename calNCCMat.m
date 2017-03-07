function NCC = calNCCMat(patch, image)
NCC = zeros(size(image,1),size(image,2));
patchCenter = ceil([size(patch,1) size(patch,2)]/2);
patchR = patch(:,:,1); patchG = patch(:,:,2); patchB = patch(:,:,3);
meanPatchR = repmat(mean(patchR(:)),size(patch,1),size(patch,2)); 
meanPatchG = repmat(mean(patchG(:)),size(patch,1),size(patch,2)); 
meanPatchB = repmat(mean(patchB(:)),size(patch,1),size(patch,2)); 
sdR = std(patchR(:)); sdG = std(patchG(:)); sdB = std(patchB(:));
for r=patchCenter(1):size(image,1)-patchCenter(1)+1
    for c=patchCenter(2):size(image,2)-patchCenter(2)+1
        patchFromImage = image(r-patchCenter(1)+1:r+patchCenter(1)-1,...
            c-patchCenter(2)+1:c+patchCenter(2)-1,:);
        patchImR = patchFromImage(:,:,1); 
        patchImG = patchFromImage(:,:,2); 
        patchImB = patchFromImage(:,:,3);
        meanPatchImR = repmat(mean(patchImR(:)),size(patchFromImage,1),size(patchFromImage,2)); 
        meanPatchImG = repmat(mean(patchImG(:)),size(patchFromImage,1),size(patchFromImage,2)); 
        meanPatchImB = repmat(mean(patchImB(:)),size(patchFromImage,1),size(patchFromImage,2));
        sdImR = std(patchImR(:)); sdImG = std(patchImG(:)); sdImB = std(patchImB(:)); 
        NCCR = sum(((patchImR-meanPatchImR).*(patchR-meanPatchR))/(sdR*sdImR));
        NCCG = sum(((patchImG-meanPatchImG).*(patchG-meanPatchG))/(sdG*sdImG));
        NCCB = sum(((patchImB-meanPatchImB).*(patchB-meanPatchB))/(sdB*sdImB));
        NCC(r,c) = sum(NCCR)+sum(NCCG)+sum(NCCB); %Since both are images, not to be divided by (size-1)
    end
end