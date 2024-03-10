%% Train BPnet according to samples extract from each window
%% Inputs:
% - LUT: Training Samples [biome, NDVI, FPAR, center_lat, center_lon]
% - isEBF: yes-1/2/3; no-0;
% - hiddenLayerSize: hyper-parameter(1)
% - netpath: savepath for bpnet

function trainbpnet(LUT, isEBF, hiddenLayerSize, netpath)


%% preprocess
if isEBF==1 

        X = LUT(:,[2,4,5]);
        Y = LUT(:,3);
        [row,col] = getRowCol([-90,90],[-180,180],1/12,LUT(:,4),LUT(:,5));
        [m,n] = find(col<1800);
        X = X(m,:);
        Y = Y(m,:);
        [xtrain,ps_input] = mapminmax(X',0,1);
        [ytrain,ps_output] = mapminmax(Y',0,1);


elseif isEBF==2

        X = LUT(:,[2,4,5]);
        Y = LUT(:,3);
        [row,col] = getRowCol([-90,90],[-180,180],1/12,LUT(:,4),LUT(:,5));
        [m,n] = find(col>=1800&col<2900);
        X = X(m,:);
        Y = Y(m,:);
        [xtrain,ps_input] = mapminmax(X',0,1);
        [ytrain,ps_output] = mapminmax(Y',0,1);

elseif isEBF==3

        X = LUT(:,[2,4,5]);
        Y = LUT(:,3);
        [row,col] = getRowCol([-90,90],[-180,180],1/12,LUT(:,4),LUT(:,5));
        [m,n] = find(col>=2900);
        X = X(m,:);
        Y = Y(m,:);
        [xtrain,ps_input] = mapminmax(X',0,1);
        [ytrain,ps_output] = mapminmax(Y',0,1);

else

        X = LUT(:,[2,4,5]);
        Y = LUT(:,3);
        [input,ps_input] = mapminmax(X',0,1);
        [ytrain,ps_output] = mapminmax(Y',0,1);
        biome = dummyvar(LUT(:,1)); 
        xtrain = [input;biome'];

end

%% parameters setting
net = feedforwardnet(hiddenLayerSize,'trainlm');
net.trainParam.lr = 0.005;
net.trainParam.epochs = 1000;
net.trainParam.goal = 1e-3;
net.trainParam.max_fail = 10;
net.trainParam.showWindow = 0;
net.layers{2}.transferFcn = 'tansig';

%% train bpnet (10-fold CV)
dataset = cvpartition(size(xtrain,2),'KFold',10);
Ysim=[];
Yobs=[];
Xtest = [];
bpnet=cell(10,1);
for i = 1:dataset.NumTestSets

        trind = dataset.training(i);
        teind = dataset.test(i);

        net = init(net);
        [net,~] = train(net,xtrain(:,trind),ytrain(1,trind));
        pred = net(xtrain(:,teind));
        bpnet{i} = net;
        % 需要将预测值反标准化再计算RMSE
        ysim = mapminmax('reverse',pred,ps_output);
        yobs = mapminmax('reverse',ytrain(1,teind),ps_output);
        Ysim = [Ysim;ysim'];
        Yobs = [Yobs;yobs'];
        Xtest = [Xtest;xtrain(:,teind)'];
        clear yobs ysim pred
end

%% save bpnet
save(netpath,'bpnet','Xtest','Yobs','Ysim','ps_input','ps_output');


end