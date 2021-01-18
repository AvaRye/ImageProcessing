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
    imshow(bilinear(I, n));
    axis on
    title('自实现双线性插值');
    
    subplot(2,2,4);
    imshow(imresize(I, n, 'bicubic'));
    axis on
    title('双三次插值');
end


function H = bilinear(I,n)
img = I;
[row,col,color] = size(img);
row = round(row*n);
col = round(col*n);
H = zeros(row,col,color,class(img));
for i = 1:row
    for j = 1:col
        for I = 1:color
            x = round(i/n);
            y = round(j/n);
            if x == 0
                x = x+1;
            end
            if y ==0
                y = y+1;
            end
            u = i/n-floor(i/n); %求取水平方向上的权重
            v = j/n-floor(j/n); %求取垂直方向上的权重
            % 对图像右下边用最近邻插值
            if i >= row-n || j >= col-n
                H(i,j,I) = img(x,y,I);
            else
                H(i,j,I) = u*v*img(x,y,I)+(1-u)*v*img(x+1,y,I)+u*(1-v)*img(x,y+1,I)+(1-u)*(1-v)*img(x+1,y+1,I);
            end
        end
    end
end
end

