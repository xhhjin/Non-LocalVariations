function C = Identity(sz)
C = zeros(sz);
for i = 1:sz(3)
    C(:,:,i,i) = 1;
end