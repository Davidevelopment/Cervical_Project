% Compute median of already computed principal axes
% Output axis is 'pca'
% ______________
% Select input file:
filename = 'PCA_HUG.mat';
% ______________

s = load(filename);
fields = fieldnames(s);
axes = zeros(size(fields,1),3);
for i=1:numel(fields)
    axes(i,:) = s.(fields{i});
end

pca = median(axes)
figure; hold on; grid on;
xlabel('R'), ylabel('G'), zlabel('B');
h = plot3([0 pca(1)], [0 pca(2)], [0 pca(3)], 'r'); set(h,'linewidth',2);
for i=1:size(axes,1)
    plot3([0 axes(i,1)], [0 axes(i,2)], [0 axes(i,3)], 'b');
end
