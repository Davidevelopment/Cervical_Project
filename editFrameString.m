function editFrameString( hObject, handles )

if(hObject == handles.editLast)
    axes(handles.axesLast);
else
    axes(handles.axesFirst);
end

frameEnd = floor(str2double(get(hObject,'String')));

Images = evalin('base','Images');
nFrames = size(Images,1);

if (frameEnd > 0 && frameEnd < nFrames+1)
    imshow(Images{frameEnd});
    
    % Update Tags
    set(hObject,'String',num2str(frameEnd));
end

end

