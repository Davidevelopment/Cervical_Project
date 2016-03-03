function init(handles)

addpath('Kovesi_toolbox');
addpath('OpenSURF');
addpath('OpenSURF/SubFunctions');
addpath('OpenSURF/WarpFunctions');

axes(handles.axes2); imshow('logo.tif');            % Display EPFL logo

axes(handles.axesGraph);                            % Display axes
xlabel('Time (s)'), ylabel('Projected value');

% Store some blank values
assignin('base','plotColors','');
assignin('base','legendsName','');

% Store some constants
assignin('base','framesSkipped',25);                % ratio of frame skipped (i.e. 1/frameSkipped)
assignin('base','resize_param',7);                  % spatial subsampling param
assignin('base','principalAxis', [0.3609 0.5941 0.7074]);   % see the report
%assignin('base','principalAxis', [0.5311 0.5815 0.6048]);    % madagascar

assignin('base','computePrincipalAxis', false);
assignin('base','fittingWindowSize', 1);