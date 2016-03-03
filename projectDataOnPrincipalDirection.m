function [ cdata_out ] = projectDataOnPrincipalDirection( cdata, axis )
%PROJECTDATAONPRINCIPALDIRECTION This function performs a projection of the data
%   on the principal axis (i.e. the direction of maximum variance)
%
%   [cdata_out] = projectDataOnPrincipalDirection(cdata)
%
%   cdata is a 4D matrix (frame, pos_x, pos_y, RGB values)
%   i.e. a given frame, a given height, a given width, RGB values
%
%   cdata_out is a 2D matrix organised as [frame, projectedData]
%   the principal axis is saved automatically in the workspace



% Convert the 4D into a 2D matrix
nFrames = size(cdata,1);
cdata2D = zeros(nFrames,3);     % cdata2D is (frames, RGB-values)

for ii = 1: nFrames
    cdata2D(ii,:) = mean(mean(cdata(ii,:,:,:),2),3);
end


% Compute the principal axis
if nargin == 1
    COEFF =  princomp(cdata2D);
    B = [COEFF(1,1),COEFF(2,1),COEFF(3,1)];
else
    % If the axis argument was given, keep it
    B = axis;
end
assignin('base','principalAxis', B);   



% Project the data
C = zeros(nFrames,3);

for ii = 1:nFrames
    %calculation of the projection of the data into B
    C(ii,:) = (sum([cdata2D(ii,1), cdata2D(ii,2), cdata2D(ii,3)].*B)/(norm(B)^2))*B;
end


% data is now projected
cdata_out = C(:,1);



% %%% Do some plot stuff
% %%% Uncomment this only when you're using the PCA feature
% 
% % Plot the data 
% figure(); hold on; grid on;
% xlabel('R'), ylabel('G'), zlabel('B');
% title('RGB values for each frame of a given pixel');
% 
% plot3(cdata2D(:,1),cdata2D(:,2),cdata2D(:,3),'r.');
% % gname                 
% 
% % Plot the axe with biggest variance
% q = 20*[-B(1,1) -B(1,2) -B(1,3); B(1,1) B(1,2) B(1,3)];
% plot3(q(:,1),q(:,2),q(:,3));
% 
% % Plot the origin plot3(0,0,0,'o');
% 
% % PLot the projected data
% plot3(C(:,1),C(:,2),C(:,3),'x','Color','k');
% 
% 
% legend('data (zero mean)','principal axis','projected data','Location','SouthEast')


end

