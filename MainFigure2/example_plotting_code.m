fig2.fig = figure('Name', 'Figure 2: Stimulation Effect on Activity in Motor Cortex');
set(fig2.fig, 'Units', 'centimeters', 'Position', [40 15 8.8 3], 'NumberTitle', 'off');
fig2.seCDF(1) = axes('Position', [.035 .125 .215 .85]);
fig2.seCDF(2) = axes('Position', [.265 .125 .215 .85]);
fig2.seCDF(3) = axes('Position', [.495 .125 .215 .85]);
annotation('textbox', [0, 0.88, .1, .1], 'String', 'a', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

fig2.modValue = axes('Position', [.81 .15 .18 .75]); %axes('Position', [.4 .15 .275 .75]);
annotation('textbox', [0.7, 0.88, .1, .1], 'String', 'b', 'FitBoxToText', 'on', 'LineStyle', 'none', 'Rotation', 0, ...
    'FontWeight', 'bold', 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left');

subjectColors = [rgb(106, 27, 154); rgb(239, 108, 0); rgb(46, 125, 50)];
hmapColors = cmap_gradient([rgb(255, 255, 255); rgb(136, 14, 79)]);

subjects = {'C1', 'P2', 'P3'};
for ss = 1:3

    subjectID = subjects{ss};
    switch subjectID
        case 'C1'
            arrayInfo = UC_chan_mapper('FullMapLatMed.txt');
        case 'P2'
            arrayInfo = Pitt_chan_mapper_P2('FullMapLatMed.txt');
        case 'P3'
            arrayInfo = Pitt_chan_mapper_P3('FullMapLatMed.txt');
    end
    
    load([sprintf('TrainData_100Hz_%s_Unsorted.mat', subjectID)]);
    
    % Sparseness
    numSE = sum(sm.isModulated, 2);
    propSE = numSE / length(sm.stimElectrode);
    hmap = createHeatmapMatrix(propSE, sm.motorChannel, 'motor', arrayInfo);

    axes(fig2.seCDF(ss))
    hmap.lateral([1 1 10 10], [1 10 1 10]) = 0;
     if strcmpi(subjectID, 'C1')
        rotHmap = imrotate(hmap.lateral, 90);
    elseif strcmpi(subjectID, 'P2')
        rotHmap = imrotate(hmap.lateral, 270);
     else
        rotHmap = imrotate(hmap.lateral, 270);
    end
    generateHeatmap(rotHmap, 'cmap', hmapColors, 'plotOutline', 1, 'clim', [0 .7]);
    axis square
    axis on
    title(sprintf('%s', subjectID), 'FontWeight', 'normal')
    set(gca, 'Color', rgb(176, 190, 197), 'FontSize', 7)
    plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', 3.4, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', fig2.seCDF(ss))

    % Modulation Value
    meanModValueMC = mean(abs(sm.modValue), 2);
    axes(fig2.modValue)
    SymphonicBeeSwarm(ss, meanModValueMC, subjectColors(ss, :), 3, 'CenterMethod', 'median', 'CenterColor', subjectColors(ss, :), 'CenterWidth', .1,...
        'DistributionMethod', 'KernelDensity', 'BackgroundType', 'violin',  'BackgroundWidth', .3, 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', .5, 'MarkerEdgeAlpha', .5, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 50)    
    hold on
    box off
end

axes(fig2.seCDF(2))
cbar = colorbar;
cbar.Location = 'southoutside';
cbar.Position = [.275 .125, .175, .07];
cbar.Ticks = [];
ylabel(cbar, 'p(Stimulating Channels)', 'Position', [0.35 -0.1 0]);
cbar.FontSize = 7;
text(-0.5, 5.5, 'Lateral Motor', 'Rotation', 90, 'FontSize', 6.5, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'Parent', fig2.seCDF(1))

fig2.modValue.YTick = 0:2:10;
fig2.modValue.YLim = [0 10];
ylabel('Avg. |Modulation|', 'Position', [-1, 5, -1], 'Parent', fig2.modValue);
fig2.modValue.XLim = [0 4];
fig2.modValue.XTick = 1:3;
fig2.modValue.XTickLabel = subjects;
fig2.modValue.FontSize = 7;
