function computeFalseColorMaps(handles)
% --- Executes on button press in pushbuttonFalseColor.
% hObject    handle to pushbuttonFalseColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%tic
Images = evalin('base','Images');



%% Step one: get the data

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


% Preallocate
cdata_ref = zeros(nFrames, areaHeight, areaWidth, 3);

% Read one frame at a time.
time = 60*(0:(nFrames-1));
for ii = 1 : nFrames
    cdata_ref(ii,:,:,:) = Images{ii}(areaRow:areaRow+areaHeight-1,areaCol:areaCol+areaWidth-1,:);
end



%% Step two : compute the principal axis and project the data

computePrincipalAxis = evalin('base','computePrincipalAxis');
if(computePrincipalAxis)
    % Learn the principal axis
    cdata_ref = projectDataOnPrincipalDirection(cdata_ref);
else
    % The principal axis has been learnt previously (see the report)
    principalAxis = evalin('base','principalAxis');
    cdata_ref = projectDataOnPrincipalDirection(cdata_ref, principalAxis);
end


%% Step three : compute the parameters of the referential zone - optional

% fit a line on semilog data
[maxValue, maxIndex] = max(cdata_ref(3:end)');
maxIndex = maxIndex+2;
if(maxIndex > nFrames)
            maxIndex = nFrames;
end
[slope, intercept, MSE1] = logfit(time(1:maxIndex)+1,cdata_ref(1:maxIndex),'logy');
yApprox = (10^intercept)*(10^slope).^(time(1:maxIndex)+1);

slope2 = 0;
MSE2 = 0;
if(maxIndex < nFrames-2)
    [slope2, ~, MSE2] = logfit(1+time(maxIndex:end), cdata_ref(maxIndex:end), 'linear');
end
referential = struct('end_start_lin',yApprox(end)-yApprox(1),...
    'tau',slope, 'end_value', cdata_ref(end),...
    'final_slope', slope2,'MSE',max(MSE1,MSE2),...
    'first_frame',str2double(get(handles.editFirst,'String')),...
    'last_frame', str2double(get(handles.editLast,'String')));
assignin('base','referential',referential);



%% Step four : compute videoObj_opt

% Spatial subsampling
Frames = {};
resize_param = evalin('base','resize_param');
resize_param = size(Images{1},1)*resize_param/720;
for ii = 1:nFrames   
    Frames{ii} = imresize(Images{ii+framesIndex(1)-1},1/resize_param);
end


% Update the tags
[width height ~] = size(Frames{framesIndex(1)});
assignin('base','Frames',Frames);



%% Step five : compute the parameters for the whole video

% Storage matrixes (warning: new width, height, nFrames)
tau = zeros(width,height);                  % time constant
end_start_lin = zeros(width,height);        % final - initial value 
MSE_mat = zeros(width,height);              % MSE values
end_values_lin = zeros(width,height);       % final value
final_slope = zeros(width,height);


for row = 2:width-1
    row
    for col = 2:height-1
        for ii = 1 : nFrames
            cdata(ii,:,:,:) = Frames{ii}(row-1:row+1,col-1:col+1,:);
        end
        if(computePrincipalAxis)
            cdata_proj = projectDataOnPrincipalDirection(cdata);
        else
            cdata_proj = projectDataOnPrincipalDirection(cdata,principalAxis);
        end
        data_proj{row,col} = cdata_proj;
        
        
        
        % Fitting
        [maxValue, maxIndex] = max(cdata_proj');
        %maxIndex = maxIndex+2;
        if(maxIndex > nFrames)
            maxIndex = nFrames;
        end
        maxValue = maxValue + 1;
        
        end_start_lin(row,col) = 0;
        tau(row,col) = 0;
        end_values_lin(row,col) = cdata_proj(end);
        if(maxIndex>3)
            %         [slope, intercept, MSE1] = logfit(time(1:maxIndex)+1,cdata_proj(1:maxIndex),'logy');
            %         yApprox = (10^intercept)*(10^slope).^(time(1:maxIndex)+1);
            
            [slope, intercept, MSE1] = logfit(time(1:maxIndex)+1, -log10(-cdata_proj(1:maxIndex)./ maxValue + 1), 'linear');
            yApprox = maxValue .* (1-(10^(-intercept))*(10^(-slope)).^(time(1:maxIndex)+1));
            
            end_start_lin(row,col) = yApprox(end)-yApprox(1);
            tau(row,col) = slope;
            end_values_lin(row,col) = cdata_proj(end);
        end
        slope2 = 0;
        MSE2 = 0;
        if(maxIndex < nFrames-2)
            [slope2, ~, MSE2] = logfit(1+time(maxIndex:end), cdata_proj(maxIndex:end), 'linear');
        end
        final_slope(row,col) = slope2;
        MSE_mat(row,col) = max(MSE1, MSE2);
        
        
    end
end


% save to workspace
assignin('base','end_start_lin',end_start_lin);
assignin('base','tau',tau);
assignin('base','end_values_lin',end_values_lin);
assignin('base','final_slope',final_slope);
assignin('base','MSE_mat',MSE_mat);
assignin('base','data_proj', data_proj);



%% Step six : Plot the maps


figure();

subplot(3,2,1)
imagesc(tau,[-2*referential.tau 2*referential.tau]);
title('time constant'); colorbar;

subplot(3,2,2);
if referential.end_start_lin>0
   imagesc(end_start_lin,[0 2*referential.end_start_lin]);
else
    imagesc(end_start_lin,[2*referential.end_start_lin 0]);
end
title('raising/rehaussement'); colorbar;

subplot(3,2,3)
imagesc(end_values_lin);
title('end values/valeurs finales'); colorbar;

subplot(3,2,4)
imagesc(final_slope);
title('final linear slope'); colorbar;

subplot(3,2,5)
imagesc(MSE_mat, [0 mean(MSE_mat(:))+2*std(MSE_mat(:))]);
title('MSE'); colorbar;