fig3.fig = figure('Name', 'Figure 3: Direct Effect of Stimulation on Activity in Motor Cortex');
set(fig3.fig, 'Units', 'centimeters', 'Position', [40 15 8.8 5], 'NumberTitle', 'off');
fig3.pta(1) = axes('Position', [.1 .675 .375 .275]);
fig3.pta(2) = axes('Position', [.1 .375 .375 .275]);
fig3.pta(3) = axes('Position', [.1 .075 .375 .275]);
fig3.pta(4) = axes('Position', [.575 .075 .375 .275]);
fig3.latplot = axes('Position', [.575 .475 .375 .475]);

% Which data to load
subjects = [{'C1'}, {'C1'}, {'P3'}, {'C1'}];
mcId = [145, 163, 8, 138];
seId = [11, 43, 18, 11];

staColor = rgb(40, 53, 147);
baselineColor = rgb(33, 33, 33);

for ss = 1:length(subjects)
    subjectID = subjects{ss};
    load([sprintf('PulseData_100Hz_%s_Unsorted.mat', subjectID)]);

    % Example PTAs
    AlphaLine(sm.ptaTimeVec(1:end - 1), squeeze(sm.pulse.indvPTA(sm.motorChannel == mcId(ss), sm.stimElectrode == seId(ss), :, 1:end - 1)), ...
        staColor, 'LineWidth', 1.5, 'IgnoreNaN', 2, 'ErrorType', 'STD', 'Parent', fig3.pta(ss))
    AlphaLine(sm.ptaTimeVec(1:end - 1), squeeze(sm.pulse.baselinePTA(sm.motorChannel == mcId(ss), sm.stimElectrode == seId(ss), :, 1:end - 1)), ...
        baselineColor, 'LineWidth', 1.5, 'IgnoreNaN', 2, 'ErrorType', 'STD', 'Parent', fig3.pta(ss))
    %
    % Stim Blank Interval
    [~, yMax] = getLimits(fig3.pta(ss).YLim, 0.05);
    plotStimInterval(0, 2.25, yMax, 'Parent', fig3.pta(ss))

    % Scale bars
    plot([0 0], [0 .1], 'k', 'LineWidth', 1.5, 'Parent', fig3.pta(ss))

    if ss == 3 || ss == 4
        plot([0 1], [0 0], 'k', 'LineWidth', 1.5, 'Parent', fig3.pta(ss))
        text(.5, 0, '1ms', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'Parent', fig3.pta(ss))
    end

    fig3.pta(ss).XTick = [];
    fig3.pta(ss).XColor = 'w';
    fig3.pta(ss).XLim = [0 9.5];
    fig3.pta(ss).YTick = [];
    fig3.pta(ss).YColor = 'w';
    fig3.pta(ss).YLim(1) = 0;

end

ylabel('p = 0.1', 'Color', 'k', 'Position', [-0.25, 0.05, 0], 'Parent', fig3.pta(3))
ylabel('p = 0.1', 'Color', 'k', 'Position', [-0.25, 0.025, 0], 'Parent', fig3.pta(4))

annotation('textbox', [0, 0.9, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0.46, 0.3, .1, .1], 'String', 'c', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');

% Latency plots
subjects = {'C1', 'P2', 'P3'};
subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];

for ss = 1:length(subjects)
    subjectID = subjects{ss};
    load([sprintf('PulseData_100Hz_%s_Unsorted.mat', subjectID)]);

    peakTime = sm.pulse.peakTime(sm.pulse.isModulated);

    latBins = 2:.5:10;
    cdfLat = NaN(1, length(latBins));
    for mm = 1:length(latBins)
        cdfLat(mm) = sum(peakTime <= latBins(mm));
    end
    cdfLat = cdfLat / length(peakTime);

    axes(fig3.latplot)
    plot(latBins, cdfLat, 'Color', subjectColors(ss, :), 'LineWidth', 1.5);
    hold on
    box off
end
fig3.latplot.XTick = [2, 6, 10];
fig3.latplot.XTickLabel = {'2', 'Latency [ms]', '10'};
fig3.latplot.XTickLabelRotation = 0;
fig3.latplot.XLim = [2 10];
fig3.latplot.YTick = [0 1];
ylabel('Proportion', 'Position', [1.9, .5, 0], 'Parent', fig3.latplot);
text(3.25, 1, ColorText(subjects, subjectColors), 'Parent', fig3.latplot, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')

annotation('textbox', [0.46, 0.9, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center');
