% Compute PCA for several sequence files
% ______________
% Select output filename:
filename = 'PCA_HUG.mat';
% ______________

addpath ../;
stop = 0;

while(~stop)
    [FileName, PathName] = uigetfile('*.jpg','Select image files', 'Multiselect', 'on');
    
    if(~iscell(FileName))
        tmp{1} = FileName;
        FileName = tmp;
    end
    nFrames = size(FileName,2);
    
    %select croping area
    figure;
    [im rect] = imcrop(imread([PathName FileName{1}]));
    close;
    
    %load images
    disp('Load and crop images...');
    images = zeros(nFrames, size(im,1), size(im,2), 3);
    for i=1:nFrames
        im = imread([PathName FileName{i}]);
        images(i,:,:,:) = imcrop(im, rect);
    end
    
    %compute PCA
    disp('Compute PCA');
    clear principalAxis axis;
    projectDataOnPrincipalDirection(images);
    axis = evalin('base', 'principalAxis');
    
    % Extract file name
    PathName = evalin('base', 'PathName');
    exp = '([^/])+';
    [tokens,~] = regexp(PathName, exp, 'tokens', 'match');
    name = char(tokens{8});
    S.(name) = axis;
    
    choice = questdlg('Load another sample?', 'Continue', 'Yes', 'Stop', 'Yes');
    switch choice
        case 'Stop'
            stop = 1;
    end
    
end

if exist(filename,'file')
    save(filename, '-struct', 'S', '-append');
else
    save(filename, '-struct', 'S');
end





