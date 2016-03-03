function clearGraph( handles )

% Clear axesGraph
axes(handles.axesGraph);
cla;
legend('off');
assignin('base','plotColors','');
assignin('base','legendsName','');


% Display the the first and last frames anew
Images = evalin('base','Images');

indexFirst = str2double(get(handles.editFirst,'String'));
axes(handles.axesFirst);
imshow(Images{indexFirst});

indexLast = str2double(get(handles.editLast,'String'));
axes(handles.axesLast);
imshow(Images{indexLast});


end

