figX.fig = figure('Name', 'Figure X: Heatmaps');
set(figX.fig, 'Units', 'pixels', 'Position', OSScreenSize([10 18]), 'NumberTitle', 'off');

axWidth = .3;
axHeight = .145;
stimX = [.025, .315, .025, .315, .025, .315];
medMotorY = [.825, .825, .495, .495, .165, .165];
latMotorY = [.67, .67, .34, .34, 0.01, 0.01];

annotation('textbox', [0, 0.94, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0.64, 0.93, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0, 0.6, .1, .1], 'String', 'c', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0.64, 0.6, .1, .1], 'String', 'd', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0, 0.27, .1, .1], 'String', 'e', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

annotation('textbox', [0.64, 0.27, .1, .1], 'String', 'f', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

figX.cbar(1) = axes('Position', [.6 .735 .025 .2]);
figX.cbar(2) = axes('Position', [.6 .405 .025 .2]);
figX.cbar(3) = axes('Position', [.6 .075 .025 .2]);

cMin = -5; cMax = 10;
propHigh = cMax / (abs(cMax) + abs(cMin));
propLow = 1 - propHigh;
hmapColors = cmap_gradient([rgb(25, 118, 210); rgb(250, 250, 250); rgb(194, 24, 91)], [propLow, propHigh]);

subject = {'C1', 'C1', 'P2', 'P2', 'P3', 'P3'};
seId = [23, 48, 44, 21, 34, 13]; 

for ss = 1:length(subject)

    subjectID = subject{ss};
    switch subjectID
        case 'C1'
            arrayInfo = UC_chan_mapper('FullMapLatMed.txt');
        case 'P2'
            arrayInfo = Pitt_chan_mapper_P2('FullMapLatMed.txt');
        case 'P3'
            arrayInfo = Pitt_chan_mapper_P3('FullMapLatMed.txt');
    end
    load([sprintf('TrainData_100Hz_%s_Unsorted.mat', subjectID)]);


    seIdx = sm.stimElectrode == seId(ss);
    hmap = createHeatmapMatrix(sm.modValue(:, seIdx), sm.motorChannel, 'motor', arrayInfo);
    hmap.medial([1 1 10 10], [1 10 1 10]) = 0.1;
    hmap.lateral([1 1 10 10], [1 10 1 10]) = 0.1;

    if strcmpi(subjectID, 'BCI02')
        rotHmapMedial = imrotate(hmap.medial, 180);
        rotHmapLateral = imrotate(hmap.lateral, 90);
    elseif strcmpi(subjectID, 'CRS02b')
        rotHmapMedial = imrotate(hmap.medial, 0);
        rotHmapLateral = imrotate(hmap.lateral, 270);
    else
        rotHmapMedial = imrotate(hmap.medial, 0);
        rotHmapLateral = imrotate(hmap.lateral, 270);
    end


    figX.hmap(ss, 1) = axes('Position', [stimX(ss) medMotorY(ss) axWidth axHeight]);
    generateHeatmap(rotHmapMedial, 'cmap', hmapColors, 'plotOutline', 1, 'cLim', [cMin, cMax]);
    axis square
    set(gca, 'Color', rgb(176, 190, 197))

    figX.hmap(ss, 2) = axes('Position', [stimX(ss) latMotorY(ss) axWidth axHeight]);
    generateHeatmap(rotHmapLateral, 'cmap', hmapColors, 'plotOutline', 1, 'cLim', [cMin, cMax]);
    axis square
    set(gca, 'Color', rgb(176, 190, 197))
end

markerSize = 8;
% C1
title('Medial Stimulating', 'FontWeight', 'normal', 'Parent', figX.hmap(1,1))
title('Lateral Stimulating', 'FontWeight', 'normal', 'Parent', figX.hmap(2,1))
ylabel('Medial Motor', 'Parent', figX.hmap(1,1))
text(-.25, 5.5, 'Medial Motor', 'Rotation', 90, 'HorizontalAlignment', 'center', 'Parent', figX.hmap(1, 1))
text(-.25, 5.5, 'Lateral Motor', 'Rotation', 90, 'HorizontalAlignment', 'center', 'Parent', figX.hmap(1, 2))

plot(10, 1, 's', 'Color', [29, 111, 169] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [29, 111, 169] ./ 255, 'Parent', figX.hmap(1, 1))
plot(10, 1, 's', 'Color', [29, 111, 169] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [29, 111, 169] ./ 255, 'Parent', figX.hmap(2, 1))

plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', figX.hmap(1, 2))
plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', figX.hmap(2, 2))

% P2
title('Medial Stimulating', 'FontWeight', 'normal', 'Parent', figX.hmap(3,1))
title('Lateral Stimulating', 'FontWeight', 'normal', 'Parent', figX.hmap(4,1))
text(-.25, 5.5, 'Medial Motor', 'Rotation', 90, 'HorizontalAlignment', 'center', 'Parent', figX.hmap(3, 1))
text(-.25, 5.5, 'Lateral Motor', 'Rotation', 90, 'HorizontalAlignment', 'center', 'Parent', figX.hmap(3, 2))

plot(10, 1, 's', 'Color', [29, 111, 169] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [29, 111, 169] ./ 255, 'Parent', figX.hmap(3, 1))
plot(10, 1, 's', 'Color', [29, 111, 169] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [29, 111, 169] ./ 255, 'Parent', figX.hmap(4, 1))

plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', figX.hmap(3, 2))
plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', figX.hmap(4, 2))

% P3
title('Medial Stimulating', 'FontWeight', 'normal', 'Parent', figX.hmap(5,1))
title('Lateral Stimulating', 'FontWeight', 'normal', 'Parent', figX.hmap(6,1))
text(-.25, 5.5, 'Medial Motor', 'Rotation', 90, 'HorizontalAlignment', 'center', 'Parent', figX.hmap(5, 1))
text(-.25, 5.5, 'Lateral Motor', 'Rotation', 90, 'HorizontalAlignment', 'center', 'Parent', figX.hmap(5, 2))

plot(10, 1, 's', 'Color', [29, 111, 169] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [29, 111, 169] ./ 255, 'Parent', figX.hmap(5, 1))
plot(10, 1, 's', 'Color', [29, 111, 169] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [29, 111, 169] ./ 255, 'Parent', figX.hmap(6, 1))

plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', figX.hmap(5, 2))
plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', markerSize, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', figX.hmap(6, 2))

