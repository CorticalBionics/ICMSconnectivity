clear;

subjectID = 'C1';
load(sprintf('TrainData_100Hz_%s_Unsorted.mat', subjectID));

if ~isempty(subjectID)
    switch subjectID
        case 'C1'
            arrayInfo = UC_chan_mapper('FullMapLatMed.txt');
        case 'P2'
            arrayInfo = Pitt_chan_mapper_CRS02b('FullMapLatMed.txt');
        case 'P3'
            arrayInfo = Pitt_chan_mapper_CRS07('FullMapLatMed.txt');
    end
end

filtSize = 1;
% Calculate the distance and correlation matrices
cont = 1;
for s1 = 1:63
    if ismember(s1, sm.stimElectrode)
        s1Idx = find(sm.stimElectrode == s1);
        if any(sm.isModulated(:, s1Idx))
            tmpLoc = getChannelInfo(s1, 'stim', arrayInfo);
            s1Row = tmpLoc.hmapRow;
            s1Col = tmpLoc.hmapCol;
            s1Array = tmpLoc.array;

            modValues = sm.modValue(:, s1Idx);
            modChannels = sm.motorChannel;

            hmap = createHeatmapMatrix(modValues, modChannels, 'motor', arrayInfo);
            tmp = hmap.medial;
            tmp(isnan(tmp)) = 0;
            tmp = imgaussfilt(tmp, filtSize);
            tmp([1, 1, end, end], [1, end, 1, end]) = NaN;
            s1MedialHmap = tmp;

            tmp = hmap.lateral;
            tmp(isnan(tmp)) = 0;
            tmp = imgaussfilt(tmp, filtSize);
            tmp([1, 1, end, end], [1, end, 1, end]) = NaN;
            s1LateralHmap = tmp;

            for s2 = (s1 + 1):64
                if ismember(s2, sm.stimElectrode)
                    s2Idx = find(sm.stimElectrode == s2);
                    if any(sm.isModulated(:, s2Idx))
                        tmpLoc = getChannelInfo(s2, 'stim', arrayInfo);
                        s2Row = tmpLoc.hmapRow;
                        s2Col = tmpLoc.hmapCol;
                        s2Array = tmpLoc.array;

                        modValues = sm.modValue(:, s2Idx); 
                        modChannels = sm.motorChannel;

                        hmap = createHeatmapMatrix(modValues, modChannels, 'motor', arrayInfo);
                        tmp = hmap.medial;
                        tmp(isnan(tmp)) = 0;
                        tmp = imgaussfilt(tmp, filtSize);
                        tmp([1, 1, end, end], [1, end, 1, end]) = NaN;
                        s2MedialHmap = tmp;

                        tmp = hmap.lateral;
                        tmp(isnan(tmp)) = 0;
                        tmp = imgaussfilt(tmp, filtSize);
                        tmp([1, 1, end, end], [1, end, 1, end]) = NaN;
                        s2LateralHmap = tmp;

                        % Actual Analysis
                        distData.s1.seId(cont) = s1;
                        distData.s1.row(cont) = s1Row;
                        distData.s1.col(cont) = s1Col;
                        distData.s1.array(cont) = s1Array;
                        
                        distData.s2.seId(cont) = s2;
                        distData.s2.row(cont) = s2Row;
                        distData.s2.col(cont) = s2Col;
                        distData.s2.array(cont) = s2Array;

                        distData.s1ArrayIdx(cont) = s1Array;
                        distData.s2ArrayIdx(cont) = s2Array;
                        distData.channelDist(cont) = sqrt((s1Row - s2Row)^2 + (s1Col - s2Col)^2);

                        tmp = corr([reshape(s1MedialHmap, [100, 1]), reshape(s2MedialHmap, [100, 1])], 'rows', 'complete');
                        distData.medialMotor.corr(cont) = tmp(1,2);

                        tmp = corr([reshape(s1LateralHmap, [100, 1]), reshape(s2LateralHmap, [100, 1])], 'rows', 'pairwise');
                        distData.lateralMotor.corr(cont) = tmp(1,2);

                        cont = cont + 1;
                    end % only if s2 modulates some channels
                end % ismember s2
            end % s2 loop
        end % only if s1 modulates some channels
    end % ismember s1
end % s1 loop

%% Within array correlations

withinArrayIdx = distData.s1ArrayIdx == distData.s2ArrayIdx;
medialSensoryArrayIdx = find(withinArrayIdx & distData.s1ArrayIdx == 2);
lateralSensoryArrayIdx = find(withinArrayIdx & distData.s1ArrayIdx == 4);

[fMedial, xMedial] = ecdf(distData.channelDist(medialSensoryArrayIdx));
[~, ~, fMedialIdx] = histcounts(fMedial, 0:.2:1);
distValuesMedial(1) = 1;
for ff = 1:4
    xLowerLim = xMedial(find(fMedialIdx == ff, 1, 'last'));
    xUpperLim = xMedial(find(fMedialIdx == ff + 1, 1, 'first'));
    distValuesMedial(ff + 1) = mean([xLowerLim, xUpperLim]);
end
distValuesMedial(end + 1) = 11;
[distCountsMedial, ~, medialDistId] = histcounts(distData.channelDist(medialSensoryArrayIdx), distValuesMedial);
distData.medialMotor.medialSensoryBin = NaN(max(distCountsMedial), length(distValuesMedial) - 1); % med motor, med sensory
distData.lateralMotor.medialSensoryBin = NaN(max(distCountsMedial), length(distValuesMedial) - 1); % lat motor, med sensory

