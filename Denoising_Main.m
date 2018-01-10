clear;

addpath('Utilities');
Original_image_dir        =    'C:\Users\csjunxu\Desktop\Projects\WODL\20images\';
load Data\Lib\PCA_AR_TD2_c2

par.PCA_D                 =   PCA_D;
par.Codeword              =   centroids;


fpath                     =   fullfile(Original_image_dir, '*.png');
im_dir                    =   dir(fpath);
im_num                    =   length(im_dir);

for nSig                      =   [10 20 30]         % The standard variance of the additive Gaussian noise;
    par.nSig                  =   nSig;
    for sp  =   [0.1 0.3 0.5]        % salt and pepper
        Type = 0;
        PSNR = [];
        SSIM = [];
        for i = 1:im_num
            par.I                =   double( imread(fullfile(Original_image_dir, im_dir(i).name)) );
            S = regexp(im_dir(i).name, '\.', 'split');
            randn('seed',0);
            par.nim              =   par.I + nSig*randn(size(par.I));
            [par.nim,Narr]          =   impulsenoise(par.nim,sp,Type);
            imwrite(par.nim/255, ['images/G' num2str(nSig) '_SPIN' num2str(sp) '_' im_dir(i).name]);
            %             if Type == 0
            %                 par.nim = double( imread(['C:/Users/csjunxu/Documents/GitHub/WODL_RID/GINimages/G' num2str(nSig) '_SPIN' num2str(sp) '_' im_dir(i).name]));
            %             elseif Type == 1
            %                 par.nim = double( imread(['C:/Users/csjunxu/Documents/GitHub/WODL_RID/GINimages/G' num2str(nSig) '_RVIN' num2str(sp) '_' im_dir(i).name]));
            %             else
            %                 break;
            %             end
            [par.pim,ind]           =   adpmedft(par.nim,19);
            [im_out PSNRi SSIMi]      =   WESNR_Denoising( par );
            PSNR = [PSNR PSNRi];
            SSIM = [SSIM SSIMi];
            imname = sprintf('C:/Users/csjunxu/Desktop/NIPS2017/W3Results/GSPIN/WESNR/WESNR_nSig%d_sp%2.2f_%s', nSig, sp, im_dir(i).name);
            imwrite(im_out/255, imname);
            disp( sprintf('The denoised result of %s: PSNR = %12.8f  SSIM = %12.8f\n', im_dir(i).name, PSNRi, SSIMi) );
        end
        mPSNR=mean(PSNR);
        mSSIM=mean(SSIM);
        name = sprintf(['results/WESNR_AGIN_nSig' num2str(nSig) '_sp' num2str(sp) '.mat']);
        save(name,'nSig','sp','PSNR','SSIM','mPSNR','mSSIM');
    end
end
