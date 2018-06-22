function [img_out, img_b] = ResizeConsistentOut(img_in, fromScale, toScale, FinestLevelSize)
beta = exp(-1); % The antialiasing gaussian filter drops to beta at the Nyquist frequency
Q = FinestLevelSize(1);
R = FinestLevelSize(2);
K = size(img_in, 3);
L = size(img_in, 4);
[Qi, Ri, ~, ~] = size(img_in);
% Prepare antialiasing filter
samplingRatio = toScale / fromScale;
if samplingRatio < 1
    sigma = sqrt(-2*log(beta)) / (samplingRatio * pi);
    h = fspecial('gaussian', ceil(sigma * 5), sigma);
else
    h = 1;
end
% [xFrom, yFrom] = meshgrid(linspace(1, R, Ri),linspace(1, Q, Qi));
% [xTo, yTo] = meshgrid(linspace(1, R, ceil(R*toScale)),linspace(1, Q, ceil(Q*toScale)));
xF = 1:(1/fromScale):R;
yF = 1:(1/fromScale):Q;

xT = 1:(1/toScale):R;
yT = 1:(1/toScale):Q;

padsize = 0;

 padsize = ceil(max(1,max(abs(R-max(xT(:))), abs(Q-max(yT(:))))));
 img_in = padarray(img_in, [padsize padsize], 'replicate', 'post');


[xFrom, yFrom] = meshgrid(1:(1/fromScale):R+padsize*(1/fromScale),1:(1/fromScale):Q+padsize*(1/fromScale));
[xTo, yTo] = meshgrid(1:(1/toScale):R+padsize*(1/toScale),1:(1/toScale):Q+padsize*(1/toScale));

% Resample
img_out = zeros([size(xTo), K]);
if(h~=1)
    img_b = imfilter(img_in,h,'conv', 'replicate');
else
    img_b = img_in;
end

for k=1:K
    for l = 1:L
        
        img_out(:,:,k,l) = interp2(xFrom,yFrom,img_b(:,:,k,l) , xTo,yTo,'spline');
    end
end

if(padsize)
    img_out =  img_out(1:length(yT), 1:length(xT),:,:);
end