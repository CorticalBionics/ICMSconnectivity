clear; clc;
subjectID = 'CRS08';
sessionDate = 20230831;
stimElectrode = [2:30, 32:61, 63,64];
motorChannel = [1:64, 97:192, 225:256]; %[177, 236, 237, 253, 255];
freqId = 100;

sortedSpikes = 0;
saveData = 1;
plotFigures = 0;

% Permutation Params
alpha = 0.001;
numReps = 1000;
numDraws = 20;

% Baseline Folds
numFolds = 10;

dataFolder = sprintf('S:/UserFolders/NatalyaShelchkova/BCI/Data/Stim Modulation/%i/', sessionDate);

% Saving Data
saveDataType = 'Stim Modulation';
saveDataFolder = sprintf('S:/UserFolders/NatalyaShelchkova/BCI/Data/%s/%i/', saveDataType, sessionDate);
if sortedSpikes
    saveDataFilename = sprintf('TrainData_%iHz_%s_Sorted', freqId, subjectID);
else
    saveDataFilename = sprintf('TrainData_%iHz_%s_Unsorted', freqId, subjectID);
end

%% Analysis Start
sm.subjectID = subjectID;
sm.motorChannel = motorChannel;
sm.stimElectrode = stimElectrode;

cont = 1;
disp('Performing permutation analysis...')
reverseStr = '';
for mc = 1:length(motorChannel)
    msg = sprintf('    Loading MC: %i/%i\n', mc, length(motorChannel));
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));

    mcId = motorChannel(mc);

    if sortedSpikes
        %         load(sprintf('//BENSMAIA-LAB/LabSharing/Natalya/BCI/Data/Processed Raw Files/%i/Snippets/MC%i_Snippets_%i.mat', sessionDate, mcId, sessionDate))
        load(sprintf('S:/UserFolders/NatalyaShelchkova/BCI/Data/Processed Raw Files/%i/Snippets/MC%i_Snippets_%i.mat', sessionDate, mcId, sessionDate))
        validUnits = unique(snippetData.unit);
        validUnits = validUnits(validUnits > 0);
        %         validUnits = goodUnits.units(goodUnits.motorChannel == mcId);
        datafile = sprintf('MC%i_AllSE_%iHz_%i_Sorted.mat', mcId, freqId, sessionDate);
    else
        validUnits = 0;
        datafile = sprintf('MC%i_AllSE_%iHz_%i_Unsorted.mat', mcId, freqId, sessionDate);
    end

    % Load Data
    try
        load([dataFolder, datafile])
    catch
        continue;
    end

    for uu = validUnits

        amp = unique(allSmData.data(1).pulse.indv.ampIdx);
        for aa = 1:numel(amp)

            deltaNoStim = [];
            trainCont = 1;

            for se = 1:length(stimElectrode)
                seId = stimElectrode(se);

                seIdx = allSmData.stimElectrode == seId;
                if all(seIdx == 0)
                    continue;
                end
                smData = allSmData.data(seIdx);

                if sortedSpikes
                    smTrainIdx = smData.train.indv.unitIdx == uu;
                    permTrainIdx = smData.permutation.unitIdx == uu;
                    bsTrainIdx = smData.baseline.info.unitIdx == uu;
                else
                    smTrainIdx = smData.train.indv.unitIdx >= 0;
                    permTrainIdx = smData.permutation.unitIdx >= 0;
                    bsTrainIdx = smData.baseline.info.unitIdx >= 0;
                end

                numTrains = length(smData.train.indv.ampIdx(smTrainIdx));
                sm.mcIdx(cont, se) = mcId;
                sm.seIdx(cont, se) = seId;
                sm.unitIdx(cont, se) = uu;
                sm.ampIdx (cont, se) = amp(aa);

                % Get the delta FR values for the stim and non stim intervals
                sm.deltaStim.indv{cont, se} = smData.train.indv.stimFR(smTrainIdx) - smData.baseline.train.mean(bsTrainIdx);
                sm.deltaStim.mean(cont, se) = mean(smData.train.indv.stimFR(smTrainIdx) - smData.baseline.train.mean(bsTrainIdx));
                sm.stimFR(cont, se) = mean(smData.train.indv.stimFR(smTrainIdx));
                deltaNoStim(trainCont:trainCont + numTrains - 1) = smData.permutation.pre2_mean(permTrainIdx) - smData.permutation.pre1_mean(permTrainIdx);
                trainCont = trainCont + numTrains;
            end % stim channel loop

            % Now that we have the data for all electrodes, we can do the bootstrap
            % analysis
            for k = 1:numReps
                tmp = datasample(deltaNoStim, numTrains, 'Replace', true);
                sm.deltaNoStim.dist(cont, k) = mean(tmp);
            end
            sm.deltaNoStim.mean(cont) = mean(sm.deltaNoStim.dist(cont, :));
            sm.deltaNoStim.std(cont) = std(sm.deltaNoStim.dist(cont, :));

            % Let's see which stim channels modulated this motor channel
            for se = 1:length(stimElectrode)
                leftTail = 1 - sum(sm.deltaStim.mean(cont, se) < sm.deltaNoStim.dist(cont, :)) / numReps;
                rightTail = 1 - (sum(sm.deltaStim.mean(cont, se) > sm.deltaNoStim.dist(cont, :)) / numReps);
                sm.p(cont, se) = min([leftTail, rightTail]);
                sm.modValue(cont, se) = (sm.deltaStim.mean(cont, se)  - sm.deltaNoStim.mean(cont)) / sm.deltaNoStim.std(cont);
                sm.isModulated(cont, se) = sm.p(cont, se) <= alpha / 2;
            end
            cont = cont + 1;

        end % amp loop
    end % unit loop