% Colorbar
axes(figX.cbar(1))
axis off
caxis([cMin, cMax])
cbar = colorbar;
cbar.Ticks = [];
cbar.Location = 'westoutside';
cbar.Position = [.605, .685, .025, .115];
text(.775, 0.28, '+', 'FontSize', 20, 'FontWeight', 'normal', 'Parent', figX.cbar(1), 'HorizontalAlignment', 'center', 'VerticalAlignment','bottom')
text(.775, -.36, '-', 'FontSize', 25, 'FontWeight', 'normal', 'Parent', figX.cbar(1), 'HorizontalAlignment', 'center', 'VerticalAlignment','bottom')

axes(figX.cbar(2))
axis off
caxis([cMin, cMax])
cbar = colorbar;
cbar.Ticks = [];
cbar.Location = 'westoutside';
cbar.Position = [.605, .355, .025, .115];
text(.775, 0.28, '+', 'FontSize', 20, 'FontWeight', 'normal', 'Parent', figX.cbar(2), 'HorizontalAlignment', 'center', 'VerticalAlignment','bottom')
text(.775, -.36, '-', 'FontSize', 25, 'FontWeight', 'normal', 'Parent', figX.cbar(2), 'HorizontalAlignment', 'center', 'VerticalAlignment','bottom')

axes(figX.cbar(3))
axis off
caxis([cMin, cMax])
cbar = colorbar;
cbar.Ticks = [];
cbar.Location = 'westoutside';
cbar.Position = [.605, .025, .025, .115];
text(.775, 0.28, '+', 'FontSize', 20, 'FontWeight', 'normal', 'Parent', figX.cbar(3), 'HorizontalAlignment', 'center', 'VerticalAlignment','bottom')
text(.775, -.36, '-', 'FontSize', 25, 'FontWeight', 'normal', 'Parent', figX.cbar(3), 'HorizontalAlignment', 'center', 'VerticalAlignment','bottom')

% Correlations across arrays
covWidth = .25;
covHeight = .14;
covX = .73;
medCovY = [.825, .495, .165];
latCovY = [.67, .34, 0.01];

