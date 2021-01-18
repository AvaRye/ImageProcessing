function [] = myhisteq()
H= imread('girl.jpeg');
if length(size(H))>2
    H=rgb2gray(H);
end
subplot(3,2,1);
imshow(H); title('原图');
subplot(3,2,2);
imhist(H); title('原图直方图');
subplot(3,2,3);
H1=histeq1(H);
imshow(H1); title('自实现histeq均衡');
subplot(3,2,4);
imhist(H1); title('自实现histeq均衡直方图');
subplot(3,2,5);
H2=adapthisteq(H);
imshow(H2);  title('adapthisteq均衡');
subplot(3,2,6);
imhist(H1);title('adapthisteq均衡直方图');
end


function I = histeq1(a)
I=a;
[R, C] = size(I);
cnt = zeros(1, 256);
for i = 1 : R
    for j = 1 : C
        cnt(1, I(i, j) + 1) = cnt(1, I(i, j) + 1) + 1;
    end
end
f = zeros(1, 256);
f = double(f); cnt = double(cnt);
% 统计每个像素值出现的概率， 得到概率直方图
for i = 1 : 256
    f(1, i) = cnt(1, i) / (R * C);
end
% 求累计概率，得到累计直方图
for i = 2 : 256
    f(1, i) = f(1, i - 1) + f(1, i);
end
% 用f数组实现像素值[0, 255]的映射。 
for i = 1 : 256
    f(1, i) = f(1, i) * 255;
end
% 完成每个像素点的映射
I = double(I);
for i = 1 : R
    for j = 1 : C
        I(i, j) = f(1, I(i, j) + 1);
    end
end
I = uint8(I);
end