function [] = myresize(name, n)
    
    I = imread(name);
    subplot(2,2,1);
    imshow(I);
    axis on
    title('原图');
    
    subplot(2,2,2);
    imshow(imresize(I, n, 'nearest'));
    axis on
    title('最近邻插值');
    
    subplot(2,2,3);
    imshow(imresize(I, n, 'bilinear'));
    axis on
    title('双线性插值');
    
    subplot(2,2,4);
    imshow(imresize(I, n, 'bicubic'));
    axis on
    title('双三次插值');
end
