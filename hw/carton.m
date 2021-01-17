function carton_img = carton(name)
    %     I  = imread(name);
    I = name;
    fi_img = imbilatfilt(I,100,20); %双边滤波
    ed_img = 1-edge((rgb2gray(I)),'canny',0.2); %边缘提取
    carton_img = fi_img.*(uint8(repmat(ed_img,[1,1,3]))); %合并
%     imshow(carton_img)
end