function reverseImagesSequence( handles )

%reverse ordering of images
Images = evalin('base','Images');
Images = flip(Images);
nFrames = size(Images,1);
assignin('base','Images',Images);

%compute new indices
frameStart = floor(str2double(get(handles.editFirst,'String')));
frameEnd = floor(str2double(get(handles.editLast,'String')));
newStart = nFrames-frameEnd+1;
newEnd = nFrames-frameStart+1;

%update tags
set(handles.editFirst,'String',num2str(newStart));
set(handles.editLast,'String',num2str(newEnd));

%update images
axes(handles.axesFirst);
if (frameStart > 0 && frameStart < nFrames+1)
    imshow(Images{newStart});
end

axes(handles.axesLast);
if (frameStart > 0 && frameStart < nFrames+1)
    imshow(Images{newEnd});
end
end

