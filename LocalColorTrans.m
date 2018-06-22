function [A, img1_trns] = LocalColorTrans(img1, img2, A, alpha)
if(~exist('alpha', 'var'))
    alpha = 10;
end
NumIter = 300;
epsilon1 = 1e-3; % data term
epsilon2 = 1e-3; % smoothness term

h = [0 1 0; 1 0 1; 0 1 0] / 4;
[Q,R,K] = size(img1);
I = Identity([Q,R,K,K]);
if ~exist('A', 'var') || isempty(A)
    A = I;
end
img1NormSq = sum(img1.^2,3);
for i = 1:NumIter
    A_pad = padarray(A,[1,1,0,0],'replicate');
    A_avg = imfilter(A_pad, h); A_avg = A_avg(2:end-1,2:end-1,:,:);
    A_x = imfilter(A_pad, [-1 1]); A_x = A_x(2:end-1,2:end-1,:,:);
    A_y = imfilter(A_pad, [-1 1]'); A_y = A_y(2:end-1,2:end-1,:,:);

    W1 = sqrt(sum((MultiplyMatrix(A, img1) - img2).^2,3) + epsilon1^2);
    W2 = sqrt(sum(sum(A_x.^2 + A_y.^2, 4), 3) + epsilon2^2);
    W = W1 ./ W2;
    denominator = repmat(alpha.*W + img1NormSq, [1,1,K,K]);
    A = A_avg + MultiplyVecVecTraspose(img2 - MultiplyMatrix(A_avg, img1), img1) ./ denominator;   
end
img1_trns = MultiplyMatrix(A, img1);


function C = MultiplyVecVecTraspose(A,B)
C = zeros([size(A) size(B,3)]);
for i = 1:size(A,3)
    for j = 1:size(B,3)
        C(:,:,i,j) = A(:,:,i) .* B(:,:,j);
    end
end




% function C = MultiplyMatrixTrasposeVec(A,B)
% C = sum(bsxfun(@times, A, B), 4);

% function C = MultiplyVecTrasposeVec(A,B)
% C = sum(A.*B,3);
