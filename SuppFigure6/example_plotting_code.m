figX.fig = figure('Name', 'Figure X: Anti vs Ortho');
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([15 8]), 'NumberTitle', 'off');
figX.unsorted(1) = axes('Position', [.05 .55 .275 .4]);
figX.sorted(1) = axes('Position', [.05 .075 .275 .4]);

figX.unsorted(2) = axes('Position', [.375 .55 .275 .4]);
figX.sorted(2) = axes('Position', [.375 .075 .275 .4]);

figX.unsorted(3) = axes('Position', [.7 .55 .275 .4]);
figX.sorted(3) = axes('Position', [.7 .075 .275 .4]);

annotation('textbox', [0, 0.925, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0, 0.45, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

subjectID = {'C1', 'P2', 'P3'};
subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];

distMethod = 'KernelDensity';

for ss = 1:length(subjectID)
    load([sprintf('PulseData_100Hz_%s_Unsorted.mat', subjectID{ss})]);
    isPhaseLocked = sm.pulse.isModulated & sm.pulse.pSpikeAny < 0.2 & sm.pulse.peakTimeJitter < 1;

    if sum(isPhaseLocked(:)) < 10
        distWidth = 0;
    else
        distWidth = 0.3;
    end

    Swarm(ss, sm.pulse.peakTimeJitter(isPhaseLocked), 'Color', subjectColors(ss, :), 'SMS', 10, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :),...
        'DistributionMethod', 'Histogram', 'DistributionWidth', distWidth, 'DistributionStyle', 'violin', 'DistributionFaceAlpha', 0.1, 'DistributionLineAlpha', 1,...
        'SwarmFaceAlpha', .5, 'SwarmEdgeAlpha', .5, 'Parent', figX.unsorted(1))

    Swarm(ss, sm.pulse.peakLatency(isPhaseLocked), 'Color', subjectColors(ss, :), 'SMS', 10, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :),...
        'DistributionMethod', 'Histogram', 'DistributionWidth', distWidth, 'DistributionStyle', 'violin', 'DistributionFaceAlpha', 0.1, 'DistributionLineAlpha', 1,...
        'SwarmFaceAlpha', .5, 'SwarmEdgeAlpha', .5, 'Parent', figX.unsorted(2))

    Swarm(ss, sm.pulse.pSpikeAny(isPhaseLocked), 'Color', subjectColors(ss, :), 'SMS', 10, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :),...
        'DistributionMethod', 'Histogram', 'DistributionWidth', distWidth, 'DistributionStyle', 'violin', 'DistributionFaceAlpha', 0.1, 'DistributionLineAlpha', 1,...
        'SwarmFaceAlpha', .5, 'SwarmEdgeAlpha', .5, 'Parent', figX.unsorted(3))

    if ss == 2
        continue
    end

    load([sprintf('PulseData_100Hz_%s_Sorted.mat', subjectID{ss})]);
    isPhaseLocked = sm.pulse.isModulated & sm.pulse.pSpikeAny < 0.2 & sm.pulse.peakTimeJitter < 1;

    if sum(isPhaseLocked(:)) < 10
        distWidth = 0;
    else
        distWidth = 0.3;
    end

    Swarm(ss, sm.pulse.peakTimeJitter(isPhaseLocked), 'Color', subjectColors(ss, :), 'SMS', 10, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :),...
        'DistributionMethod', 'Histogram', 'DistributionWidth', distWidth, 'DistributionStyle', 'violin', 'DistributionFaceAlpha', 0.1, 'DistributionLineAlpha', 1,...
        'SwarmFaceAlpha', .5, 'SwarmEdgeAlpha', .5, 'Parent', figX.sorted(1))

    Swarm(ss, sm.pulse.peakLatency(isPhaseLocked), 'Color', subjectColors(ss, :), 'SMS', 10, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :),...
        'DistributionMethod', 'Histogram', 'DistributionWidth', distWidth, 'DistributionStyle', 'violin', 'DistributionFaceAlpha', 0.1, 'DistributionLineAlpha', 1,...
        'SwarmFaceAlpha', .5, 'SwarmEdgeAlpha', .5, 'Parent', figX.sorted(2))

    Swarm(ss, sm.pulse.pSpikeAny(isPhaseLocked), 'Color', subjectColors(ss, :), 'SMS', 10, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :),...
        'DistributionMethod', 'Histogram', 'DistributionWidth', distWidth, 'DistributionStyle', 'violin', 'DistributionFaceAlpha', 0.1, 'DistributionLineAlpha', 1,...
        'SwarmFaceAlpha', .5, 'SwarmEdgeAlpha', .5, 'Parent', figX.sorted(3))
end

figX.unsorted(1).XTick = [1:3];
figX.unsorted(1).XTickLabel = '';
figX.unsorted(1).XLim = [0 4];
figX.unsorted(1).YLim = [-.1 1];
figX.unsorted(1).YTick = [0 1];
ylabel('ms^2', 'Position', [-0.05 .5 0], 'Parent', figX.unsorted(1))
title('Jitter', 'Parent', figX.unsorted(1))

figX.sorted(1).XTick = [1:3];
figX.sorted(1).XTickLabel = subjectID;
figX.sorted(1).XLim = [0 4];
figX.sorted(1).YLim = [-.1 1];
figX.sorted(1).YTick = [0 1];
ylabel('ms^2', 'Position', [-0.05 .5 0], 'Parent', figX.sorted(1))

figX.unsorted(2).XTick = [1:3];
figX.unsorted(2).XTickLabel = '';
figX.unsorted(2).XLim = [0 4];
figX.unsorted(2).YLim = [0 10];
figX.unsorted(2).YTick = [0 10];
ylabel('ms', 'Position', [-0.05 5 0], 'Parent', figX.unsorted(2))
title('Latency', 'Parent', figX.unsorted(2))

figX.sorted(2).XTick = [1:3];
figX.sorted(2).XTickLabel = subjectID;
figX.sorted(2).XLim = [0 4];
figX.sorted(2).YLim = [0 10];
figX.sorted(2).YTick = [0 10];
ylabel('ms', 'Position', [-0.05 5 0], 'Parent', figX.sorted(2))

figX.unsorted(3).XTick = [1:3];
figX.unsorted(3).XTickLabel = '';
figX.unsorted(3).XLim = [0 4];
figX.unsorted(3).YLim = [0 .25];
figX.unsorted(3).YTick = [0 .25];
ylabel('p(spike)', 'Position', [-0.05 .125 0], 'Parent', figX.unsorted(3))
title('Spike Probability', 'Parent', figX.unsorted(3))

figX.sorted(3).XTick = [1:3];
figX.sorted(3).XTickLabel = subjectID;
figX.sorted(3).XLim = [0 4];
figX.sorted(3).YLim = [0 .25];
figX.sorted(3).YTick = [0 .25];
ylabel('p(spike)', 'Position', [-0.05 .125 0], 'Parent', figX.sorted(3))
box off