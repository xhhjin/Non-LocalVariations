function  Res = VisualizeExaggColor(img, A, step)
[Q,R,K] = size(img);
E = Identity([Q,R,K-1,K-1]);

A_inv = InvMatrix(A);

h = figure;
global Res;

i = 0;
Ie = img;
Ie_y = rgb2ycbcr(Ie);
fhandle = get(h, 'KeyPressFcn');
    function  KeyPressCb(~,evnt)
        
        fprintf('key pressed: %s\n',evnt.Key);
        
        if strcmpi(evnt.Key,'leftarrow')
            i = i-step;
            cla;
            figure(h);
            
            for ii=1:step
                [Ie,Ie_y] = ApplyColorTrans(A_inv, im2double(Ie_y));
                
            end
            % Ie = Ie./max(Ie(:));
            imshow(Ie,[] ); drawnow;
            title(['Exgg val=' num2str(i)]);
        elseif strcmpi(evnt.Key,'rightarrow')
            i = i + step;
            cla;
            %subplot(1,2,2);
            for ii=1:step
                [Ie,Ie_y] = ApplyColorTrans(A, im2double(Ie_y));
            end
            
            imshow(Ie ,[]); drawnow;
            
            title(['Exgg val=' num2str(i)]);
        elseif  strcmpi(evnt.Key,'return')
            SetOutput(Ie, A);
            set(h,'KeyPressFcn', fhandle) ;
        end
        
    end
set(h,'KeyPressFcn',@KeyPressCb) ;

end


function SetOutput(Ie, A)
global Res;
Res.Ie = Ie;
Res.A = A;
end