end % motor channel loop

sm.isExcited = sm.isModulated & sm.modValue > 0;
sm.isInhibited = sm.isModulated & sm.modValue < 0;

if saveData
    save([dataFolder, saveDataFilename], 'sm', '-v7.3')
end

%% Figures
if plotFigures
    %% Train Summary
    figure('Units', 'Normalized', 'OuterPosition', [.4 .2 0.5 0.75], 'Color', 'w')
    t = tiledlayout(2, 2, 'Padding', 'Compact', 'TileSpacing', 'Compact');
    title(t, sprintf('%s - Trad Mod', subjectID), 'FontWeight', 'bold', 'FontSize', 15)

    % Proportion of modulated MCs by a single stim channel
    nexttile
    tmp = mean(sm.isModulated, 1);
    histogram(tmp, [-.005, 0.005], 'Normalization', 'probability', 'FaceColor', rgb('LightGrey'), 'EdgeColor', rgb('Grey'), 'LineWidth', 1, 'FaceAlpha', .5)
    hold on
    histogram(tmp, .01:.05:1, 'Normalization', 'probability', 'FaceColor', rgb('Grey'), 'EdgeColor', rgb('Grey'), 'LineWidth', 1, 'FaceAlpha', .5) %[0 112 192] / 255
    ylim([0 .6])
    stem(mean(tmp), .5, 'k:v', 'filled', 'LineWidth', 1.5, 'Color', rgb('LightGrey'))
    stem(mean(tmp(tmp > 0)), .35, 'k:v', 'filled', 'LineWidth', 1.5, 'Color', rgb('Grey'))
    ylabel('Proportion'); xlabel('Prop. of Motor Channels')
    box off
    set(gca, 'FontSize', 12, 'YTick', 0:.2:1)
    title('Modulation By Single Stim Channel')

    % Modulation type
    nexttile(2)
    propExcited = sum(sm.isExcited, 2) ./ sum(sm.isModulated, 2);
    propInhibited = sum(sm.isInhibited, 2) ./ sum(sm.isModulated, 2);
    SymphonicBeeSwarm(1, propExcited, rgb('MediumVioletRed'), 50, 'BackgroundType', 'bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0, 'CenterMethod', 'mean')
    hold on
    SymphonicBeeSwarm(2, propInhibited, rgb('DodgerBlue'), 50, 'BackgroundType', 'bar', 'BackgroundFaceAlpha', 0.1, 'BackgroundEdgeAlpha', 1,...
        'MarkerFaceAlpha', 1, 'MarkerEdgeAlpha', 1, 'BoxPercentiles', [1,40,60,99], 'MaxPoints', 0, 'CenterMethod', 'mean')
    ylabel('Proportion')
    set(gca, 'YLim', [0, 1], 'XTick', 1:2, 'XTickLabel', {'Excitation', 'Inhibition'}, 'FontSize', 12)
    title('Modulation Type')

    % Proportion of motor channels modulated by all stim channels
    numPerms = 1000;
    numSE = length(sm.stimElectrode);
    numMC = length(sm.motorChannel);
    for pp = 1:numPerms
        shuffledSE = randperm(numSE,numSE);
        for se = 1:numSE
            unsortedCDF(pp, se) = sum(sum(sm.isModulated(:, shuffledSE(1:se)), 2) >= 1);
        end
    end
    unsortedCDF = unsortedCDF ./ numMC;
    nexttile(3)
    hold on
    AlphaLine(linspace(0, 1, numSE), unsortedCDF, rgb('Grey'), 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'SEM', 'LineWidth', 1.5);
    box off
    text(.925, max(unsortedCDF(:)) + .04, sprintf('%.2f', max(unsortedCDF(:))), 'Color', rgb('Grey'), 'FontSize', 10)
    %     plot([0, 1], [max(unsortedCDF(:)), max(unsortedCDF(:))], ':', 'Color', rgb('Grey'), 'LineWidth', 1.5)
    xlabel('Prop. of SEs'); ylabel('Prop. of Modulated MCs')
    set(gca, 'FontSize', 12, 'YTick', 0:.1:1)
    title('Motor Channels Modulated By Stim')

    % Modulation Effect CDF
    % modValues = sort(abs(sm.modValue(:)));
    % modBins = 0:.25:5;
    % cdfMod = NaN(1, length(modBins));
    %
    % for mm = 1:length(modBins)
    %    cdfMod(mm) = sum(modValues <= modBins(mm));
    % end
    % cdfMod = cdfMod / length(modValues);

    % Modulation effect size
    nexttile(4)
    histogram(sm.modValue, 'BinEdges', -10:25, 'Normalization', 'probability', 'FaceColor', rgb('Grey'), 'EdgeColor', rgb('Grey'), 'LineWidth', 1, 'FaceAlpha', .5) %[0 112 192] / 255
    hold on
    bar(30, sum(sum(sm.modValue > 25)) / numel(sm.modValue(:)), 1, 'FaceColor', rgb('Grey'), 'EdgeColor', rgb('Grey'), 'LineWidth', 1, 'FaceAlpha', .5)
    xlabel('Modulation Value'); ylabel('Proportion')
    box off
    xlim([-10, 31])
    set(gca, 'FontSize', 12, 'XTick', -10:5:30, 'XTickLabel', [num2cell(-10:5:25), {'>25'}])
    title('Modulation Value')
    saveas(gcf, sprintf('./Figures/StimMod_%s.png', subjectID))

    %% Pulse Summary
    figure('Units', 'Normalized', 'OuterPosition', [.4 .2 0.5 0.4], 'Color', 'w')
    t = tiledlayout(1, 3, 'Padding', 'Compact', 'TileSpacing', 'Compact');
    title(t, sprintf('Subject: %s - 20Hz', subjectID), 'FontWeight', 'bold', 'FontSize', 15)

    % Bar: Num Motor Channels That Have Peaky PTAs
    pulseMod = sm.isModulated & sm.pulse.varRatio >= varThresh;
    propMod = sum((sum(pulseMod, 2) > 0)) ./ sum((sum(sm.isModulated, 2) > 0));
    nexttile
    bar(1, 1 - propMod, 'FaceColor', rgb('LightGrey'), 'FaceAlpha', .5)
    hold on
    bar(2, propMod, 'FaceColor', rgb('Grey'), 'FaceAlpha', .5)
    set(gca, 'XTick', [1,2], 'XTickLabel', {'Not Peaky', 'Peaky'}, 'FontSize', 12)
    ylabel('Proportion')
    box off
    title('Mod. MCs with Pulse Locked Activity')

    % Histogram: Prop SCs Causing Peaky PTAs
    nexttile
    varThresh = 100;
    pulseMod = sm.isModulated & sm.pulse.varRatio >= varThresh;
    histogram(mean(pulseMod, 2), [-.005, 0.005], 'Normalization', 'probability', 'FaceColor', rgb('LightGrey'), 'EdgeColor', rgb('Grey'), 'LineWidth', 1, 'FaceAlpha', .5)
    hold on
    histogram(mean(pulseMod, 2), .01:.05:1, 'Normalization', 'probability', 'FaceColor', rgb('Grey'), 'EdgeColor', rgb('Grey'), 'LineWidth', 1, 'FaceAlpha', .5) %[0 112 192] / 255
    ylim([0 .5])
    ylabel('Proportion'); xlabel('Prop. SCs')
    box off
    set(gca, 'FontSize', 12, 'YTick', 0:.2:1)
    title('Pulse Locked Effect Per MC')

    % Time Course
    nexttile
    histogram(sm.pulse.peakTime(pulseMod), 'BinEdges', 0:.5:10, 'Normalization', 'probability', 'FaceColor', rgb('Grey'), 'EdgeColor', rgb('Grey'), 'LineWidth', 1, 'FaceAlpha', .5)
    ylabel('Proportion'); xlabel('Latency [ms]')
    box off
    set(gca, 'FontSize', 12, 'YTick', 0:.2:1)
    title('Peak Time Course')

    saveas(gcf, sprintf('./Figures/PulseMod_%s.png', subjectID))

end
