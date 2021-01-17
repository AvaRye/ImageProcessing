function [] = myhough(name)
    I  = imread(name);
    if length(size(I))>2
        I=rgb2gray(I);
    end
    % 创建二值图像
    binary = edge(I,'canny');
    % 使用二值图像创建Hough变换
    [H,T,R] = hough(binary);
    % 峰值
    P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
    lines = houghlines(binary,T,R,P,'FillGap',5,'MinLength',7);
    figure; imshow(I); hold on
    for i = 1:length(lines)
        xy = [lines(i).point1; lines(i).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan');
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','green');
    end
    title('直线检测');
end