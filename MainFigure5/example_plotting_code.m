load('RevisionResults.mat');
subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];

fig5.fig = figure('Name', 'Figure X: Correlation Within Arrays');
set(fig5.fig, 'Units', 'centimeters', 'Position', [40 20 8.8 4.6], 'NumberTitle', 'off');

fig5.panelA1 = axes('Position', [.08 .175 .25 .775]);
annotation('textbox', [0, 0.9, .05, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

CDFbins = -3:.001:6;
sameDist = zeros(length(CDFbins),1);
otherDist = zeros(length(CDFbins),1);

sameMods = [sameModNormC1{1} sameModNormC1{2} sameModNormC1{3} sameModNormC1{4} sameModNormC1{5}];
otherMods = [otherModNormC1{1} otherModNormC1{2} otherModNormC1{3} otherModNormC1{4} otherModNormC1{5}];

for i = 1:length(CDFbins)
    sameDist(i) = sum(sameMods < CDFbins(i))/sum(~isnan(sameMods));
    otherDist(i) = sum(otherMods < CDFbins(i))/sum(~isnan(otherMods));
end

plot(CDFbins, sameDist, 'LineWidth', 1, 'Color', subjectColors(1, :));
hold on;
plot(CDFbins, otherDist, 'LineWidth', 1, 'Color', [.4 .4 .4]);
stem(0, 1, 'k:', 'Marker', 'none')
set(gca, 'XLim', [-3 6], 'XTick', -3:3:6, 'YTick', 0:.5:1, 'YTickLabel', {'0', '', '1'})
box off
xlabel('Normalized Modulation', 'Position', [6.5 -0.125 -1])
ylabel('Proportion of Electrodes', 'Position', [-3.5 0.5000 -1])
% title('C1')
text(-2.5, 1, 'C1', 'Color', subjectColors(1, :), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left')
text(6, .2, ColorText({'Matched Digits', 'Unmatched Digits'}, [subjectColors(1, :); [.4 .4 .4]]), 'FontSize', 5, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')

fig5.panelA2 = axes('Position', [.37 .175 .25 .775]);
CDFbins = -3:.001:6;
sameDist = zeros(length(CDFbins),1);
otherDist = zeros(length(CDFbins),1);

sameMods = [sameModNormP3{1} sameModNormP3{2} sameModNormP3{3} sameModNormP3{4} sameModNormP3{5}];
otherMods = [otherModNormP3{1} otherModNormP3{2} otherModNormP3{3} otherModNormP3{4} otherModNormP3{5}];

for i = 1:length(CDFbins)
    sameDist(i) = sum(sameMods < CDFbins(i))/sum(~isnan(sameMods));
    otherDist(i) = sum(otherMods < CDFbins(i))/sum(~isnan(otherMods));
end

plot(CDFbins, sameDist, 'LineWidth', 1, 'Color', subjectColors(3, :));
hold on;
plot(CDFbins, otherDist, 'LineWidth', 1, 'Color', [.4 .4 .4]);
stem(0, 1, 'k:', 'Marker', 'none')
set(gca, 'XLim', [-3 6], 'XTick', -3:3:6, 'YTick', 0:.5:1, 'YTickLabel', '')
box off
% xlabel('Normalized Modulation')
% title('P3')
text(-2.5, 1, 'P3', 'Color', subjectColors(3, :), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left')
text(6, .2, ColorText({'Matched Digits', 'Unmatched Digits'}, [subjectColors(3, :); [.4 .4 .4]]), 'FontSize', 5, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top')

fig5.panelB = axes('Position', [.71 .175 .275 .775]);
annotation('textbox', [.625, 0.895, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

meanC1 = mean(unrollSortStimRespC1,2,'omitnan');
meanP3 = mean(unrollSortStimRespP3,2,'omitnan');
SEMC1 = std(unrollSortStimRespC1,0,2,'omitnan')./sqrt(sum(~isnan(unrollSortStimRespC1),2));
SEMP3 = std(unrollSortStimRespP3,0,2,'omitnan')./sqrt(sum(~isnan(unrollSortStimRespP3),2));

errorbar(1:4, meanC1, SEMC1, '-o', 'Color', subjectColors(1, :), 'LineWidth', 1, 'MarkerSize', 3, 'MarkerFaceColor', subjectColors(1, :));
hold on
errorbar(1:3, meanP3, SEMP3, '-o', 'Color', subjectColors(3, :), 'LineWidth', 1, 'MarkerSize', 3, 'MarkerFaceColor', subjectColors(3, :));
set(gca, 'YLim', [-1 1], 'YTick', -1:1:1, 'YTickLabel', {'-1', '', '1'}, 'XLim', [0.75 4.25])
box off
xlabel('Motor Digit Ranking')
ylabel('Normalized Stim Response', 'Position', [0.55 0 -1]);
text(1.05, -0.5, ColorText({'C1', 'P3'}, [subjectColors(1, :); subjectColors(3, :)]), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top')
