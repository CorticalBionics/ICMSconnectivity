figX.fig = figure();
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([6 6]), 'NumberTitle', 'off');

figX.ax = axes('Position', [.15 .15 .8 .8]);
subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];

load('Processed Data.mat')

meanC1 = mean(meanFRbyStim_220328,2,'omitnan');
meanP3 = mean(meanFRbyStim_220527,2,'omitnan');
SEMC1 = std(meanFRbyStim_220328,0,2,'omitnan')./sqrt(sum(~isnan(meanFRbyStim_220328),2));
SEMP3 = std(meanFRbyStim_220527,0,2,'omitnan')./sqrt(sum(~isnan(meanFRbyStim_220527),2));

errorbar([20, 32, 44, 56], meanC1, SEMC1, '-o', 'Color', subjectColors(1, :), 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', subjectColors(1, :));
hold on
errorbar([20, 32, 44, 56], meanP3, SEMP3, '-o', 'Color', subjectColors(3, :), 'LineWidth', 1.5, 'MarkerSize', 5, 'MarkerFaceColor', subjectColors(3, :));
box off
set(gca, 'YLim', [-0.5 0.5], 'YTick', -0.5:.5:1, 'XLim', [15 60], 'XTick', [20, 32, 44, 56])
xlabel('Stimulation Amplitude [\muA]')
ylabel('Normalized Firing Rate', 'Position', [10, 0, -1])
text(17, 0.5, ColorText({'C1', 'P3'}, [subjectColors(1, :); subjectColors(3, :)]), 'FontSize', 12, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')