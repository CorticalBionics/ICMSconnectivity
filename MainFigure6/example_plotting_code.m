load('ProcessedData_220328.mat');

fig6.fig = figure('Name', 'Figure 6: Motor Activity is Modulated by Task Conditions');
set(fig6.fig, 'Units', 'centimeters', 'Position', [40 15 8.8 6.5], 'NumberTitle', 'off');

xActive = .04; 
xGrasp = .215;
xCarry = .39;
fig6.active(1) = axes('Position', [xActive .05 .15 .225]); fig6.active(2) = axes('Position', [xActive .3 .15 .225]); fig6.active(3) = axes('Position', [xActive .55 .15 .225]); 
fig6.grasp(1) = axes('Position', [xGrasp .05 .15 .225]); fig6.grasp(2) = axes('Position', [xGrasp .3 .15 .225]); fig6.grasp(3) = axes('Position', [xGrasp .55 .15 .225]); 
fig6.carry(1) = axes('Position', [xCarry .05 .15 .225]); fig6.carry(2) = axes('Position', [xCarry .3 .15 .225]); fig6.carry(3) = axes('Position', [xCarry .55 .15 .225]); 
annotation('textbox', [0, 0.915, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

fig6.decoder = axes('Position', [.6 .535 .4 .4]);
annotation('textbox', [0.57, 0.915, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');


fig6.switchPlot = axes('Position', [.65 .075 .3 .375]);
annotation('textbox', [0.57, 0.4, .1, .1], 'String', 'c', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

mcId = [150, 189, 165];
forceColors = cmap_gradient([255, 167, 38; 230, 81, 0], 4);
forceLevels = [3, 6, 9, 12];
xMin = 0; xMax = 50;
yMin = -10; yMax = 10;

for mc = 1:length(mcId)
    mcIdx = chanRefIdx == mcId(mc);

    % Active
    activeTimeIdx = 176:225;
    meanTraj = squeeze(nanmean(trialFRGrasp(:, activeTimeIdx, mcIdx), 1)) * 50;
    axes(fig6.active(mc))
    plot([1 49], [0 0], 'k:', 'LineWidth', 1)
    hold on
    for ff = 1:numel(forceLevels)
        plot(squeeze(nanmean(trialFRGrasp(trialTargetGrasp == forceLevels(ff), activeTimeIdx, mcIdx), 1)) * 50 - meanTraj, 'Color', forceColors(ff,:), 'LineWidth', 1);
        hold on;
    end
    box off
    fig6.active(mc).XLim = [xMin xMax];
    fig6.active(mc).XTick = [];
    fig6.active(mc).XColor = 'none';
    fig6.active(mc).YTick = [];
    fig6.active(mc).YColor = 'none';

    % Grasp
    graspTimeIdx = 101:150;
    meanTraj = squeeze(nanmean(trialFRBoth(:, graspTimeIdx, mcIdx), 1)) * 50;
    axes(fig6.grasp(mc))
    plot([1 49], [0 0], 'k:', 'LineWidth', 1)
    hold on
    for ff = 1:numel(forceLevels)
        plot(squeeze(nanmean(trialFRBoth(trialTargetBoth == forceLevels(ff), graspTimeIdx, mcIdx), 1)) * 50 - meanTraj, 'Color', forceColors(ff,:), 'LineWidth', 1);
        hold on;
    end
    box off
    fig6.grasp(mc).XLim = [xMin xMax];
    fig6.grasp(mc).XTick = [];
    fig6.grasp(mc).XColor = 'none';
    fig6.grasp(mc).YTick = [];
    fig6.grasp(mc).YColor = 'none';

    % Carry
    carryTimeIdx = 241:290;
    meanTraj = squeeze(nanmean(trialFRBoth(:, carryTimeIdx, mcIdx), 1)) * 50;
    axes(fig6.carry(mc))
    plot([1 49], [0 0], 'k:', 'LineWidth', 1)
    hold on
    for ff = 1:numel(forceLevels)
        plot(squeeze(nanmean(trialFRBoth(trialTargetBoth == forceLevels(ff), carryTimeIdx, mcIdx), 1)) * 50 - meanTraj, 'Color', forceColors(ff,:), 'LineWidth', 1);
        hold on;
    end
    box off
    fig6.carry(mc).XLim = [xMin xMax];
    fig6.carry(mc).XTick = [];
    fig6.carry(mc).XColor = 'none';
    fig6.carry(mc).YTick = [];
    fig6.carry(mc).YColor = 'none';
end
fig6.active(1).YLim = [-10 10];
fig6.grasp(1).YLim = [-10 10];
fig6.carry(1).YLim = [-10 10];
plot([0 0], [-10 -5],  'k', 'LineWidth', 1, 'Parent', fig6.active(1))
text(-7, -3.5, '5Hz', 'Rotation', 90, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'Parent', fig6.active(1))
plot([0 12.5], [-10 -10], 'k', 'LineWidth', 1, 'Parent', fig6.active(1))
text(15, -10, '250ms', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Parent', fig6.active(1))

fig6.active(2).YLim = [-6 6];
fig6.grasp(2).YLim = [-6 6];
fig6.carry(2).YLim = [-6 6];
plot([0 0], [-6 -1], 'k', 'LineWidth', 1, 'Parent', fig6.active(2))

fig6.active(3).YLim = [-20 20];
fig6.grasp(3).YLim = [-20 20];
fig6.carry(3).YLim = [-20 20];
plot([0 0], [-20 -15], 'k', 'LineWidth', 1, 'Parent', fig6.active(3))

% Confusion Matrix: Decoder Performance
load('CrossPhaseClassNormdBoth.mat')

axes(fig6.decoder)
confusionMatrix(ClassifierAcc_CombinedC1)
colormap(flipud(bone))
caxis([0.25 1])
fig6.decoder.XTick = 1:3;
fig6.decoder.XTickLabel = {'Squeeze', 'Grasp', 'Transport'};
fig6.decoder.XTickLabelRotation = 0;
fig6.decoder.YTick = 1:3;
fig6.decoder.YTickLabel = {'Squeeze', 'Grasp', 'Transport'};
fig6.decoder.YTickLabelRotation = 90;
fig6.decoder.YAxisLocation = 'right';
fig6.decoder.FontSize = 6.5;
xlabel('Condition Tested', 'Position', [2 0.075 0], 'FontSize', 7,'FontWeight', 'bold', 'Parent', fig6.decoder)
ylabel('Condition Trained', 'Position', [0.075 2 0], 'FontSize', 7, 'FontWeight', 'bold', 'Parent', fig6.decoder)

% Switch Scatter Plot
load('C:/Users/somlab/Dropbox/S1 to M1 Paper/Figures/Main Figures/Fig 6 - Behavioral Modulation/Data/switchStat.mat')
load('fd_GraspAndCarry_C1_20220328.mat');

directColor = rgb(249, 168, 37);
indirectColor = rgb(40, 53, 147);
motorChannel = fd.motorChannel;
mcIdx = ismember(motorChannel, chanRefIdx);
peakyIdx = [sum(fd.task.isModulated(:, [4, 8]), 2) == 2]';

[peakyCounts, peakyBins] = histcounts(switchIdx(peakyIdx(mcIdx)), 0:10);

axes(fig6.switchPlot)
[f, x] = ecdf(switchIdx(peakyIdx(mcIdx)));
plot(x, f, 'Color', directColor, 'LineWidth', 1.5)
hold on
[f, x] = ecdf(switchIdx(~peakyIdx(mcIdx)));
plot(x, f, 'Color', indirectColor, 'LineWidth', 1.5)
fig6.switchPlot.XScale = 'linear';
box off

fig6.switchPlot.XTick = [0 5 10];
fig6.switchPlot.XLim = [0 10];
fig6.switchPlot.XTickLabel = {'0', 'Task Dependence', '10'};
fig6.switchPlot.XTickLabelRotation = 0;
fig6.switchPlot.YLim = [0 1];
fig6.switchPlot.YTick = [0 1];
ylabel('Cum. Fraction', 'Position', [-0.35, .5, 0], 'Parent', fig6.switchPlot)
text(10, .3, ColorText({'Direct', 'Indirect'}, [directColor; indirectColor]), 'Parent', fig6.switchPlot, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')
