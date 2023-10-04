clear; close all; clc;
saveFigure = 0;

% Define figure coordinates and axes
figX.fig = figure('Name', 'Figure X: Correlation Within Arrays');
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([14 6]), 'NumberTitle', 'off');
figX.lateralCorr(1) = axes('Position', [.085 .15 .275 .775]);
figX.lateralCorr(2) = axes('Position', [.385 .15 .275 .775]);
figX.lateralCorr(3) = axes('Position', [.685 .15 .275 .775]);

subject = {'C1', 'P2', 'P3'};

medialColor = rgb(255, 0, 102);
lateralColor = rgb(241, 157, 25);

for ss = 1:length(subject)

    subjectID = subject{ss};

    load([sprintf('distData_%s.mat', subjectID)]);

    AlphaLine((distData.distValues(1:end-1) + diff(distData.distValues) / 2) .* .4, distData.lateralMotor.medialSensoryBin, medialColor, ...
        'LineWidth', 1.5, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'SEM', 'Parent', figX.lateralCorr(ss));
    AlphaLine((distData.distValues(1:end-1) + diff(distData.distValues) / 2) .* .4, distData.lateralMotor.lateralSensoryBin, lateralColor, ...
        'LineWidth', 1.5, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'SEM', 'Parent', figX.lateralCorr(ss));
    figX.lateralCorr(ss).XLim = [0.5 3.5];
    figX.lateralCorr(ss).YLim = [0 1];
    figX.lateralCorr(ss).YTick = [0:.25:1];
    title(sprintf('%s', subjectID), 'Parent', figX.lateralCorr(ss))
end

figX.lateralCorr(1).YLim = [0 1];
figX.lateralCorr(2).YTickLabel = [];
figX.lateralCorr(3).YTickLabel = [];

ylabel('Correlation', 'Parent', figX.lateralCorr(1))
xlabel('Channel Distance [mm]', 'Parent', figX.lateralCorr(2))

text(3.5, 1, ColorText({'Medial', 'Lateral'}, [medialColor; lateralColor]), 'Parent', figX.lateralCorr(1), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')
