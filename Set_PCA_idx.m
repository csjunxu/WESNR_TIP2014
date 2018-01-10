function  [PCA_D, PCA_idx, s_idx, seg,D1]  =  Set_PCA_idx( im, par, codewords)

[h  w]     =  size(im);   
im         =  double(im);
cls_num    =  size( codewords, 2 );   
LP_filter  =  fspecial('gaussian', 7, par.sigma);  
lp_im      =  conv2(im,LP_filter);
lp_im      =  lp_im(4:h+3, 4:w+3);
hp_im      =  im - lp_im;   


b          =  par.win; 
s          =  par.step;  
N          =  h-b+1;    
M          =  w-b+1;    

r          =  [1:s:N];
r          =  [r r(end)+1:N]; 
c          =  [1:s:M];
c          =  [c c(end)+1:M];
L          =  length(r)*length(c);

X          =  zeros(b*b, L, 'single');


% For the Y component
k    =  0;
for i  = 1:b
    for j  = 1:b
        k    =  k+1;

        blk    =  hp_im(r-1+i,c-1+j);  
        X(k,:) =  blk(:)';        
    end
end
PCA_idx   =  zeros(L, 1);

m         =  mean(X);   
d         =  ( X - m( ones(size(X,1),1), :) ).^2;     
v         =  sqrt( mean( d ) );
[a, ind]  =  find( v<par.nSig );    %ind为找到满足条件的指标


set         =  [1:L];
set(ind)    =  [];  
L2          =  size(set,2);  %

for i = 1:L2
    
    wx             =   X(:, set(i));              
    wx             =   wx(:, ones(1,cls_num));       %     wx            =   repmat( X(:,set(i)), 1, cls_num );
    dis            =   sum( (wx - codewords).^2 );        
    [md, idx]      =   min(dis);
PCA_idx( set(i) )  =   idx;


end

[s_idx, seg]       =   Proc_cls_idx( PCA_idx );
PCA_D              =   par.PCA_D(:, 2:end);
D1                 =   reshape(par.PCA_D(:,1), b*b,b*b);    



return;
        