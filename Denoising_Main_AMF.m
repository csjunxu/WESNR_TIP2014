clear;

Original_image_dir  =    'C:\Users\csjunxu\Desktop\TWSCGIN\cleanimages\';
Sdir = regexp(Original_image_dir, '\', 'split');
fpath = fullfile(Original_image_dir, '*.png');
im_dir  = dir(fpath);
im_num = length(im_dir);
method = 'WESNR';
write_MAT_dir = ['C:/Users/csjunxu/Desktop/TWSCGIN/'];
write_sRGB_dir = [write_MAT_dir method];
if ~isdir(write_sRGB_dir)
    mkdir(write_sRGB_dir)
end

load Lib\PCA_AR_TD2_c2
for nSig                      =   [10 20 30]         % The standard variance of the additive Gaussian noise;
    for sp                        =   [.1 .3 .5]        % salt and pepper
        par.PCA_D                 =   PCA_D;
        par.Codeword              =   centroids;
        par.nSig             =   nSig;
       
        imPSNR = [];
        imSSIM = [];
        Type = 0;
        for i = 1:im_num
            par.I                =   double( imread(fullfile(Original_image_dir, im_dir(i).name)) );
            S = regexp(im_dir(i).name, '\.', 'split');
            %                                 %% add Gaussian noise
            %                                 randn('seed',0);
            %                                 par.nim =   par.I + nSig*randn(size(par.I));
            %                                 %% add "salt and pepper" noise
            %                                 rand('seed', 0)
            %                                 par.nim = imnoise(par.nim, 'salt & pepper', sp); %"salt and pepper" noise
            %                                 par.nim = par.nim*255;
            %                                 %% add "salt and pepper" noise 0 or RVIN noise 1
            %                                 randn('seed',0);
            %                                 [par.nim,Narr]          =   impulsenoise(par.nim,sp,Type);
            if Type == 0
                imname = sprintf([write_MAT_dir 'noisyimages/G' num2str(nSig) '_SPIN' num2str(sp) '_' im_dir(i).name]);
                %                                     imwrite(Par.nim/255,imname);
                par.nim = double( imread(imname));
            elseif Type == 1
                imname = sprintf([write_MAT_dir 'noisyimages/G' num2str(nSig) '_RVIN' num2str(sp) '_' im_dir(i).name]);
                %                                     imwrite(Par.nim/255,imname);
                par.nim = double( imread(imname));
            else
                break;
            end
            % Adaptive Median filter”√”⁄’“œ‡À∆øÈ∫Õ—µ¡∑◊÷µ‰
            [par.pim,ind] = adpmedft(par.nim,19);
            ind=(par.pim~=par.nim)&((par.nim==255)|(par.nim==0));
            par.pim(~ind)=par.nim(~ind);
            [im_out,PSNR,SSIM]      =   WESNR_Denoising( par );
            %% output
            imPSNR = [imPSNR PSNR];
            imSSIM  = [imSSIM SSIM];
            imname = sprintf([write_sRGB_dir '/' method '_AMF1_GSPIN_nSig' num2str(nSig) '_sp' num2str(sp) im_dir(i).name]);
            fprintf('%s : PSNR = %2.2f, SSIM = %2.4f \n',im_dir(i).name,PSNR,SSIM);
        end
        %% save output
        SmPSNR = mean(imPSNR);
        SmSSIM = mean(imSSIM);
        result = sprintf('WESNR_AMF1_GauSPIN_%d_%2.2f.mat',nSig,sp);
        save(result,'imPSNR','imSSIM','SmPSNR','SmSSIM');
    end
end