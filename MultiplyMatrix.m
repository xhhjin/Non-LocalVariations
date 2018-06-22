function C = MultiplyMatrix(A,B)
 C = zeros([size(A, 1), size(A, 2), size(A, 3), size(B, 4)]);

for i = 1:size(A,3)
    for j = 1:size(B,4)
        C(:,:,i,j) = sum(squeeze(A(:,:,i,:)) .* squeeze(B(:,:,:,j)), 3);
    end
end


%C = squeeze(sum(bsxfun(@times, A,permute(B,[1,2,4,3])),4));

