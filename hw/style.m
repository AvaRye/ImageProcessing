%% 加载数据
styleImage = im2double(imread('102.jpg'));
contentImage = imread('connor.jpg');

%% 加载特征提取网络 - VGG19
net = vgg19;
lastFeatureLayerIdx = 38;
layers = net.Layers;
layers = layers(1:lastFeatureLayerIdx);
for l = 1:lastFeatureLayerIdx
    layer = layers(l);
    if isa(layer,'nnet.cnn.layer.MaxPooling2DLayer')
        layers(l) = averagePooling2dLayer(layer.PoolSize,'Stride',layer.Stride,'Name',layer.Name);
    end
end
lgraph = layerGraph(layers);
dlnet = dlnetwork(lgraph);

%% 预处理数据
imageSize = [384,512];
styleImg = imresize(styleImage,imageSize);
contentImg = imresize(contentImage,imageSize);
imgInputLayer = lgraph.Layers(1);
meanVggNet = imgInputLayer.Mean(1,1,:);
styleImg = rescale(single(styleImg),0,255) - meanVggNet;
contentImg = rescale(single(contentImg),0,255) - meanVggNet;

%% 白噪声初始化图像
noiseRatio = 0.7;
randImage = randi([-20,20],[imageSize 3]);
transferImage = noiseRatio.*randImage + (1-noiseRatio).*contentImg;
%% 损失函数、样式传递参数
styleTransferOptions.contentFeatureLayerNames = {'conv4_2'};
styleTransferOptions.contentFeatureLayerWeights = 1;
styleTransferOptions.styleFeatureLayerNames = {'conv1_1','conv2_1','conv3_1','conv4_1','conv5_1'};
styleTransferOptions.styleFeatureLayerWeights = [0.5,1.0,1.5,3.0,4.0];
styleTransferOptions.alpha = 1;
styleTransferOptions.beta = 1e3;

%% 设定训练数值
numIterations = 1500;
learningRate = 2;
trailingAvg = [];
trailingAvgSq = [];

%% 训练
dlStyle = dlarray(styleImg,'SSC');
dlContent = dlarray(contentImg,'SSC');
dlTransfer = dlarray(transferImage,'SSC');
if canUseGPU %我的mac是不行了，后悔
    dlContent = gpuArray(dlContent);
    dlStyle = gpuArray(dlStyle);
    dlTransfer = gpuArray(dlTransfer);
end
numContentFeatureLayers = numel(styleTransferOptions.contentFeatureLayerNames);
contentFeatures = cell(1,numContentFeatureLayers);
[contentFeatures{:}] = forward(dlnet,dlContent,'Outputs',styleTransferOptions.contentFeatureLayerNames);
numStyleFeatureLayers = numel(styleTransferOptions.styleFeatureLayerNames);
styleFeatures = cell(1,numStyleFeatureLayers);
[styleFeatures{:}] = forward(dlnet,dlStyle,'Outputs',styleTransferOptions.styleFeatureLayerNames);

%% 迭代以及画出迭代后结果
figure
minimumLoss = inf;
for iteration = 1:numIterations
    [grad,losses] = dlfeval(@imageGradients,dlnet,dlTransfer,contentFeatures,styleFeatures,styleTransferOptions);
    [dlTransfer,trailingAvg,trailingAvgSq] = adamupdate(dlTransfer,grad,trailingAvg,trailingAvgSq,iteration,learningRate);
    if losses.totalLoss < minimumLoss
        minimumLoss = losses.totalLoss;
        dlOutput = dlTransfer;
    end
    
    % 第一次和每50次迭代展示一次 
    if mod(iteration,50) == 0 || (iteration == 1)
        transferImage = gather(extractdata(dlTransfer));
        transferImage = transferImage + meanVggNet;
        transferImage = uint8(transferImage);
        transferImage = imresize(transferImage,size(contentImage,[1 2]));
        image(transferImage)
        title(['Transfer Image After Iteration ',num2str(iteration)])
        axis off image
        drawnow
    end   
end

%% 结果对比
transferImage = gather(extractdata(dlOutput));
transferImage = transferImage + meanVggNet;
transferImage = uint8(transferImage);
transferImage = imresize(transferImage, size(contentImage,[1 2]));
imshow(imtile({contentImage,transferImage,styleImage}, ...
    'GridSize',[1 3],'BackgroundColor','w'));

%% 相关函数
function [gradients,losses] = imageGradients(dlnet,dlTransfer,contentFeatures,styleFeatures,params)
 
    % Initialize transfer image feature containers. 
    numContentFeatureLayers = numel(params.contentFeatureLayerNames);
    numStyleFeatureLayers = numel(params.styleFeatureLayerNames);
 
    transferContentFeatures = cell(1,numContentFeatureLayers);
    transferStyleFeatures = cell(1,numStyleFeatureLayers);
 
    % Extract content features of transfer image.
    [transferContentFeatures{:}] = forward(dlnet,dlTransfer,'Outputs',params.contentFeatureLayerNames);
     
    % Extract style features of transfer image.
    [transferStyleFeatures{:}] = forward(dlnet,dlTransfer,'Outputs',params.styleFeatureLayerNames);
 
    % Compute content loss. 
    cLoss = contentLoss(transferContentFeatures,contentFeatures,params.contentFeatureLayerWeights);
 
    % Compute style loss. 
    sLoss = styleLoss(transferStyleFeatures,styleFeatures,params.styleFeatureLayerWeights);
 
    % Compute final loss as weighted combination of content and style loss. 
    loss = (params.alpha * cLoss) + (params.beta * sLoss);
 
    % Calculate gradient with respect to transfer image.
    gradients = dlgradient(loss,dlTransfer);
    
    % Extract various losses. 
    losses.totalLoss = gather(extractdata(loss));
    losses.contentLoss = gather(extractdata(cLoss));
    losses.styleLoss = gather(extractdata(sLoss));
 
end

function loss = contentLoss(transferContentFeatures,contentFeatures,contentWeights)

    loss = 0;
    for i=1:numel(contentFeatures)
        temp = 0.5 .* mean((transferContentFeatures{1,i} - contentFeatures{1,i}).^2,'all');
        loss = loss + (contentWeights(i)*temp);
    end
end

function loss = styleLoss(transferStyleFeatures,styleFeatures,styleWeights)

    loss = 0;
    for i=1:numel(styleFeatures)
        
        tsf = transferStyleFeatures{1,i};
        sf = styleFeatures{1,i};    
        [h,w,c] = size(sf);
        
        gramStyle = computeGramMatrix(sf);
        gramTransfer = computeGramMatrix(tsf);
        sLoss = mean((gramTransfer - gramStyle).^2,'all') / ((h*w*c)^2);
        
        loss = loss + (styleWeights(i)*sLoss);
    end
end

function gramMatrix = computeGramMatrix(featureMap)
    [H,W,C] = size(featureMap);
    reshapedFeatures = reshape(featureMap,H*W,C);
    gramMatrix = reshapedFeatures' * reshapedFeatures;
end