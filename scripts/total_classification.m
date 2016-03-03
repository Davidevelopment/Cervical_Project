% Train classificator and output result
%
% Input files have to be a structure with:
% - img: an image
% - test: parameters for the classification for each pixels
% - train_pos: parameters for the classification for cancerous pixels
% - train_neg: parameters for the classification for non-cancerous pixels
% ________________
% Directory containing the data:
dir_name = 'classification-color';
% File in 'dir_name' to be used for testing:
test_file = 'HUG23.mat';
% ________________




%% Load
load(strcat(dir_name,'/',test_file));
Testing = test;
Image = img;

Training_pos = [];
Training_neg = [];
files = dir(fullfile(dir_name, '*.mat'));
for i=1:length(files)
    fname = files(i).name;
    if (~strcmp(fname, test_file))
        load(strcat(dir_name,'/',fname));
        Training_pos = [Training_pos; train_pos];
        Training_neg = [Training_neg; train_neg];
    end
end
Training = [Training_pos; Training_neg];
Group = [ones(size(Training_pos,1),1); zeros(size(Training_neg,1),1)];


%% Normalize
mean_r = mean(Training(:,1));
std_r = std(Training(:,1));
mean_t = mean(Training(~isinf(Training(:,2)),2));
std_t = std(Training(~isinf(Training(:,2)),2));
mean_f = mean(Training(:,3));
std_f = std(Training(:,3));

Training(:,1) = (Training(:,1) - mean_r) ./ std_r;
Training(:,2) = (Training(:,2) - mean_t) ./ std_t;
Training(:,3) = (Training(:,3) - mean_f) ./ std_f;

Testing(:,1) = (Testing(:,1) - mean_r) ./ std_r;
Testing(:,2) = (Testing(:,2) - mean_t) ./ std_t;
Testing(:,3) = (Testing(:,3) - mean_f) ./ std_f; 



%% K-nn classification
%Class = knnclassify(Testing, Training, Group, 5);

%% SVM classification
SVMModel = fitcsvm(Training, Group, 'KernelFunction', 'rbf', 'IterationLimit', 1000, 'ClassNames', [0,1]);
[Class, ~] = predict(SVMModel, Testing);


%% Post processing

% Disregard pixels outside the area defined in choose_pixels.m
binary_image = Image(:,:,1);
binary_image(Class==1) = 255;
binary_image(Class==0) = 0;

% % Disregard high MSE pixels
% MSE_mask = MSE_mat>mean(MSE_mat(:))+2*std(MSE_mat(:));

% % Combine both mask
% binary_image = binary_image&~MSE_mask;


% Opening
se = strel('disk',2);
binary_image_open = imopen (binary_image,se);


% Show the boundaries on the image
[B,~,N,~] = bwboundaries(binary_image_open);

[Mim, Nim, ~] = size(Image);
boundaries = 0;
for i =1:N
    boundaries = boundaries + bound2im(B{i},Mim, Nim, min(B{i}(:,1)), min(B{i}(:,2)));
end

im_boundaries = Image;
im_r = im_boundaries(:,:,1);
im_g = im_boundaries(:,:,2);
im_b = im_boundaries(:,:,3);
im_r(Class==1) = 0;
im_g(Class==1) = 0;
%im_b(Class==1) = 0;
im_boundaries(:,:,1) = im_r;
im_boundaries(:,:,2) = im_g;
im_boundaries(:,:,3) = im_b;
im_boundaries(boundaries==1) = 0;
%im_boundaries(Class==1) = 0;


%% Visualization
% Data
figure;
scatter3(Testing(Class==1,1), Testing(Class==1,2), Testing(Class==1,3), 'r');
hold on;
scatter3(Testing(Class==0,1), Testing(Class==0,2), Testing(Class==0,3), 'k');
xlabel('raising'), ylabel('exponential slope'), zlabel('linear slope')
title('k-nn');

% Segmentation
figure;
imshow(im_boundaries);
