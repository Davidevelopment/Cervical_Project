load data;

img = Frames{end};

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
        Training = [Training; double(end_start_lin(Index(ii,2),Index(ii,1))) ...
            double(tau(Index(ii,2),Index(ii,1))) ...
            double(final_slope(Index(ii,2),Index(ii,1))) ];
end

test = [end_start_lin(:) tau(:) final_slope(:)];
train_pos = Training(1:size(CIN_x,1),:);
train_neg = Training(size(CIN_x,1)+1:end,:);

% Extract file name
PathName = evalin('base', 'PathName');
exp = '([^/])+';
[tokens,~] = regexp(PathName, exp, 'tokens', 'match');

save(strcat('classification/', char(tokens{8}), '.mat'), 'img', 'test', 'train_neg', 'train_pos');







