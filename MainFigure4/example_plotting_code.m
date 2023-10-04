close all; clear; clc;

fig4.fig = figure();
set(fig4.fig, 'Units', 'centimeters', 'Position', [40 10 8.8 12.5], 'NumberTitle', 'off');

fig4.motor(1) = axes('Position', [.05 .525 .4 .25]); fig4.motor(2) = axes('Position', [.475 .525 .4 .25]);
fig4.sensory(1) = axes('Position', [.05 .01 .4 .25]); fig4.sensory(2) = axes('Position', [.475 .01 .4 .25]);

% Array Images
stimColor = [139 193 69] ./ 255;
medialColor = [255 0 102] ./ 255;
lateralColor = [241 157 25] ./ 255;

load('C1SomatotopyData.mat');
% Motor cmap
cMinMotor = -1;
cMaxMotor = 1;
propHigh = cMaxMotor / (abs(cMaxMotor) + abs(cMinMotor));
propLow = 1 - propHigh;
motorColors = cmap_gradient([rgb(25, 118, 210); rgb(250, 250, 250); rgb(194, 24, 91)], [propLow, propHigh]);

% Sensory cmap
[cMinSensory, cMaxSensory] = getLimits(smData.pf.hmap(:), 1);
cMinSensory = -5;
propHigh = cMaxSensory / (abs(cMaxSensory) + abs(cMinSensory));
propLow = 1 - propHigh;
sensoryColors = cmap_gradient([rgb(25, 118, 210); rgb(250, 250, 250); rgb(194, 24, 91)], [propLow, propHigh]);

digitOfInterest = [1, 4]; % Thumb, ring
fingerNames = {'Thumb', 'Ring'};
for dd = 1:length(digitOfInterest)
    axes(fig4.motor(dd))
    rotHmap = imrotate(squeeze(smData.rf.hmap(digitOfInterest(dd), :, :)), 90);
    ml(dd) = generateHeatmap(rotHmap, 'cmap', motorColors, 'plotOutline', 1, 'cLim', [cMinMotor, cMaxMotor]);
    axis square
    fig4.motor(dd).Colormap = motorColors;
    plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', 7, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', fig4.motor(dd))

    axes(fig4.sensory(dd))
    rotHmap = imrotate(squeeze(smData.pf.hmap(digitOfInterest(dd), :, :)), 90);
    ms(dd) = generateHeatmap(rotHmap, 'cmap', sensoryColors, 'plotOutline', 1, 'cLim', [cMinSensory, cMaxSensory]);
    axis square
    fig4.sensory(dd).Colormap = sensoryColors;
    plot(10, 1, 's', 'Color', [139, 193, 69] ./ 255, 'MarkerSize', 7, 'MarkerFaceColor', [139, 193, 69] ./ 255, 'Parent', fig4.sensory(dd))
end

fig4.motor(1).Colormap = motorColors; fig4.motor(2).Colormap = motorColors;
fig4.sensory(1).Colormap = sensoryColors; fig4.sensory(2).Colormap = sensoryColors;

fig4.medial(1).Colormap = [rgb(224, 224, 224); medialColor];
fig4.medial(2).Colormap = [rgb(224, 224, 224); stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; medialColor];
fig4.lateral(1).Colormap = [rgb(224, 224, 224); stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; stimColor; lateralColor];
fig4.lateral(2).Colormap = [rgb(224, 224, 224); lateralColor];

text(-.25, 5.5, 'Motor Movement', 'Parent', fig4.motor(1), 'FontSize', 7, 'Rotation', 90, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(-.25, 5.5, 'Sensory Projection', 'Parent', fig4.sensory(1), 'FontSize', 7, 'Rotation', 90, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

% Motor Colorbar
axes(fig4.motor(2))
cbarMotor = colorbar;
cbarMotor.Colormap = motorColors;
cbarMotor.Limits = [cMinMotor, cMaxMotor];
cbarMotor.Ticks = cMinMotor:1:cMaxMotor;
cbarMotor.Location = 'eastoutside';
cbarMotor.Position = [.875, .55, .035, .2];
cbarMotor.FontSize = 7;
yl = ylabel(cbarMotor, 'Motor Modulation', 'Rotation', 270);
yl.Position(1) = 3.5;
yl.FontSize = 7;

% Sensory Colorbar
axes(fig4.sensory(2))
cbarSensory = colorbar;
cbarSensory.Colormap = sensoryColors;
cbarSensory.Limits = [cMinSensory, cMaxSensory];
cbarSensory.Ticks = cMinSensory:5:cMaxSensory;
cbarSensory.Location = 'eastoutside';
cbarSensory.Position = [.875, .035, .035, .2]; 
cbarSensory.FontSize = 7;
ylabel(cbarSensory, 'Stim Modulation', 'Position', [3.5 5 0], 'FontSize', 7, 'Rotation', 270)
