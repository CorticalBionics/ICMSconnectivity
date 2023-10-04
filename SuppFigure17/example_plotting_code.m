close all; clear; clc;

figX.fig = figure();
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([5 10]), 'NumberTitle', 'off');

figX.diagram = axes('Position', [.1 .65 .85 .3]);
annotation('textbox', [0, 0.92, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

figX.proj = axes('Position', [.15 .1 .75 .5]);
annotation('textbox', [0, 0.58, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

motorColor = rgb(0, 0, 0);
stimColor = rgb(40, 53, 147);


% Diagram
axes(figX.diagram)
viscircles([1 0], 1, 'Color', 'k');
text(.75, 0, 'Motor Exclusive', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
hold on
viscircles([2 -1], 1, 'Color', stimColor);
text(2.25, -1, 'Stim Exclusive', 'Color', stimColor, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
text(1.5, -.5, 'Shared', 'Color', rgb(100, 100, 100), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')

figX.diagram.YLim = [-2.25 1.25];
figX.diagram.YColor = 'none';
figX.diagram.XLim = [0 3];
figX.diagram.XColor = 'none';

% Subspace
load('shared_subspace_7_20_2022.mat')
SymphonicBeeSwarm(1, ProjVarExpl.X1onShared, motorColor, 5, 'CenterMethod', 'median', 'CenterColor', motorColor, 'CenterWidth', .1,...
    'DistributionMethod', 'histogram', 'BackgroundType', 'bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0, 'Parent', figX.proj)
SymphonicBeeSwarm(2, ProjVarExpl.X2onShared, stimColor, 5, 'CenterMethod', 'median', 'CenterColor', stimColor, 'CenterWidth', .1,...
    'DistributionMethod', 'histogram', 'BackgroundType', 'bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0, 'Parent', figX.proj)

figX.proj.XTick = [1 2];
figX.proj.XTickLabel = {'Motor', 'Stim'};
xlabel('Subspace Projections', 'Position', [1.5, -.055 0], 'Parent', figX.proj)

figX.proj.YLim = [0 .5];
figX.proj.YTick = [0 .5];
ylabel('Variance Explained', 'Position', [.45 .25 0], 'Parent', figX.proj)
