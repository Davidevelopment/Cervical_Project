function loadImages(handles)

% Get the path file
[FileName, PathName] = uigetfile('*.jpg','Select image files', 'Multiselect', 'on');
if(~iscell(FileName))
    tmp{1} = FileName;
    FileName = tmp;
end
nFrames = size(FileName,2);

% %sort names
% Indices = zeros(nFrames,2);
% exp = '(\D?)(\d+)(\.[a-zA-Z]+)';      %(something) (number) (.ext)
% %exp = '(\.[a-zA-Z]+)'; % L'expression régulière ne permet que de prendre des noms de fichier contenant des numéros
% for j = 1:nFrames
%     [tokens,~] = regexp(FileName{j}, exp, 'tokens', 'match')
%     Indices(j,:) = [str2double(tokens{1}{2}) j]
% end
% Indices = sortrows(Indices,1);

% crop the images
% figure;
% [im rect] = imcrop(imread([PathName FileName{Indices(1,2)}]));
% close;

%load images
Images = cell(nFrames,1);
for i=1:nFrames
    %im = imread([PathName FileName{Indices(i,2)}]);
    im = imread([PathName FileName{i}]);
    Images{i} = imcrop(im, rect);
    %Images{i}=im;
end
FileName'

% Update the textFileName
set(handles.textFileName,'string',FileName{1});

% Set the visibility of the uipanels to 'on'
set(handles.uipanelArea,'Visible','on');
set(handles.uipanelFirst,'Visible','on');
set(handles.uipanelLast,'Visible','on');

% Save the images to the workspace
assignin('base','Images',Images);


% Display the default first frame
axes(handles.axesFirst);
imshow(Images{1});

% Display the lastFrame
axes(handles.axesLast);
imshow(Images{end});



% Update the interface
set(handles.editFirst,'String',num2str(1));
set(handles.textFirst1,'String',['Frame (total=' num2str(nFrames) ')']);

set(handles.editLast,'String',num2str(nFrames));
set(handles.textLast1,'String',['Frame (total=' num2str(nFrames) ')']);