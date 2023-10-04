fig7.fig = figure('Name', 'Figure 7: Stimulation Effects on Decoding');
set(fig7.fig, 'Units', 'centimeters', 'Position', [40 10 8.8 3], 'NumberTitle', 'off');
fig7.failureRate = axes('Position', [.1 .15 .375 .8]);
annotation('textbox', [0, 0.9, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

fig7.pathLength = axes('Position', [.6 .15 .375 .8]);
annotation('textbox', [0.49, 0.9, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

load('TransportLengthForViolin.mat');

% Colors
noStimColor = rgb(97, 97, 97);
linearStimColor = rgb(2, 136, 209);
biomStimColor = rgb(48, 63, 159);

% Failure Rate
axes(fig7.failureRate)
for dd = 1:3
    plot([1,2,3], [1 - noStimSuccessRate(dd), 1 - stimSuccessRate(dd), 1 - bioSuccessRate(dd)] * 100, '--', 'Color', rgb(189, 189, 189))
    hold on
end

SymphonicBeeSwarm(1, mean((1 - noStimSuccessRate) * 100), noStimColor, 3, 'CenterMethod', 'mean', 'CenterColor', noStimColor, 'CenterWidth', 0,...
    'DistributionMethod', 'histogram', 'BackgroundType', 'Bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0)
hold on

SymphonicBeeSwarm(2, mean((1 - stimSuccessRate) * 100), linearStimColor, 3, 'CenterMethod', 'mean', 'CenterColor', linearStimColor, 'CenterWidth', 0,...
    'DistributionMethod', 'histogram', 'BackgroundType', 'Bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0)

SymphonicBeeSwarm(3, mean((1 - bioSuccessRate) * 100), biomStimColor, 3, 'CenterMethod', 'mean', 'CenterColor', biomStimColor, 'CenterWidth', 0,...
    'DistributionMethod', 'histogram', 'BackgroundType', 'Bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0)

for dd = 1:3
    scatter(1, (1 - noStimSuccessRate(dd)) * 100, 5, 'filled', 'MarkerFaceColor', noStimColor, 'MarkerEdgeColor', noStimColor, 'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5)
    scatter(2, (1 - stimSuccessRate(dd)) * 100, 5, 'filled', 'MarkerFaceColor', linearStimColor, 'MarkerEdgeColor', linearStimColor, 'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5)
    scatter(3, (1 - bioSuccessRate(dd)) * 100, 5, 'filled', 'MarkerFaceColor', biomStimColor, 'MarkerEdgeColor', biomStimColor, 'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5)
end
box off

fig7.failureRate.XTick =  1:3;
fig7.failureRate.XTickLabel = {'No Stim', 'Linear', 'Biomimetic'};
fig7.failureRate.XTickLabelRotation = 0;
fig7.failureRate.YTick = [0:20:80];
fig7.failureRate.YLim = [0 80];
fig7.failureRate.XLim = [0.5 3.5];
ylabel(['% Failed Trials'], 'Parent', fig7.failureRate)

% Plot Significance Lines
plot([1.15 1.85], [70 70], 'k', 'LineWidth', 1, 'Parent', fig7.failureRate)
text(1.5, 72.5, '*', 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle')
plot([2.15, 2.85], [75 75], 'k', 'LineWidth', 1, 'Parent', fig7.failureRate)
text(2.5, 77.5, '*', 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle')

axes(fig7.pathLength)
bkgdWidth = .25;
SymphonicBeeSwarm(1, carryLengthNoStim(carryTimeNoStim > 3), noStimColor, 2, 'CenterMethod', 'median', 'CenterColor', noStimColor, 'CenterWidth', .1,...
    'DistributionMethod', 'KernelDensity', 'BackgroundWidth', bkgdWidth, 'BackgroundType', 'violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
hold on
SymphonicBeeSwarm(2, carryLengthStim(carryTimeStim > 3), linearStimColor, 2, 'CenterMethod', 'median', 'CenterColor', linearStimColor, 'CenterWidth', .1,...
    'DistributionMethod', 'KernelDensity', 'BackgroundWidth', bkgdWidth, 'BackgroundType', 'violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
SymphonicBeeSwarm(3, carryLengthBio(carryTimeBio > 3), biomStimColor, 2, 'CenterMethod', 'median', 'CenterColor', biomStimColor, 'CenterWidth', .1,...
    'DistributionMethod', 'KernelDensity', 'BackgroundWidth', bkgdWidth, 'BackgroundType', 'violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
    'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
fig7.pathLength.XTick =  1:3;
fig7.pathLength.XLim = [0.5 3.5];
fig7.pathLength.XTickLabel = {'No Stim', 'Linear', 'Biomimetic'};
fig7.pathLength.XTickLabelRotation = 0;
fig7.pathLength.YTick = [0:5:30];
fig7.pathLength.YLim = [0 30];
ylabel('Path Length [m]', 'Parent', fig7.pathLength)
