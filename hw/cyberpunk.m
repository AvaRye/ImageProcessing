function [] = cyberpunk()
    
    I = imread('lena_std.tif');
    figure; imshow(I);
    
    hsv = rgb2hsv(I);
    H = hsv(:,:,1); % 色调
    S = hsv(:,:,2); % 饱和度
    V = hsv(:,:,3); % 亮度
    
    %直方图均衡化
    S = histeq(S);
    hsv1(:,:,1) = H;
    hsv1(:,:,2) = S;
    hsv1(:,:,3) = V;
   
    %转为RGB，进行显示
    rgb = hsv2rgb(hsv1); 
    figure; imshow(rgb);
    
    cmy = imcomplement(rgb);
    C = cmy(:,:,1);
    M = cmy(:,:,2);
    Y = cmy(:,:,3);
    cmy1(:,:,1) = 1.1*C;
    cmy1(:,:,2) = 1.1*M;
    cmy1(:,:,3) = Y;
    figure;
    cmy1 = imcomplement(cmy1);
    imshow(cmy1);
    
    
end

