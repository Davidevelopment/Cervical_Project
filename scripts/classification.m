% classification.m
% Determine cancerous regions. Training is done on the same images as for
% testing.

useSVM = true;


%% Normalize the data
if ~useSVM
    mean_r = mean2(end_start_lin);
    std_r = std2(end_start_lin);
    mean_t = mean2(tau(~isinf(tau)));
    std_t = std2(tau(~isinf(tau)));
    mean_f = mean2(final_slope);
    std_f = std2(final_slope);

    end_start_lin_norm = (end_start_lin - mean_r) ./ std_r;
    tau_norm = (tau - mean_t) ./ std_t;
    final_slope_norm = (final_slope - mean_f) ./ std_f;
else
    end_start_lin_norm = end_start_lin;
    tau_norm = tau;
    final_slope_norm = final_slope;
end


%% Create the training data
I_rgb = Frames{end};

% 50 CIN1 pixels and 50 others pixels (from choose_pixels.m)
load data


% Remove points outside of the image
CIN_y((CIN_x > size(end_start_lin,2)) | (CIN_x < 1)) = [];
CIN_x((CIN_x > size(end_start_lin,2)) | (CIN_x < 1)) = [];
CIN_x((CIN_y > size(end_start_lin,1)) | (CIN_y < 1)) = [];
CIN_y((CIN_y > size(end_start_lin,1)) | (CIN_y < 1)) = [];
OTHER_y((OTHER_x > size(end_start_lin,2)) | (OTHER_x < 1)) = [];
OTHER_x((OTHER_x > size(end_start_lin,2)) | (OTHER_x < 1)) = [];
OTHER_x((OTHER_y > size(end_start_lin,1)) | (OTHER_y < 1)) = [];
OTHER_y((OTHER_y > size(end_start_lin,1)) | (OTHER_y < 1)) = [];

% Create the training data
Index = [CIN_x CIN_y; OTHER_x OTHER_y];
Index = round(Index);

Training = [];
for ii = 1: size(Index,1)
        % we need to swap x and y
        Training = [Training; double(end_start_lin_norm(Index(ii,2),Index(ii,1))) ...
            double(tau_norm(Index(ii,2),Index(ii,1))) ...
            double(final_slope_norm(Index(ii,2),Index(ii,1))) ];
end

Group = [ones(size(CIN_x,1),1);ones(size(OTHER_x,1),1)+1];


X = end_start_lin_norm(:);
Y = tau_norm(:);
Z = final_slope_norm(:);
Sample = [X Y Z];



%% Classification

if useSVM
    % SVM classification:
    SVMModel = fitcsvm(Training, Group, 'KernelFunction', 'rbf', 'IterationLimit', 1000, 'Standardize', true, 'ClassNames', [1,2]);
    [Class, ~] = predict(SVMModel, Sample);
else
    %K-nn algorithm:
    Class = knnclassify(Sample, Training, Group, 5);
end


%% Post processing

% Disregard pixels outside the area defined in choose_pixels.m
binary_image = I_rgb(:,:,1);
binary_image(Class==1) = 255;
binary_image(Class==2) = 0;

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
% Data
figure; scatter3(X(Class==1), Y(Class==1), Z(Class==1));
hold on; scatter3(X(Class==2), Y(Class==2), Z(Class==2));
xlabel('raising'), ylabel('exponential slope'), zlabel('linear slope')
title('k-nn');

% Segmentation
figure;
imshow(im_boundaries);
%title('3D k-nn (k=5)');



