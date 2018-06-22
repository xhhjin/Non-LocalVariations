function [u,v,map_init,map_final] = FlowConsistency2(u,v, iter_num, filtSize)
% FlowConsistency2(u,v,iter_num, filtSize) a function that correct for
% 'flips' in warping field (u,v). Specifically it looks at the Jacobian of
% the transformation (smooth the flow where the determinant of the Jacobian
% is negetive. See paper for more details.

if(isempty(iter_num) || ~exist('iter_num', 'var'))
    iter_num = 30;
end
ShowRes = false;
u = padarray(u,[10,10],'replicate');
v = padarray(v,[10,10],'replicate');

hx = [-1 0 1; -2 0 2; -1 0 1] / 8;
hy = hx';

ux = filter2(hx, u);
uy = filter2(hy, u);
vx = filter2(hx, v);
vy = filter2(hy, v);
map_init = (1+ux) .* (1+vy) - vx.*uy;
map_init(1:10,:)=0; map_init(:,1:10)=0; map_init(end-9:end,:)=0; map_init(:,end-9:end)=0;
se = strel('disk',8);
map_final = map_init;
h = fspecial('gaussian', 10, 2);
if ShowRes
    figure('doublebuffer', 'on')
    imshow(map_init<0), drawnow
end
for i = 1:iter_num
    ind = imdilate(map_final<0, se);    
    u_filt = filter2(h, u);
    v_filt = filter2(h, v);
    u(ind) = u_filt(ind);
    v(ind) = v_filt(ind);
    ux = filter2(hx, u);
    uy = filter2(hy, u);
    vx = filter2(hx, v);
    vy = filter2(hy, v);
    map_final = (1+ux) .* (1+vy) - vx.*uy;
    map_final(1:10,:)=0; map_final(:,1:10)=0; map_final(end-9:end,:)=0; map_final(:,end-9:end)=0;
%     if ShowRes
%         imshow(map_final<0), title(num2str(i)), drawnow
%     end
%     if ~any(map_final<0)
%         break
%     end
end

u = u(11:end-10, 11:end-10);
v = v(11:end-10, 11:end-10);

if(exist('filtSize', 'var') & ~isempty(filtSize))
    h = fspecial('gaussian', filtSize, filtSize/5);
    u = u - imfilter(u, h, 'replicate');
    v = v - imfilter(v, h, 'replicate');
end
    