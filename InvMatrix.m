function Ainv = InvMatrix(A)
[Q,R, c, c] = size(A);
a = A(:,:,1,1);
b = A(:,:,1,2);
c = A(:,:,2,1);
d = A(:,:,2,2);

Ainv(:,:,1,1) = d;
Ainv(:,:,2,2) = a;
Ainv(:,:,1,2) = -b;
Ainv(:,:,2,1) = -c;
Det = a.*d - b.*c;
Ainv = bsxfun(@rdivide, Ainv, Det);