clear; close all; clc;
saveFigure = 0;
SetFont('Arial', 10)

% Define figure coordinates and axes
figX.fig = figure('');
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([5 6]), 'NumberTitle', 'off');
figX.ax = axes('Position', [.175 .1 .75 .825]);

subject = {'C1', 'P2', 'P3'};
subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];

for ss = 1:length(subject)

    subjectID = subject{ss};

    load([sprintf('TrainData_100Hz_%s_Unsorted.mat', subjectID)]);

    meanModValueMC = mean(sm.modValue, 2);
    SymphonicBeeSwarm(ss, meanModValueMC, subjectColors(ss, :), 5, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :), 'CenterWidth', .1,...
        'DistributionMethod', 'KernelDensity', 'BackgroundWidth', .25, 'BackgroundType', 'violin',  'BackgroundWidth', .3, 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
    hold on
    box off

end

figX.ax.YTick = -5:5:10;
figX.ax.YLim = [-5 10];
ylabel('Mean Modulation', 'Parent', figX.ax)
figX.ax.XLim = [0.3 3.5];
figX.ax.XTick = 1:3;
figX.ax.XTickLabel = subjectLabel;