% [fLateral, xLateral] = ecdf(distData.channelDist(withinArrayIdx & lateralArrayIdx));
% [~, ~, fLateralIdx] = histcounts(fLateral, 0:.2:1);
% distValuesLateral(1) = 1;
% for ff = 1:4
%     xLowerLim = xLateral(find(fLateralIdx == ff, 1, 'last'));
%     xUpperLim = xLateral(find(fLateralIdx == ff + 1, 1, 'first'));
%     distValuesLateral(ff + 1) = mean([xLowerLim, xUpperLim]);
% end
% distValuesLateral(end + 1) = 11;
[distCountsLateral, ~, lateralDistId] = histcounts(distData.channelDist(lateralSensoryArrayIdx), distValuesMedial);

distData.medialMotor.lateralSensoryBin = NaN(max(distCountsLateral), length(distValuesMedial) - 1); % med motor, lat sensory
distData.lateralMotor.lateralSensoryBin = NaN(max(distCountsLateral), length(distValuesMedial) - 1); % lat motor, lat sensory

for dd = 1:length(distValuesMedial) - 1

    % Medial Stim
    distIdx = medialDistId == dd;
    distData.medialMotor.medialSensoryBin(1:sum(distIdx), dd) = distData.medialMotor.corr(medialSensoryArrayIdx(distIdx));
    distData.lateralMotor.medialSensoryBin(1:sum(distIdx), dd) = distData.lateralMotor.corr(medialSensoryArrayIdx(distIdx));

    % Lateral Stim
    distIdx = lateralDistId == dd;
    distData.medialMotor.lateralSensoryBin(1:sum(distIdx), dd) = distData.medialMotor.corr(lateralSensoryArrayIdx(distIdx));
    distData.lateralMotor.lateralSensoryBin(1:sum(distIdx), dd) = distData.lateralMotor.corr(lateralSensoryArrayIdx(distIdx));
end

distData.distValues = distValuesMedial;
distData.withinMedialSensoryIdx = medialSensoryArrayIdx;
distData.withinLateralSensoryIdx = lateralSensoryArrayIdx;


figure;
t = tiledlayout(2, 2, 'Padding', 'Compact', 'TileSpacing', 'Compact');

nexttile
scatter(distData.channelDist(medialSensoryArrayIdx), distData.medialMotor.corr(medialSensoryArrayIdx), 10, 'k', 'filled', 'MarkerFaceAlpha', .15)
hold on
AlphaLine(distValuesMedial(1:end-1) + diff(distValuesMedial) / 2, distData.medialMotor.medialSensoryBin, rgb(84, 110, 122), 'LineWidth', 1.5, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'STD');
xlabel('Stim Channel Distance'); ylabel('Correlation')
[r, p] = corrcoef(distData.channelDist(medialSensoryArrayIdx), distData.medialMotor.corr(medialSensoryArrayIdx));
title(sprintf('Medial Motor, Medial Sensory [r = %.2f, p = %.3f]', r(1,2), p(1,2)))

nexttile
scatter(distData.channelDist(lateralSensoryArrayIdx), distData.medialMotor.corr(lateralSensoryArrayIdx), 10, 'k', 'filled', 'MarkerFaceAlpha', .15)
hold on
AlphaLine(distValuesMedial(1:end-1) + diff(distValuesMedial) / 2, distData.medialMotor.lateralSensoryBin, rgb(84, 110, 122), 'LineWidth', 1.5, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'STD');
xlabel('Stim Channel Distance'); ylabel('Correlation')
[r, p] = corrcoef(distData.channelDist(lateralSensoryArrayIdx), distData.medialMotor.corr(lateralSensoryArrayIdx));
title(sprintf('Medial Motor, Lateral Sensory [r = %.2f, p = %.3f]', r(1,2), p(1,2)))

nexttile
scatter(distData.channelDist(medialSensoryArrayIdx), distData.lateralMotor.corr(medialSensoryArrayIdx), 10, 'k', 'filled', 'MarkerFaceAlpha', .15)
hold on
AlphaLine(distValuesMedial(1:end-1) + diff(distValuesMedial) / 2, distData.lateralMotor.medialSensoryBin, rgb(84, 110, 122), 'LineWidth', 1.5, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'STD');
xlabel('Stim Channel Distance'); ylabel('Correlation')
[r, p] = corrcoef(distData.channelDist(medialSensoryArrayIdx), distData.lateralMotor.corr(medialSensoryArrayIdx));
title(sprintf('Lateral Motor, Medial Sensory [r = %.2f, p = %.3f]', r(1,2), p(1,2)))

nexttile
scatter(distData.channelDist(lateralSensoryArrayIdx), distData.lateralMotor.corr(lateralSensoryArrayIdx), 10, 'k', 'filled', 'MarkerFaceAlpha', .15)
hold on
AlphaLine(distValuesMedial(1:end-1) + diff(distValuesMedial) / 2, distData.lateralMotor.lateralSensoryBin, rgb(84, 110, 122), 'LineWidth', 1.5, 'EdgeAlpha', 0.2, 'FaceAlpha', 0.2, 'ErrorType', 'STD');
xlabel('Stim Channel Distance'); ylabel('Correlation')
[r, p] = corrcoef(distData.channelDist(lateralSensoryArrayIdx), distData.lateralMotor.corr(lateralSensoryArrayIdx));
title(sprintf('Lateral Motor, Lateral Sensory [r = %.2f, p = %.3f]', r(1,2), p(1,2)))
