clear;
Original_image_dir  =    'C:\Users\csjunxu\Desktop\ECCV2016\1_Results\NoisyImage\Real\';
fpath = fullfile(Original_image_dir, 'Real_ISO1600_AlexanderSemenov.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
load Lib\PCA_AR_TD2_c2
for i = 1:im_num
    IMin=im2double(imread(fullfile(Original_image_dir, im_dir(i).name)));
    S = regexp(im_dir(i).name, '\.', 'split');
    IMname = S{1};
    % color or gray image
    [h,w,ch] = size(IMin);
    if h >= 600
        IMin = IMin(ceil(h/2)-300+1:ceil(h/2)+300,:,:);
    end
    if w >= 800
        IMin = IMin(:,ceil(w/2)-400+1:ceil(w/2)+400,:);
    end
    [h,w,ch] = size(IMin);
    if ch==1
        IMin_y = IMin;
    else
        % change color space, work on illuminance only
        IMin_ycbcr = rgb2ycbcr(IMin);
        IMin_y = IMin_ycbcr(:, :, 1);
        IMin_cb = IMin_ycbcr(:, :, 2);
        IMin_cr = IMin_ycbcr(:, :, 3);
    end
    %% denoising
    par.PCA_D         =   PCA_D;
    par.Codeword   =   centroids;
    par.nim = IMin_y*255;
    par.I = IMin_y*255;
    [par.pim,ind]      =   adpmedft(par.nim,19);
    par.nSig             =   NoiseLevel(par.nim);
    fprintf('The noise level is %2.2f.\n',par.nSig);
    [Iout_y,PSNR,FSIM]      =   WESNR_Denoising( par );
    Iout_y(Iout_y>255)=255;
    Iout_y(Iout_y<0)=0;
    if ch==1
        Iout = Iout_y/255;
    else 
        Iout_ycbcr = zeros([h,w,ch]);
        Iout_ycbcr(:, :, 1) = Iout_y/255;
        Iout_ycbcr(:, :, 2) = IMin_cb;
        Iout_ycbcr(:, :, 3) = IMin_cr;
        Iout = ycbcr2rgb(Iout_ycbcr);
    end
    %% output
    imwrite(Iout, ['C:/Users/csjunxu/Desktop/ECCV2016/1_Results/WESNR/Real/WESNR_Real_' IMname '.png']);
end