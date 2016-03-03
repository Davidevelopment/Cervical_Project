function plotColorCurve(handles)

% get the ColorSpace
content = get(handles.popupmenuColorSpace,'String');
colorSpace = content{get(handles.popupmenuColorSpace,'Value')};

switch colorSpace
    case 'PCA'
        indexRGB = 1:3;
        plotColor = 'k';
    case 'Red'
        indexRGB = 1;
        plotColor = 'r';
    case 'Green'
        indexRGB = 2;
        plotColor = 'g';
    case 'Blue'
        indexRGB = 3;
        plotColor = 'b';
end

% Get the frames difference
framesIndex = [str2double(get(handles.editFirst,'String')) str2double(get(handles.editLast,'String'))];
framesIndex = sort(framesIndex);                              % to make sure it's ordered
nFrames = framesIndex(2)-framesIndex(1)+1;


% Get the area propreties
area = evalin('base','pos');

areaRow = floor(area.pos(2));
areaCol = floor(area.pos(1));
areaHeight = floor(area.pos(4));
areaWidth = floor(area.pos(3));


% Load images
Images = evalin('base','Images');

% Preallocate
cdata = zeros(nFrames, areaHeight, areaWidth, size(indexRGB,2));

% Read one frame at a time.
for ii = 1 : nFrames
    cdata(ii,:,:,:) = Images{ii}(areaRow:areaRow+areaHeight-1,areaCol:areaCol+areaWidth-1,indexRGB);
end



% Process a pca if necessary
computePrincipalAxis = evalin('base','computePrincipalAxis');
switch colorSpace
    case 'PCA'
        if(computePrincipalAxis)
            % If you want to learn the principal axis uncomment this and
            % comment the two lines before
            cdata = projectDataOnPrincipalDirection(cdata);
        else
            % Process a pca
            principalAxis = evalin('base','principalAxis');
            cdata = projectDataOnPrincipalDirection(cdata,principalAxis);
        end
        
    otherwise       
        % If the area is bigger than a single pixel
        if (size(cdata,2) > 1 && size(cdata,3) > 1)
            % we take the mean
            cdata = mean(mean(cdata(:,:,:),3),2);
        end
end



% Plot
axes(handles.axesGraph);
set(handles.axesGraph,'Visible','on');
hold on;
plot(1:nFrames,cdata,plotColor);


% Display proper legends
legendsName = evalin('base','legendsName');
if strcmp(area.type, 'pixel')
    legendsName = cellstr([legendsName; [area.type ' - ' colorSpace]]);
else
    legendsName = cellstr([legendsName; [area.type '(mean) - ' colorSpace]]);
end
assignin('base','legendsName',legendsName);


plotColors = evalin('base','plotColors');
plotColors = [plotColors; plotColor];
assignin('base','plotColors',plotColors);

legend(plotColors,legendsName,'Location','NorthEastOutside')
