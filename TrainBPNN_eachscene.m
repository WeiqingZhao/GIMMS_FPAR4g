%% Train BPNN model for each half-month
%% file folder
comp_dir = 'J:\FPAR4g\Trial\V3\data\CompositeImages\CompositeImages_';
net_dir = 'J:\FPAR4g\Trial\V3\data\bpnet\mat\bpnet_';
fig_dir = 'J:\FPAR4g\Trial\V3\data\bpnet\figures\fig_';

%% auxiliary data
path = 'MajorBiomeType.mat';
pft = loadMatData(path);
pft(pft<1|pft>8) = nan;

%% parameters
xdataRange = [0.05,1];
ydataRange = [0.01,1];
validPercent = 0.1;
classes = 1:8;

%% EBF
% data preparation
pct=[10,50,90];
winsz = 11;
for halfmon = 1:24

        path = strcat(comp_dir,num2str(halfmon),'.mat');
        fpar_img = importdata(path).comp_FPAR;
        ndvi_img = importdata(path).comp_NDVI;

        LUT = [];
        for i = 1:size(fpar_img,3)
                
                f_img = fpar_img(:,:,i);
                n_img = ndvi_img(:,:,i);
                temp = f_img+n_img;
                f_img(isnan(temp)|pft~=5) = nan;
                n_img(isnan(temp)|pft~=5) = nan;
                lut = GetTrainingSamples(n_img,f_img,pft,winsz,winsz,xdataRange,ydataRange,validPercent,classes,pct);
                LUT = [LUT;lut];
                clear f_img n_img temp

        end
       
        outname = strcat('J:\FPAR4g\Trial\V3\data\bpnet\TrainingSamples\LUT_EBF_',num2str(halfmon),'_',num2str(winsz),'.mat');
        save(outname,'LUT');
        clear LUT fpar_img ndvi_img
        
end

% train bpnet and evaluate test set accuracy for each half-month
for halfmon = 1:24

    outname = strcat('J:\FPAR4g\Trial\V3\data\bpnet\TrainingSamples\LUT_EBF_',num2str(halfmon),'_',num2str(winsz),'.mat'); 
    LUT = loadMatData(outname);

    
    netpath = strcat(net_dir,'EBF1_',num2str(halfmon),'.mat');
    trainbpnet(LUT,1,[20,20], netpath);

    
    netpath = strcat(net_dir,'EBF2_',num2str(halfmon),'.mat');
    trainbpnet(LUT,2,[20,20], netpath);

    
    netpath = strcat(net_dir,'EBF3_',num2str(halfmon),'.mat');
    trainbpnet(LUT,3,[20,20], netpath);

    clear LUT outname netpath

end

%% Other biomes
% data preparation
winsz = 25;
pct = 50;
biomes = [1,2,3,4,6,7,8];

for halfmon = 1:24

        path = strcat(comp_dir,num2str(halfmon),'.mat');
        fpar_img = importdata(path).comp_FPAR;
        ndvi_img = importdata(path).comp_NDVI;

        LUT = [];
        for i = 1:size(fpar_img,3)
                
                f_img = fpar_img(:,:,i);
                n_img = ndvi_img(:,:,i);
                temp = f_img+n_img;
                f_img(isnan(temp)|pft==5) = nan;
                n_img(isnan(temp)|pft==5) = nan;
                lut = GetTrainingSamples(n_img,f_img,pft,winsz,winsz,xdataRange,ydataRange,validPercent,classes,pct);
                LUT = [LUT;lut];
                clear f_img n_img temp

        end

        % save traning samples
        outname = strcat('J:\FPAR4g\Trial\V3\data\bpnet\TrainingSamples\LUT_Others','_',num2str(halfmon),'_',num2str(winsz),'.mat');
        save(outname,'LUT');
        clear LUT fpar_img ndvi_img

end

% train bpnet and evaluate test set accuracy for each half-month
for halfmon = 1:24

    outname = strcat('J:\FPAR4g\Trial\V3\data\bpnet\TrainingSamples\LUT_Others','_',num2str(halfmon),'_',num2str(winsz),'.mat');
    LUT = loadMatData(outname);

    netpath = strcat(net_dir,'Others_',num2str(halfmon),'.mat');
    trainbpnet(LUT,0,[20,20], netpath);

    clear LUT outname netpath

end