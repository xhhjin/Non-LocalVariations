function [imgColorTranRGB,imgColorTranY] = ApplyColorTrans(A, img_y)
imgColorTranY = img_y;
imgColorTranY(:,:,2:3) = MultiplyMatrix(A, img_y(:,:,2:3));

imgColorTranRGB = ycbcr2rgb(imgColorTranY);
%imgColorTranRGB = (imgColorTranRGB+min(imgColorTranRGB(:)))./max(imgColorTranRGB(:));