withinArrayColor = rgb(249, 168, 37);
withinMedial = [29, 111, 169] ./ 255;
withinLateral = [139, 193, 69] ./ 255;
acrossArrayColor = rgb(97, 97, 97);
subject = {'C1', 'P2', 'P3'};
for ss = 1:length(subject)
    subjectID = subject{ss};
    load([sprintf('distData_%s.mat', subjectID)]);


    acrossArrayIdx = distData.s1ArrayIdx ~= distData.s2ArrayIdx;
    withinArrayIdx = distData.s1ArrayIdx == distData.s2ArrayIdx;

    p = ranksum(distData.medialMotor.corr(withinArrayIdx), distData.medialMotor.corr(acrossArrayIdx));

    corrColor = rgb(97, 97, 97);
    figX.distCorr(ss, 1) = axes('Position', [covX medCovY(ss) covWidth covHeight]);
    SymphonicBeeSwarm(1, distData.medialMotor.corr(withinArrayIdx), withinMedial, 5, 'CenterMethod', 'median', 'CenterColor', withinMedial, 'CenterWidth', .1,...
        'DistributionMethod', 'Histogram', 'BackgroundType', 'Violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
    hold on
    SymphonicBeeSwarm(2, distData.medialMotor.corr(acrossArrayIdx), acrossArrayColor, 5, 'CenterMethod', 'median', 'CenterColor', acrossArrayColor, 'CenterWidth', 0.1,...
        'DistributionMethod', 'Histogram', 'DistributionWidth', 0.25, 'BackgroundType', 'Violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
    if p <= 0.001
        plot([1,2], [1.025 1.025], 'k', 'LineWidth', 1)
        text(1.5, 1.05, '***', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle')
    end

    figX.distCorr(ss,1).XTick = [1 2];
    figX.distCorr(ss,1).XTickLabel = '';
    figX.distCorr(ss,1).XLim = [0.5 2.5];
    figX.distCorr(ss,1).YLim = [-1 1.1];
    figX.distCorr(ss,1).YTick = -1:1;
    ylabel('Correlation', 'Parent', figX.distCorr(ss,1))
    if ss == 1
        text(1, 1, 'Within', 'Color', withinMedial,'Parent', figX.distCorr(ss,1), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
        text(2, 1, 'Across', 'Color', acrossArrayColor,'Parent', figX.distCorr(ss,1), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
    else
        text(1, -1, 'Within', 'Color', withinMedial,'Parent', figX.distCorr(ss,1), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
        text(2, -1, 'Across', 'Color', acrossArrayColor,'Parent', figX.distCorr(ss,1), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
    end
    p = ranksum(distData.lateralMotor.corr(withinArrayIdx), distData.lateralMotor.corr(acrossArrayIdx));

    figX.distCorr(ss, 2) = axes('Position', [covX latCovY(ss) covWidth covHeight]);
    SymphonicBeeSwarm(1, distData.lateralMotor.corr(withinArrayIdx), withinLateral, 5, 'CenterMethod', 'median', 'CenterColor', withinLateral, 'CenterWidth', .1,...
        'DistributionMethod', 'Histogram', 'BackgroundType', 'Violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
    hold on
    SymphonicBeeSwarm(2, distData.lateralMotor.corr(acrossArrayIdx), acrossArrayColor, 5, 'CenterMethod', 'median', 'CenterColor', acrossArrayColor, 'CenterWidth', 0.1,...
        'DistributionMethod', 'Histogram', 'DistributionWidth', 0.25, 'BackgroundType', 'Violin', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 200)
    if p <= 0.001
        plot([1,2], [1.025 1.025], 'k', 'LineWidth', 1)
        text(1.5, 1.05, '***', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle')
    elseif p < 0.01
        plot([1,2], [1.025 1.025], 'k', 'LineWidth', 1)
        text(1.5, 1.05, '**', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle')
    elseif p < 0.05
        plot([1,2], [1.025 1.025], 'k', 'LineWidth', 1)
        text(1.5, 1.05, '*', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment','middle')
    end
    figX.distCorr(ss,2).XTick = [1 2];
    figX.distCorr(ss,2).XTickLabel = '';
    figX.distCorr(ss,2).XTickLabelRotation = 0;
    figX.distCorr(ss,2).XLim = [0.5 2.5];
    figX.distCorr(ss,2).YLim = [-1 1.1];
    figX.distCorr(ss,2).YTick = -1:1;
    ylabel('Correlation', 'Parent', figX.distCorr(ss,2))
    text(1, -1, 'Within', 'Color', withinLateral,'Parent', figX.distCorr(ss,2), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
    text(2, -1, 'Across', 'Color', acrossArrayColor,'Parent', figX.distCorr(ss,2), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
end
