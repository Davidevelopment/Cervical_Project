% Based on example2 from OpenSURF Toolbox
function imagesStabilization2( handles )

Images = evalin('base','Images');

framesIndex = [str2double(get(handles.editFirst,'String')) str2double(get(handles.editLast,'String'))];
framesIndex = sort(framesIndex);
startIndex = framesIndex(1);
nFrames = framesIndex(2)-framesIndex(1)+1;

I1 = im2double(Images{startIndex});

Options.upright=true;
Options.tresh=0.0001;
Ipts1=OpenSurf(I1,Options);

D1 = reshape([Ipts1.descriptor],64,[]);

err=zeros(1,length(Ipts1));
cor1=1:length(Ipts1);
cor2=zeros(1,length(Ipts1));

for i = 1:nFrames-1
    i
    I2 = im2double(Images{startIndex + i});
    Ipts2=OpenSurf(I2,Options);
    D2 = reshape([Ipts2.descriptor],64,[]);
    
    % Find the best matches
    for j=1:length(Ipts1),
        distance=sum((D2-repmat(D1(:,j),[1 length(Ipts2)])).^2,1);
        [err(j),cor2(j)]=min(distance);
    end
    
    % Sort matches on vector distance
    [err, ind]=sort(err);
    upCor1=cor1(ind);
    cor2=cor2(ind);
    
    % Make vectors with the coordinates of the best matches
    Pos1=[[Ipts1(upCor1).y]',[Ipts1(upCor1).x]'];
    Pos2=[[Ipts2(cor2).y]',[Ipts2(cor2).x]'];
    Pos1=Pos1(1:30,:);
    Pos2=Pos2(1:30,:);
    
%     % Show both images
%     I = zeros([size(I1,1) size(I1,2)*2 size(I1,3)]);
%     I(:,1:size(I1,2),:)=I1; I(:,size(I1,2)+1:size(I1,2)+size(I2,2),:)=I2;
%     figure, imshow(I); hold on;
%     
%     % Show the best matches
%     plot([Pos1(:,2) Pos2(:,2)+size(I1,2)]',[Pos1(:,1) Pos2(:,1)]','-');
%     plot([Pos1(:,2) Pos2(:,2)+size(I1,2)]',[Pos1(:,1) Pos2(:,1)]','o');
%     hold off;
    
    % Calculate affine matrix
    Pos1(:,3)=1; Pos2(:,3)=1;
    M=Pos1'/Pos2';
    
    % Warp the image
    I2_warped = affine_warp(I2,inv(M),'bicubic');
    
%     % Show the result
%     figure,
%     subplot(1,3,1), imshow(I1);title('Figure 1');
%     subplot(1,3,2), imshow(I2);title('Figure 2');
%     subplot(1,3,3), imshow(I2_warped);title('Warped Figure 2');
    
    % Save the new image
    Images{startIndex + i} = im2uint8(I2_warped);
end
assignin('base','Images', Images);

% update images in gui
axes(handles.axesLast)
imshow(Images{framesIndex(2)});

end

