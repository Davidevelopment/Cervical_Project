function pixelsSelection( handles, type )

axes(handles.axesFirst);

Images = evalin('base','Images');
height = size(Images{1},1);
width = size(Images{1},2);



if(strcmp(type, 'pixel'))
    % Make sure the point is on the figure and not on the UI (you can plot on both figures (axesFirst and axesLast))
    IsOnFigure = false;
    while IsOnFigure == false
        [x,y] = ginput(1);
        
        if (x > 0 && x < width && y > 0 && y < height)
            IsOnFigure = true;
        end
    end
    
    % Plot it
    hold on;
    plot(x,y,'c','Marker','x','MarkerSize',10);
    
    % Save pos in the worspace as a rectangle [x y width heigth]
    pos = struct('pos',[x y 1 1],'type','pixel');
    assignin('base','pos',pos);
end

if(strcmp(type, '3x3'))
    axes(handles.axesFirst);
    % Make sure the point is on the figure and not on the UI (you can plot on both figures (axesFirst and aXesLast))
    IsOnFigure = false;
    while IsOnFigure == false
        [x,y] = ginput(1);
        if (x > 0 && x < width-3 && y > 0 && y < height-3)
            IsOnFigure = true;
        end
    end
    
    % Draw a 3x3 rectangle
    rectangle('EdgeColor','y','Position',[x y 3 3], 'LineWidth',2, 'EdgeColor','b');
    
    % Save pos in the worspace as a rectangle [x y width heigth]
    pos = struct('pos',[x y 3 3],'type','3x3');
    assignin('base','pos',pos);
end

if(strcmp(type, 'rectangle'))
    % Create draggable rectangle
    h = imrect(gca);
    pos = struct('pos',getPosition(h),'type','rect');
    assignin('base','pos',pos);
    
    % Call save_pos each time the rectangle is moved
    addNewPositionCallback(h,@(p)save_pos(p));
end


set(handles.uipanelColor,'Visible','on');
set(handles.uipanelFalseColor,'Visible','on');
set(handles.pushbuttonClearAll,'Visible','on');

end

% Update the position structure everytime the rectangle is moved
function save_pos(p)
pos = struct('pos',p,'type','rect');
assignin('base','pos',pos);
end

