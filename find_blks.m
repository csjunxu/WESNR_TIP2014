function [blk_arr, wei_arr]  =  find_blks(im, par)
%pim      =  medfilt2(im(:,:),[3 3],'symmetric');
S         =  12;     % Larger value, higher computational complexity
f         =  par.win;      %f=7
f2        =  f^2;  
nv        =  par.nblk;     %nv =15
s         =  par.step;     %s=3
hp        =  70;          

N         =  size(im,1)-f+1;   %N=250 
M         =  size(im,2)-f+1;   %M =250
r         =  [1:s:N];
r         =  [r r(end)+1:N];
c         =  [1:s:M];
c         =  [c c(end)+1:M];
L         =  N*M;            %L =62500
X         =  zeros(f*f, L, 'single');
%Y         =  zeros(f*f, L, 'single');

% For the Y component
k    =  0;
for i  = 1:f
    for j  = 1:f
        k    =  k+1;
        blk  =  im(i:end-f+i,j:end-f+j);  %250*250
        X(k,:) =  blk(:)';                %49*62500
    end
end

%k    =  0;
%for i  = 1:f
%    for j  = 1:f
%        k    =  k+1;
%        blk  =  pim(i:end-f+i,j:end-f+j);  %250*250
%        Y(k,:) =  blk(:)';                %49*62500
%    end
%end


% Index image
I     =   (1:L);
I     =   reshape(I, N, M);    %N=M=250
N1    =   length(r);           %N1 =84  M1 ==84
M1    =   length(c);
blk_arr   =  zeros(nv, N1*M1 );   %15*7056
wei_arr   =  zeros(nv, N1*M1 ); 
X         =  X';                  %62500*49
%Y         =  Y';


for  i  =  1 :N1
    for  j  =  1 : M1
        
        row     =   r(i);
        col     =   c(j);
        off     =  (col-1)*N + row;
        off1    =  (j-1)*N1 + i;
                
        rmin    =   max( row-S, 1 );
        rmax    =   min( row+S, N );
        cmin    =   max( col-S, 1 );
        cmax    =   min( col+S, M );
         
        idx     =   I(rmin:rmax, cmin:cmax);
        idx     =   idx(:);
        B       =   X(idx, :);        
        v       =   X(off, :);   %1*49
        
        
        dis     =   (B(:,1) - v(1)).^2;
        for k = 2:f2
            dis   =  dis + (B(:,k) - v(k)).^2;
        end
        dis   =  dis./f2;
        [val,ind]   =  sort(dis);        
        dis(ind(1))  =  dis(ind(2));
               
        
        wei         =  exp( -dis(ind(1:nv))./hp );   %15*1
        wei         =  wei./(sum(wei)+eps);                 
        indc        =  idx( ind(1:nv) );   %距离最小的前15列对应的指标
        blk_arr(:,off1)  =  indc;          %15*7056
        wei_arr(:,off1)  =  wei;
    end
end



% function [blk_arr, wei_arr]  =  find_blks(im, par)
% 
% S         =  10;
% f         =  par.win;
% nv        =  par.nblk;
% s         =  par.step;
% hp        =  70;
% 
% N         =  size(im,1)-f+1;
% M         =  size(im,2)-f+1;
% r         =  [1:s:N];
% r         =  [r r(end)+1:N];
% c         =  [1:s:M];
% c         =  [c c(end)+1:M];
% L         =  N*M;
% X         =  zeros(f*f, L, 'single');
% 
% 
% % For the Y component
% k    =  0;
% for i  = 1:f
%     for j  = 1:f
%         k    =  k+1;
%         blk  =  im(i:end-f+i,j:end-f+j);
%         X(k,:) =  blk(:)';
%     end
% end
% 
% 
% % Index image
% I     =   (1:L);
% I     =   reshape(I, N, M);
% N1    =   length(r);
% M1    =   length(c);
% blk_arr   =  zeros(nv, N1*M1 );
% wei_arr   =  zeros(nv, N1*M1 ); 
% 
% for  i  =  1 : N1
%     for  j  =  1 : M1
%         
%         row     =   r(i);
%         col     =   c(j);
%         off     =  (col-1)*N + row;
%         off1    =  (j-1)*N1 + i;
%         
%         rmin    =   max( row-S, 1 );
%         rmax    =   min( row+S, N );
%         cmin    =   max( col-S, 1 );
%         cmax    =   min( col+S, M );
%          
%         idx     =   I(rmin:rmax, cmin:cmax);
%         idx     =   idx(:);
%         L       =   size(idx,1);
%         B       =   X(:, idx);        
%         v       =   X(:,off);
%         W1      =   v(:,ones(1,L));  % repmat(X(:,off),1,L);        
% 
%         mE          =  mean((B-W1).^2);
%         [val,ind]   =  sort(mE);        
%         mE(ind(1))  =  mE(ind(2));
%         
%         wei         =  exp( -mE(ind(1:nv))./hp );
%         wei         =  wei./(sum(wei)+eps);
%         indc        =  idx( ind(1:nv) );
%         blk_arr(:,off1)  =  indc;
%         wei_arr(:,off1)  =  wei;
%     end
% end
% % blk_arr  =  blk_arr';
% % wei_arr  =  wei_arr';
