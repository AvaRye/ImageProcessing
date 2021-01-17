function [] = myhisteq(name)
    H= imread(name);
    if length(size(H))>2
        H=rgb2gray(H);
    end
    subplot(3,2,1);
    imshow(H); title('原图');
    subplot(3,2,2);
    imhist(H); title('原图直方图');
    subplot(3,2,3);
    H1=adapthisteq(H);
    imshow(H1); title('adapthisteq均衡图');
    subplot(3,2,4);
    imhist(H1);title('adapthisteq均衡直方图');
    subplot(3,2,5);
    H2=histeq(H);
    imshow(H2); title('histeq均衡图');
    subplot(3,2,6);
    imhist(H1); title('histeq均衡直方图');
    
end