function [img_regular, img_warped, A] = NonLocalVarColorMain(img, param, img_regular, A)

% NonLocalVarColorMain -

if(~isfield(param, 'show_res'))
    show_res = 1;
else
    show_res = param.show_res;
end

if(~isfield(param, 'PatchSize'))
    PatchSize = [15,15];
else
    PatchSize = param.PatchSize;
end

if(~isfield(param, 'alpha'))
    alpha = 0.04; % relative weight of the smoothness term of the flow
else
    alpha = param.alpha;
end

if(~isfield(param, 'lambda'))
    lambda = 20;
else
    lambda = param.lambda;
end

if(~isfield(param, 'val_intrep'))
    val_intrep = [];
else
    val_intrep = param.val_intrep;
end


% Number of outer iterations
if(~isfield(param, 'NumIterOuter'))
    NumIterOuter = 10;
else
    NumIterOuter = param.NumIterOuter;
end

% Number of inner iterations
if(~isfield(param, 'NumIterInner'))
    NumIterInner = 5;
else
    NumIterInner = param.NumIterInner;
end

% Number of NN
if(~isfield(param, 'NumNN'))
    NumNN = 20;
else
    NumNN = param.NumNN;
end
if ~isfield(param, 'propImgRegular')
    propImgRegular = 0 ;
else
    propImgRegular = param.propImgRegular;
end


img = im2double(img);
[Q,R,K] = size(img);
figure, imshow(img), title('Input image')

% initalization
if (~exist('A', 'var') || isempty(A))
    A = Identity([Q,R,K-1,K-1]);
end

img_y = rgb2ycbcr(img);
img_warped = ApplyColorTrans(A, img_y);
img_warped_y = rgb2ycbcr(img_warped);

if  ~propImgRegular || ~exist('img_regular', 'var') || isempty(img_regular)
    img_regular = img_warped;
end


ann = [];

if(show_res)
    h_main = figure('doublebuffer', 'on');
    h_main2 = figure('doublebuffer', 'on');
end

for i = 1:NumIterOuter
    
    disp(['Outer Iter:' num2str(i) ' out of ' num2str(NumIterOuter)]);
    
    [img_regular,ann] = UpdateImage(img_warped, img_regular, img_warped, PatchSize, NumIterInner, NumNN, lambda, ann, show_res);
    img_regular_y = rgb2ycbcr(img_regular);
    
    [A, img_warped_y(:,:,2:3)] = LocalColorTrans(img_y(:,:,2:3), img_regular_y(:,:,2:3), A, alpha);
    img_warped= ycbcr2rgb(img_warped_y);
    
    if(show_res)
        figure(h_main2); imshow(img_regular), title(['Regular Image, iteration ' num2str(i)])%, colorbar
        figure(h_main), subplot(3,1,1), imshow(img), title('Input Image')%, colorbar
        figure(h_main), subplot(3,1,2), imshow(img_regular), title(['Regular Image, iteration ' num2str(i)])%, colorbar
        figure(h_main), subplot(3,1,3), imshow(img_warped), title(['Color Transformed, iteration ' num2str(i)])%, colorbar
        drawnow
    end
end
end

function [img_new, ann] = UpdateImage(WarpedImage, img, img_DB, PatchSize, NumIter, NumNN, lambda, ann, show_res)

h = 0.1; %Bandwidth paramter of NN weights kernel
beta = 1 / h^2;
PM=1;
if(NumNN==1)
    NumNNin = [];
else
    NumNNin = NumNN;
end

img_new = img;


for i = 1:NumIter
    ann  = nnmex(img_new,img_DB, 'cputiled', PatchSize, [], [], [], [], [], 12, [], [], [], [], [], NumNNin, []);
    Dist = double(squeeze(ann(:,:,3,:)))/65025/3;
    
    
    % computing weights
    W = Dist;
    W = exp(-0.5*W/prod(PatchSize)/h^2);
    W = bsxfun(@rdivide, W, sum(W, 3));
    
    
    img_new = ind2ImAvg_mex(im2double(img_DB), int32(squeeze(ann(:,:,1,:))+1), int32(squeeze(ann(:,:,2,:))+1), W,PatchSize(1), PatchSize(2));
    
    
    PsiD  = 1./sqrt(mean((WarpedImage - img_new).^2, 3) + 1e-3);
    PsiD = repmat(PsiD,[1,1,3]);
    img_new = (lambda*PsiD.*WarpedImage +  beta * img_new)./ (lambda.*PsiD + beta );
    
    
    if(i> 1 & mean(abs(img_prev(:)-img_new(:))) < 5e-4)
        break;
    else
        img_prev = img_new;
    end
    
end
end
