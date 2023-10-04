close all; clear; clc;

figX.fig = figure();
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([15 6]), 'NumberTitle', 'off');
figX.active(1) = axes('Position', [.04 .075 .175 .275]); figX.active(2) = axes('Position', [.04 .35 .175 .275]); figX.active(3) = axes('Position', [.04 .625 .175 .275]);
figX.grasp(1) = axes('Position', [.22 .075 .175 .275]); figX.grasp(2) = axes('Position', [.22 .35 .175 .275]); figX.grasp(3) = axes('Position', [.22 .625 .175 .275]);
figX.carry(1) = axes('Position', [.4 .075 .175 .275]); figX.carry(2) = axes('Position', [.4 .35 .175 .275]); figX.carry(3) = axes('Position', [.4 .625 .175 .275]);
annotation('textbox', [0, 0.9, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

figX.decoder = axes('Position', [.585 .1 .4 .825]);
annotation('textbox', [0.575, 0.9, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

load('ProcessedData_P3.mat');

mcId = [42, 242, 55];
forceColors = cmap_gradient([255, 167, 38; 230, 81, 0], 4);
forceLevels = [3, 6, 9, 12];
xMin = 0; xMax = 50;

for mc = 1:length(mcId)
    mcIdx = chanRefIdx == mcId(mc);

    % Active
    activeTimeIdx = 176:225;
    meanTraj = squeeze(nanmean(trialFRGrasp(:, activeTimeIdx, mcIdx), 1)) * 50;
    axes(figX.active(mc))
    plot([1 49], [0 0], 'k:', 'LineWidth', 1)
    hold on
    for ff = 1:numel(forceLevels)
        plot(squeeze(nanmean(trialFRGrasp(trialTargetGrasp == forceLevels(ff), activeTimeIdx, mcIdx), 1)) * 50 - meanTraj, 'Color', forceColors(ff,:), 'LineWidth', 1.5);
        hold on;
    end

    box off
    figX.active(mc).XLim = [xMin xMax];
    figX.active(mc).XTick = [];
    figX.active(mc).XColor = 'w';
    figX.active(mc).YTick = [];
    figX.active(mc).YColor = 'w';

    % Grasp
    graspTimeIdx = 101:150;
    meanTraj = squeeze(nanmean(trialFRBoth(:, graspTimeIdx, mcIdx), 1)) * 50;
    axes(figX.grasp(mc))
    plot([1 49], [0 0], 'k:', 'LineWidth', 1)
    hold on
    for ff = 1:numel(forceLevels)
        plot(squeeze(nanmean(trialFRBoth(trialTargetBoth == forceLevels(ff), graspTimeIdx, mcIdx), 1)) * 50 - meanTraj, 'Color', forceColors(ff,:), 'LineWidth', 1.5);
        hold on;
    end
    box off
    figX.grasp(mc).XLim = [xMin xMax];
    figX.grasp(mc).XTick = [];
    figX.grasp(mc).XColor = 'w';
    figX.grasp(mc).YTick = [];
    figX.grasp(mc).YColor = 'w';

    % Carry
    carryTimeIdx = 241:290;
    meanTraj = squeeze(nanmean(trialFRBoth(:, carryTimeIdx, mcIdx), 1)) * 50;
    axes(figX.carry(mc))
    plot([1 49], [0 0], 'k:', 'LineWidth', 1)
    hold on
    for ff = 1:numel(forceLevels)
        plot(squeeze(nanmean(trialFRBoth(trialTargetBoth == forceLevels(ff), carryTimeIdx, mcIdx), 1)) * 50 - meanTraj, 'Color', forceColors(ff,:), 'LineWidth', 1.5);
        hold on;
    end
    box off
    figX.carry(mc).XLim = [xMin xMax];
    figX.carry(mc).XTick = [];
    figX.carry(mc).XColor = 'w';
    figX.carry(mc).YTick = [];
    figX.carry(mc).YColor = 'w';
end

figX.active(1).YLim = [-8 8];
figX.grasp(1).YLim = [-8 8];
figX.carry(1).YLim = [-8 8];
plot([0 0], [-8 -3], 'k', 'LineWidth', 1.5, 'Parent', figX.active(1))
text(-1, -5.5, '5Hz', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Parent', figX.active(1))

plot([0 12.5], [-8 -8], 'k', 'LineWidth', 1.5, 'Parent', figX.active(1))
text(6.25, -8, '250ms', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Parent', figX.active(1))

figX.active(2).YLim = [-5 5];
figX.grasp(2).YLim = [-5 5];
figX.carry(2).YLim = [-5 5];
plot([0 0], [-5 0], 'k', 'LineWidth', 1.5, 'Parent', figX.active(2))

figX.active(3).YLim = [-15 15];
figX.grasp(3).YLim = [-15 15];
figX.carry(3).YLim = [-15 15];
plot([0 0], [-15 -10], 'k', 'LineWidth', 1.5, 'Parent', figX.active(3))

title('Squeeze', 'Parent', figX.active(3))
title('Grasp', 'Parent', figX.grasp(3))
title('Transport', 'Parent', figX.carry(3))

% Decoder performance
load('CrossPhaseClassNormdBoth.mat')

axes(figX.decoder)
confusionMatrix(ClassifierAcc_CombinedP3, 'FontSize', 12)
colormap(flipud(bone))
caxis([0.25 1])
figX.decoder.XTick = 1:3;
figX.decoder.XTickLabel = {'Squeeze', 'Grasp', 'Transport'};
figX.decoder.XTickLabelRotation = 0;
figX.decoder.YTick = 1:3;
figX.decoder.YTickLabel = {'Squeeze', 'Grasp', 'Transport'};
figX.decoder.YTickLabelRotation = 90;
figX.decoder.YAxisLocation = 'right';
xlabel('Condition Tested', 'Position', [2 0.25 0], 'FontWeight', 'bold', 'Parent', figX.decoder)
ylabel('Condition Trained', 'Position', [0.25 2 0], 'FontWeight', 'bold', 'Parent', figX.decoder)