function [] = myhough(name)
I  = imread(name);
if length(size(I))>2
    I=rgb2gray(I);
end
% 创建二值图像
binary = edge(I,'canny');
% 使用二值图像创建Hough变换
[H,T,R] = hough1(binary);
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

function [h, theta, rho] = hough1(varargin)
[bw, rho, theta] = parseInputs(varargin{:});
h = builtin("_houghmex", bw,rho,theta*pi/180);
end
function [bw, rho, theta] = parseInputs(varargin)
narginchk(1,5);
bw = varargin{1};
validateattributes(bw, {'numeric','logical'},{'real', '2d', 'nonsparse', 'nonempty'},mfilename, 'BW', 1);
if ~islogical(bw)
    bw = bw~=0;
end
thetaResolution = 1;
rhoResolution = 1;
theta = [];
validStrings = {'RhoResolution', 'Theta', 'ThetaResolution'};
if nargin > 1
    idx = 2;
    while idx <= nargin
        input = varargin{idx};
        inputStr = validatestring(input, validStrings, mfilename, 'PARAM', idx);
        idx = idx+1;
        switch inputStr
            case 'RhoResolution'
                rhoResolution = varargin{idx};
            case 'Theta'
                theta = varargin{idx};
            case 'ThetaResolution'
                thetaResolution = varargin{idx};
        end
        idx=idx+1;
    end
end
% Compute theta and rho
[M,N] = size(bw);
if (isempty(theta))
    theta = linspace(-90, 0, ceil(90/thetaResolution) + 1);
    theta = [theta -fliplr(theta(2:end - 1))];
end
D = sqrt((M - 1)^2 + (N - 1)^2);
q = ceil(D/rhoResolution);
nrho = 2*q + 1;
rho = linspace(-q*rhoResolution, q*rhoResolution, nrho);
end



