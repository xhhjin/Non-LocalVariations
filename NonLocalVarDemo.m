% a demo for running Non-Local Variations (NLV) Alg. [1]
% [1] Revealing and Modyfing Non-Local Variations in a Single Image
%     T.Dekel, T. Michaeli, M. Irani, and W.T. Freeman, SigAsia 2015

%%
addpath(genpath(cd),1);
%% Running Geometric mode
% read input image
img = im2double(imread('images/corn.png'));

% set parameters
param.Smin = 4;
param.Smax = 9;
param.alpha = 0.03;
param.lambda = 30;
param.DeviationsType = 'Geom';

% run Non Local Variations Alg.
Res = NonLocalVarMultiScale(img, param);


% show results
IdealImg = Res(1).img_regular; % get the finest idealized image;

% 'correcting'/'idealizing' the input image
[uxf_correct, uyf_correct] = FlowConsistency2(Res(1).ux,Res(1).uy, 200); % make sure to correct flips 
CorrectedImg = warpImage(im2double(img),uxf_correct,uyf_correct,1);

figure;
subplot(1,3,1); imshow(img,[]); title('Input');
subplot(1,3,2); imshow(IdealImg,[]); title('Ideal');
subplot(1,3,3); imshow(CorrectedImg, []); title('Corrected');

% exaggerating by 2
[uxf_exagg, uyf_exagg] = FlowConsistency2(-2*Res(1).ux,-2*Res(1).uy, 200); % make sure to correct flips 
CorrectedImg = warpImage(im2double(img),uxf_exagg,uyf_exagg,1);

figure;
subplot(1,3,1); imshow(img,[]); title('Input');
subplot(1,3,2); imshow(IdealImg,[]); title('Ideal');
subplot(1,3,3); imshow(CorrectedImg, []); title('Exaggerated x2');

%% Running Color Mode
clear all;
param.Smin = 6;
param.Smax = 6;
param.alpha = 5;
param.PatchSize = [5 5];
param.NumNN = 10;
param.lambda = 20;
param.DeviationsType = 'Color';

img = im2double(imread('images/lizard.png'));
Res = NonLocalVarMultiScale(img, param);

CorrectedImg = ApplyColorTrans(Res.A, rgb2ycbcr(img));
% press return to exit VisualizeExaggColor and get the exaggerated image
% and corresponding transformation
res_exagg = VisualizeExaggColor(img, Res(1).A, 5);
%%
%figure;
subplot(1,3,1); imshow(img,[]); title('Input');
subplot(1,3,2); imshow(CorrectedImg,[]); title('Corrected');
subplot(1,3,3); imshow(img, []); title('Exaggerated, press <-- or -->');
%subplot(1,3,3); imshow(res_exagg.Ie, []); title('Exaggerated');


