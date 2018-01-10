%--------------------------------------------------------------------------
% Utilities functions
%--------------------------------------------------------------------------
function  [im_out  T] =  WESNR1(Y, im, PCA_idx, PCA_D, par, s_idx, seg, A,Arr,Wei)
b        =  par.win;     
s        =  par.step;   
lamba    =  par.lamba;
 beta    =  par.beta; 
 vpsilon =  par.em;
b2       =  b*b;
[h1  w1] =  size(im);     

N        =  h1-b+1;
M        =  w1-b+1;
r        =  [1:s:N];
r        =  [r r(end)+1:N];
c        =  [1:s:M];         
c        =  [c c(end)+1:M];
X0       =  zeros(b*b, N*M);  
X_m      =  zeros(b*b,length(r)*length(c),'single');
N        =  length(r);   
M        =  length(c);   
L        =  N*M;


% For the Y component
k    =  0;
for i  = 1:b
    for j  = 1:b
        k      =  k+1;
       blk     =  im(r-1+i,c-1+j);  
        X(k,:) =  blk(:)';        
    end
end
X=double(X);



k    =  0;
for i  = 1:b
    for j  = 1:b
        k        =  k+1;        
        blk      =  im(i:end-b+i,j:end-b+j);  
        X0(k,:)  =  blk(:)';                          
    end
end


for i = 1:par.nblk
   v             =  Wei(i,:);    
   X_m           =  X_m(:,:) + X0(:, Arr(i, :)) .*v(ones(b2,1), :);   
end

idx              =  s_idx(seg(1)+1:seg(2));
for i=1:size(idx,1)
       Phi       =   A;
       P         =   X(:,idx(i));
       y         =   Y(:,idx(i));
       residual  =    (y-P).^2;
       mu        =    Phi'*X_m(:,idx(i));
       w         =   1./exp(beta*residual);
       w         =   diag(w);
       V         =   eye(size(Phi',1));
       q1        =   Phi'*w*Phi+V; 
       q2        =   Phi'*w*P-Phi'*w*X_m(:,idx(i));
       temp_s    =   inv(q1)*q2;
       residual  =   (y-P).^2;
    w            =   1./exp(beta*residual);
     V           =   lamba./sqrt((temp_s).^2+vpsilon^2);
     V           =   diag(V);
  

  Cu0(:,idx(i))  =   Phi*(temp_s+mu);
    T(:,idx(i))  =   diag(V);
    
end
set      =   1:size(X_m,2);     %1 2....7056
set(idx) =   [];




%length(seg)-1
for   j  = 2:length(seg)-1
  idx          =   s_idx(seg(j)+1:seg(j+1));   
   for i=1:size(idx,1)
     cls       =   PCA_idx(idx(i));  
     Phi       =   reshape(PCA_D(:, cls), b2, b2);
     P         =   X(:,idx(i));
     y         =   Y(:,idx(i));
     mu        =   Phi'*X_m(:,idx(i));
     residual  =   (y-P).^2;
     w         =   1./exp(beta*residual);   
     w         =   diag(w);
     V         =   eye(size(Phi',1));
    q1         =   Phi'*w*Phi+V; 
    q2         =   Phi'*w*P-Phi'*w*X_m(:,idx(i));
    temp_s     =   inv(q1)*q2;
  residual     =   (y-P).^2;
    w          =   1./exp(beta*residual);
     V         =   lamba./sqrt((temp_s).^2+vpsilon^2);
     V         =   diag(V);

           
Cu0(:,idx(i))  =   Phi*(temp_s+mu);
 T(:,idx(i))   =   diag(V);
    end
end



    

im_out   =  zeros(h1,w1);
im_wei   =  zeros(h1,w1);
k        =  0;
for i  = 1:b
    for j  = 1:b
        k    =  k+1;
        im_out(r-1+i,c-1+j)  =  im_out(r-1+i,c-1+j) + reshape( Cu0(k,:)', [N M]);
        im_wei(r-1+i,c-1+j)  =  im_wei(r-1+i,c-1+j) + 1;       
    end
end

im_out  =  im_out./im_wei;

 