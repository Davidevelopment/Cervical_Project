% classification.m
% Execute a 3D K-NN


%% Normalize the data
% Hard thresholds
max_r = 40;
min_r = -40;
mean_r = mean2(end_start_lin);
std_r = std2(end_start_lin);
max_t = 5;
min_t = 0;
mean_t = mean2(tau);
std_t = std2(tau);
max_e = 100;
min_e = 0;
mean_e = mean2(end_values_lin);
std_e = std2(end_values_lin);

% normalize
% end_start_lin_norm = (end_start_lin - min_r) ./ (max_r - min_r);
% tau_norm = (tau - min_t) ./ (max_t - min_t);
% end_values_lin_norm = (end_values_lin - min_e) ./ (max_e - min_e);

end_start_lin_norm = (end_start_lin - mean_r) ./ std_r;
tau_norm = (tau - mean_t) ./ std_t;
end_values_lin_norm = (end_values_lin - mean_e) ./ std_e;

%bound the result to 0 and 1
% end_start_lin_norm(end_start_lin_norm > 1) = 1;
% end_start_lin_norm(end_start_lin_norm < 0) = 0;
% tau_norm(tau_norm>1) = 1;
% end_values_lin_norm(end_values_lin_norm > 1) = 1;
% end_values_lin_norm(end_values_lin_norm < 0) = 0;




%% Create the training data

figure;
BW = roipoly(Frames{end});
% Choose the polygon then Righ-Click -> Create Mask

% I_rgb = videoObj_opt.frames(end).cdata;
I_rgb = Frames{end};

% 50 CIN1 pixels and 50 others pixels (from choose_pixels.m)
% load data
load('TrNormalized.mat');


% Create the training data
% Index = [CIN_x CIN_y; OTHER_x OTHER_y];
% Index = round(Index);
% 
% Training = [];
% for ii = 1: size(Index,1)
%     % we need to swap x and y
%     Training = [Training; double(end_start_lin_norm(Index(ii,2),Index(ii,1))) ...
%         double(tau_norm(Index(ii,2),Index(ii,1))) ...
%         double(end_values_lin_norm(Index(ii,2),Index(ii,1))) ];
% end
% 
% Group = [ones(size(CIN_x,1),1);ones(size(OTHER_x,1),1)+1];

sizeGroup1 = size(CIN1,1) + size(CIN1_2,1) + size(CIN2,1) + size(CIN2_3,1) + size(CIN3,1);
sizeGroup2 = size(OTHER, 1);
Training = [CIN1; CIN1_2; CIN2; CIN2_3; CIN3; OTHER];
Group = [ones(sizeGroup1,1); ones(sizeGroup2,1)+1];

list = BW(:);
X = end_start_lin_norm(list);
Y = tau_norm(list);
Z = end_values_lin_norm(list);
Sample = [X Y Z];



%% K-nn algorithm
Class = knnclassify(Sample, Training, Group, 5);



%% Post processing

% Disregard pixels outside the area defined in choose_pixels.m
binary_mask = I_rgb(list);
binary_mask(Class==1) = 255;
binary_mask(Class==2) = 0;

binary_image = zeros(size(I_rgb(:,:,1)));
binary_image(list) = binary_mask;

% Disregard high MSE pixels
MSE_mask = MSE_mat>mean(MSE_mat(:))+2*std(MSE_mat(:));

% Combine both mask
binary_image = binary_image&~MSE_mask;


% Opening
se = strel('disk',2);
binary_image_open = imopen (binary_image,se);


% Show the boundaries on the image
[B,~,N,~] = bwboundaries(binary_image_open);

[Mim, Nim, ~] = size(I_rgb);
boundaries = 0;
for i =1:N
    boundaries = boundaries + bound2im(B{i},Mim, Nim, min(B{i}(:,1)), min(B{i}(:,2)));
end

im_boundaries = I_rgb;
im_boundaries(boundaries==1) = 0;


%% Visualization

% Segmentation
figure;
imshow(im_boundaries);
title('3D k-nn (k=5)');

% Data
figure; scatter3(X(Class==1), Y(Class==1), Z(Class==1));
hold on; scatter3(X(Class==2), Y(Class==2), Z(Class==2));
xlabel('raising'), ylabel('time constant'), zlabel('end value')
title('k-nn');




