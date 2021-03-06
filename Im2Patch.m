function  X  =  Im2Patch( im, par )
b        =  par.win;     
s        =  par.step;    
b2       =  b*b;
[h  w]   =  size(im);     

N        =  h-b+1;
M        =  w-b+1;
%Y       =   zeros(f*f, L, 'single');

r        =  [1:s:N];
r        =  [r r(end)+1:N];
c        =  [1:s:M];         
c        =  [c c(end)+1:M];

k    =  0;
for i  = 1:b
    for j  = 1:b
        k      =  k+1;
       blk     =  im(r-1+i,c-1+j);  
        Y(k,:) =  blk(:)';        
    end
end
X=double(Y);