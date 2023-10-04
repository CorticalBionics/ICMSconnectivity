% Define figure coordinates and axes
figX.fig = figure('');
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([12 10]), 'NumberTitle', 'off');
figX.modMC(1) = axes('Position', [.05 .535 .3 .415]);
figX.modMC(2) = axes('Position', [.37 .535 .3 .415]);
figX.modMC(3) = axes('Position', [.69 .535 .3 .415]);

figX.modValue(1) = axes('Position', [.05 .05 .3 .4]);
figX.modValue(2) = axes('Position', [.37 .05 .3 .4]);
figX.modValue(3) = axes('Position', [.69 .05 .3 .4]);

annotation('textbox', [0, 0.93, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0, 0.435, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

subject = {'C1', 'P2', 'P3'};
subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];

for ss = 1:length(subject)

    subjectID = subject{ss};

    load([sprintf('TrainData_100Hz_%s_Sorted.mat', subjectID)]);
    smSorted = sm;
    load([sprintf('TrainData_100Hz_%s_Unsorted.mat', subjectID)]);
    smUnsorted = sm;
    clear sm;

    modMCSorted = mean(smSorted.isModulated);
    modMCUnsorted = mean(smUnsorted.isModulated);
    axes(figX.modMC(ss))
    SymphonicBeeSwarm(1, modMCSorted, subjectColors(ss, :), 5, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :), 'CenterWidth', .1,...
        'DistributionMethod', 'KernelDensity', 'BackgroundWidth', .25, 'BackgroundType', 'violin',  'BackgroundWidth', .3, 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)

    SymphonicBeeSwarm(2, modMCUnsorted, subjectColors(ss, :), 5, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :), 'CenterWidth', .1,...
        'DistributionMethod', 'KernelDensity', 'BackgroundWidth', .25, 'BackgroundType', 'violin',  'BackgroundWidth', .3, 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
    title(sprintf('%s', subjectLabels{ss}), 'Parent', figX.modMC(ss))
    figX.modMC(ss).XTick = [1 2];
    figX.modMC(ss).XLim = [0.5 2.5];
    figX.modMC(ss).XTickLabel = {'Sorted', 'Unsorted'};
    figX.modMC(ss).YLim = [0 .6];
    figX.modMC(ss).YTick = [0 .6];
    if ss ~= 1
        figX.modMC(ss).YTickLabel = '';
    end

    axes(figX.modValue(ss))
    SymphonicBeeSwarm(1, abs(smSorted.modValue(:)), subjectColors(ss, :), 5, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :), 'CenterWidth', .1,...
        'DistributionMethod', 'KernelDensity', 'BackgroundWidth', .25, 'BackgroundType', 'violin',  'BackgroundWidth', .3, 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)

    SymphonicBeeSwarm(2, abs(smUnsorted.modValue(:)), subjectColors(ss, :), 5, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :), 'CenterWidth', .1,...
        'DistributionMethod', 'KernelDensity', 'BackgroundWidth', .25, 'BackgroundType', 'violin',  'BackgroundWidth', .3, 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1 99], 'MaxPoints', 200)

    figX.modValue(ss).XTick = [1 2];
    figX.modValue(ss).XTickLabel = {'Sorted', 'Unsorted'};
    figX.modValue(ss).XLim = [0.5 2.5];

    figX.modValue(ss).YLim = [0 15];
    figX.modValue(ss).YTick = [0 15];
    if ss ~= 1
        figX.modValue(ss).YTickLabel = '';
    end

end

figX.modMC(1).YTick = [0 .6];
ylabel('p(Modulated Motor Channels)', 'Position', [0.45 .3 0], 'Parent', figX.modMC(1))

figX.modValue(1).YTick = [0 15];
ylabel('Modulation Value', 'Position', [0.45 7.5 0], 'Parent', figX.modValue(1))
