function [result] = sketch( name, max_level )
    I = imread(name);
    scope = 255 / (255-max_level);
    b = -scope * max_level;
    [m, n, c] = size(I);

    if c > 1
        img_gray(:,:,1) = rgb2gray(I);
        img_gray(:,:,2) = rgb2gray(I);
        img_gray(:,:,3) = rgb2gray(I);
    else
        img_gray(:,:,1) = I;
        img_gray(:,:,2) = I;
        img_gray(:,:,3) = I;
    end
    subplot(1,2,1);
    imshow(I); title('origin');
    
    % 简单调整曲线
    for i=1:m
        for j=1:n
            if img_gray(i, j, 1) <= max_level
                img_gray(i, j, :) = zeros(1,1,3);
            else
                img_gray(i, j, :) = scope * img_gray(i, j, :) + b;
            end
        end
    end
    
    % 复制一个反向图层
    img_gray2 = zeros(m, n, 3);
    for i=1:m
        for j=1:n
            img_gray2(i, j, 1) = 255 - img_gray(i, j, 1);
            img_gray2(i, j, 2) = 255 - img_gray(i, j, 2);
            img_gray2(i, j, 3) = 255 - img_gray(i, j, 3);
        end
    end
    
    % 最小值滤波器
    radius = 1;
    img_gray2 = min_filter(img_gray2, radius);
    
    % 图层叠加
    img_mix = color_dodge(img_gray2, img_gray);
    result = uint8(img_mix);
    subplot(1,2,2);
    imshow(result);title('result');
end

% 最小值滤波器
function res = min_filter(img, radius)
    [m, n, c] = size(img);
    filter_width = 1 + 2 * radius;
    if c == 1
        res = zeros(m, n);
        for i=1:m-2*radius
            for j=1:n-2*radius
                c_min = min(min(img(i:i+2*radius, j:j+2*radius)));
                res(i:i+2*radius, j:j+2*radius) = ones(filter_width, filter_width) * double(c_min);
            end
        end
    else
        res = zeros(m, n, c);
        for i=1:m-2*radius
            for j=1:n-2*radius
                for k=1:c
                    c_min = min(min(img(i:i+2*radius, j:j+2*radius, k)));
                    res(i:i+2*radius, j:j+2*radius, k) = ones(filter_width, filter_width) * double(c_min);
                end
            end
        end
    end
end

% 颜色减淡的混合叠加
function res = color_dodge(layer1, layer2)
    [m, n, c] = size(layer2);
    if c == 1
        res = zeros(m, n);
        for i=1:m
            for j=1:n
                if layer2(i, j) == 255
                    res(i, j) = 255;
                else
                    res(i, j) = min(255, (layer1(i, j)*256 / (255 - layer2(i, j))));
                end
            end
        end
    else
        res = zeros(m, n, c);
        for i=1:m
            for j=1:n
                for k=1:c
                    if layer2(i, j, k) == 255
                        res(i, j, k) = 255;
                    else
                        res(i, j, k) = min(255, (layer1(i, j, k)*256 / (255 - layer2(i, j, k))));
                    end
                end
            end
        end
    end
end