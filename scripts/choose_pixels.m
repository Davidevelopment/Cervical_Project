% choose_pixels.m
% Show last frame and user selects 50 cancerous pixels and 50 non-cancerous
% pixels
% The selected pixels are saved in 'data.mat'


figure; 
imshow(Frames{end});
title('Select by hand 50 cancerous pixels of the same diagnosis and press enter');
[CIN_x,CIN_y] = ginput();


figure; 
imshow(Frames{end});title('Select by hand 50 non cancerous pixels and press enter');
[OTHER_x,OTHER_y] = ginput();
close; close; close;



%save the 4 components into a matrix
save('data.mat','CIN_x','CIN_y','OTHER_x','OTHER_y')