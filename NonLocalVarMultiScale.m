function Res = NonLocalVarMultiScale(img, param)
% -------------------------------------------------------------------------
% NonLocalVarMultiScale(img, param) coarse to fine implementation of [1]
% Input arguments:
%     img - input image (that input is required to contain repeating structures)
%
%     param - a structure parameter with the following fields
%         (1) sf (0.75) - sampling ratio of the Gaussian pyramid
%         (2) Smin - finest level of the Gaussian pyramid
%         (3) Smax - coarset level of the Gaussian pyramid
%         (4) PatchSize (15x15) - patch size (fixed in all levels)
%         (5) alpha (0.04) regularization weight
%         (6) lambda (20) relative weight between recurrence and fidelity
%         (7) NumIterOuter (20 for the coarset level, 5 for the upper
%         levels) number of outer iterations
%         (8) NumIterInner (10) number of inner iterations
%         (9) NumNN (20) number of nearest neighbours
%         (10) InterpLastLevel (true) - a flag for upsampling the results to
%         the original image resolution
%         (11) propImgRegular - a flag for using the upsampled regular
%         image in the next level as initializtion (if false img_regular is
%         initialized with img_warped)
% Output:
%     Res - result structure that containts the results from all levels
%           Res(1) containts the output from the finest level with the
%           following fields
%       (1) img_in - the input image at the current level
%       (2) img_regular - the 'ideal' image at the current level
%       (3) A - dense, spatially varying color transformation, upsampled to
%       the full resolution.
%       (4) ux, uy - dense warping field (horizontal and vertical) upsampled to
%       the full resolution.
%
% [1] Revealing and Modyfing Non-Local Variations in a Single Image
%     T.Dekel, T. Michaeli, M. Irani, and W.T. Freeman, SigAsia 2015

% Dependencies (included): 
%     PatchMatch http://gfx.cs.princeton.edu/pubs/Barnes_2009_PAR/index.php
%     A modified version of Ce Liu optical-flow implementation:
%     https://people.csail.mit.edu/celiu/OpticalFlow/
% -------------------------------------------------------------------------

% parse input parameters
% -------------------------------------------------------------------------
if ~isfield(param,'sf')
    sf = 0.75;
else
    sf = param.sf;
end
if ~isfield(param, 'DeviationsType')
    DeviationsType = 'Geom';
else
    DeviationsType = param.DeviationsType;
end

if(~isfield(param,'Smin'))
    figure; imshow(img,[]);
    title('Mark Min Psz');
    r = getrect;
    MinPsz = round(max(r(3:4)));
    Smin = [];
else
    Smin = param.Smin;
    
end

if(~isfield(param,'Smax'))
    figure; imshow(img,[]);
    title('Mark Max Psz');
    r = getrect;
    MaxPsz = round(max(r(3:4)));
    Smax = [];
else
    Smax = param.Smax;
    
end

if(~isfield(param,'PatchSize'))
    PatchSize = [15,15];
else
    PatchSize = param.PatchSize;
end

if(~isfield(param,'InterpLastLevel'))
    InterpLastLevel = 1;
else
    InterpLastLevel = param.InterpLastLevel;
end

SetOuter=0;
if(~isfield(param, 'NumIterOuter'))
     setOuter = 1;
 end
% if Smin or Smax are not given, let the user mark the size of the smallest
% and biggest repeating strcture, and compute Smin Smax accordingly
if(isempty(Smin) | isempty(Smax))
    [Smin, Smax] = ComputeMinMaxScales(MinPsz, MaxPsz, PatchSize(1), sf);
    Smin = max(Smin,1);
    Smax = max(Smax, 1);
end
% -------------------------------------------------------------------------
Res(1).Smax = Smax;
Res(1).Smin = Smin;

[Q,R,K] = size(img);
ux = [];
uy = [];
img_regular = [];
A = []';
Levels = Smax:-1:Smin;
scale = power(1/sf, 0:length(Levels)-1);

disp(['Starting Non-Local-Variations Alg.: pyramid-levels=' num2str(Levels(1)) ' image_res=' num2str(Q) 'x' num2str(R)]);

for i = Levels
    if(SetOuter)
        if(i==Levels(1))
            param.NumIterOuter = 20;
        else
            param.NumIterOuter = 5;
        end
    end
    disp(['Level:' num2str(i) ' min level: ' num2str(Smin)]);
    % downsamle the images to the current level resolution
    imgCur = ResizeConsistentOut(img, 1, sf^(i), [Q,R]);
    
    if(i<Smax)
        % Downsample the regular image onto current grid
        % and upsample all results from the coarse grid to the current grid
        img_regular = ResizeConsistentOut(img_regular, sf^(i+1), sf^(i), [Q,R]);
        if(strcmp(DeviationsType, 'Geom'))
            ux = (1/sf) * ResizeConsistentOut(ux, sf^(i+1), sf^(i), [Q,R]);
            uy = (1/sf) * ResizeConsistentOut(uy, sf^(i+1), sf^(i), [Q,R]);
        else
            A = ResizeConsistentOut(A, sf^(i+1), sf^i, [Q,R]);
        end
    end
    %  geometry mode mode
    if(strcmp(DeviationsType, 'Geom'))
        [img_regular, img_warped, ux, uy] = NonLocalVarMain(imgCur, param, img_regular, ux, uy);
        Res(i-Smin+1).ux = (1/sf)^(i) * ResizeConsistentOut(ux, sf^(i), 1, [Q,R]);
        Res(i-Smin+1).uy = (1/sf)^(i) * ResizeConsistentOut(uy, sf^(i), 1, [Q,R]);
    else %  color mode
        [img_regular, img_warped, A] = NonLocalVarColorMain(imgCur, param, img_regular, A);
        Res(i-Smin+1).A = ResizeConsistentOut(A, sf^(i), 1, [Q,R]);
    end
    close all
    Res(i-Smin+1).img_in = imgCur;
    Res(i-Smin+1).img_regular = img_regular;
    
end


function [Smin, Smax] = ComputeMinMaxScales(MinPsz, MaxPsz, Psz, sf)

Smin = ceil(log10(Psz/MinPsz)/log10(sf));
Smax = ceil(log10(Psz/MaxPsz)/log10(sf));
