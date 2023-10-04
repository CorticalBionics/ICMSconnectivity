close all; clear; clc;
saveFigure = 0;

load('SpearmanCorrFullyShuffled.mat');
subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];

figX.fig = figure('Name', '');
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([10 6]), 'NumberTitle', 'off');
figX.ax1 = axes('Position', [.05 .15 .425 .75]);
annotation('textbox', [0, 0.9, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

load('C1smData.mat')

temp1 = squeeze(smData.rf.hmap(1,:,:));temp2 = squeeze(smData.rf.hmap(2,:,:));temp3 = squeeze(smData.rf.hmap(3,:,:));temp4 = squeeze(smData.rf.hmap(4,:,:));%temp5 = squeeze(filtRF(5,:,:));
motorHMapOrder = [temp1(:)';temp2(:)';temp3(:)';temp4(:)'];%;temp5(:)'];

temp1 = squeeze(smData.pf.hmap(1,:,:));temp2 = squeeze(smData.pf.hmap(2,:,:));temp3 = squeeze(smData.pf.hmap(3,:,:));temp4 = squeeze(smData.pf.hmap(4,:,:));%temp5 = squeeze(filtPF(5,:,:));
senseHMapOrder = [temp1(:)';temp2(:)';temp3(:)';temp4(:)'];%;temp5(:)'];

rho = corr(motorHMapOrder(:,[2:9 11:90 92:99]),senseHMapOrder(:,[2:9 11:90 92:99]),'type','Pearson');
trueCorrs = diag(rho);
shuffCorrs = zeros(96,10000);
for iter = 1:10000
    tempHMap = motorHMapOrder(:,[2:9 11:90 92:99]);
    shuffMHMap = tempHMap(:,randperm(96));
    tempHMap = senseHMapOrder(:,[2:9 11:90 92:99]);
    shuffSHMap = tempHMap(:,randperm(96));

    for i = 1:96
        shuffMHMap(:,i) = shuffMHMap(randperm(4),i);
        shuffSHMap(:,i) = shuffSHMap(randperm(4),i);
    end

    rho = corr(shuffMHMap,shuffSHMap,'type','Pearson');
    shuffCorrs(:,iter) = diag(rho);
end

histogram(median(shuffCorrs, 1), 'BinEdges', -1:0.05:1, 'FaceColor', [0.4 0.4 0.4], 'EdgeAlpha', 0, 'Normalization', 'probability');
hold on;
stem(median(trueCorrs), 0.2, 'v', 'Color', subjectColors(1, :), 'MarkerSize', 7, 'MarkerFaceColor', subjectColors(1, :), 'LineWidth', 1.5, 'MarkerEdgeColor', 'none');
set(gca, 'XTick', -1:1, 'YColor', 'none')
xlabel('Correlation [\rho]')
title('C1')
box off

figX.ax2 = axes('Position', [.525 .15 .425 .75]);
annotation('textbox', [0.5, 0.9, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

load('P3smData.mat')

temp1 = squeeze(smData.rf.hmap(1,:,:));temp2 = squeeze(smData.rf.hmap(2,:,:));temp3 = squeeze(smData.rf.hmap(3,:,:));%temp4 = squeeze(smData.rf.hmap(4,:,:));%temp5 = squeeze(filtRF(5,:,:));
motorHMapOrder = [temp1(:)';temp2(:)';temp3(:)'];

temp1 = squeeze(smData.pf.hmap(1,:,:));temp2 = squeeze(smData.pf.hmap(2,:,:));temp3 = squeeze(smData.pf.hmap(3,:,:));%temp4 = squeeze(smData.pf.hmap(4,:,:));%temp5 = squeeze(filtPF(5,:,:));
senseHMapOrder = [temp1(:)';temp2(:)';temp3(:)'];

rho = corr(motorHMapOrder(:,[2:9 11:90 92:99]),senseHMapOrder(:,[2:9 11:90 92:99]),'type','Pearson');
trueCorrs = diag(rho);
shuffCorrs = zeros(96,10000);
for iter = 1:10000

    tempHMap = motorHMapOrder(:,[2:9 11:90 92:99]);
    shuffMHMap = tempHMap(:,randperm(96));
    tempHMap = senseHMapOrder(:,[2:9 11:90 92:99]);
    shuffSHMap = tempHMap(:,randperm(96));

    for i = 1:96
        shuffMHMap(:,i) = shuffMHMap(randperm(3),i);
        shuffSHMap(:,i) = shuffSHMap(randperm(3),i);
    end

    rho = corr(shuffMHMap,shuffSHMap,'type','Pearson');
    shuffCorrs(:,iter) = diag(rho);

end

histogram(median(shuffCorrs, 1), 'BinEdges', -1:0.05:1, 'FaceColor', [0.4 0.4 0.4], 'EdgeAlpha', 0, 'Normalization', 'probability');
hold on;
stem(median(trueCorrs), 0.2, 'v', 'Color', subjectColors(3, :), 'MarkerSize', 7, 'MarkerFaceColor', subjectColors(3, :), 'LineWidth', 1.5, 'MarkerEdgeColor', 'none');
set(gca, 'XTick', -1:1, 'YColor', 'none')
xlabel('Correlation [\rho]')
title('P3')
box off