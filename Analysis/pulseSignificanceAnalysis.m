clear; clc;
subjectID = 'P3';
sessionDate = 20230831;
stimElectrode = [2:30, 32:61, 63,64];
motorChannel = [1:64, 97:192, 225:256]; 
freqId = 100;
numData = length(motorChannel);
sortedSpikes = 0;
saveData = 1;

% PTA Folds
numFolds = 10;

dataFolder = sprintf('/%i/', sessionDate);


%% Analysis Start
sm.subjectID = subjectID;
sm.motorChannel = motorChannel;
sm.stimElectrode = stimElectrode;

cont = 1;
disp('Performing permutation analysis...')
reverseStr = '';
for mc = 2:length(motorChannel)
    mcId = motorChannel(mc);

    if sortedSpikes
        %         load(sprintf('Processed Raw Files/%i/Snippets/MC%i_Snippets_%i.mat', sessionDate, mcId, sessionDate))
        %         validUnits = unique(snippetData.unit);
        %         validUnits = validUnits(validUnits > 0);
        %         validUnits = goodUnits.units(goodUnits.motorChannel == mcId);
        validUnits = 1;
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
        msg = sprintf('    Running motor channel: %i/%i\n', cont, numData);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));

        amp = unique(allSmData.data(1).pulse.indv.ampIdx);
        for aa = 1:numel(amp)
            for se = 1:length(stimElectrode)
                seId = stimElectrode(se);

                seIdx = allSmData.stimElectrode == seId;

                if all(seIdx == 0)
                    continue;
                end

                smData = allSmData.data(seIdx);

                if sortedSpikes
                    unitPulseIdx = smData.pulse.indv.unitIdx == uu;
                    bsTrainIdx = smData.baseline.info.unitIdx == uu;
                else
                    unitPulseIdx = smData.pulse.indv.unitIdx >= 0;
                    bsTrainIdx = smData.baseline.info.unitIdx >= 0;
                end

                ampIdx = smData.pulse.indv.ampIdx == amp(aa);
                ptaIdx = find(unitPulseIdx & ampIdx);

                sm.mcIdx(cont, se) = mcId;
                sm.seIdx(cont, se) = seId;
                sm.unitIdx(cont, se) = uu;
                sm.ampIdx (cont, se) = amp(aa);

                % PTA Time Vector and Vector Indices
                ptaTimeVec = smData.pulse.pta.timeVec{1};
                validTimeIdx = smData.pulse.pta.timeVec{1} > 2;
                validTimeIdx = validTimeIdx(1:end - 1); % get rid of last time bin
                ptaTimeVec = ptaTimeVec(validTimeIdx);
                sm.ptaTimeVec = ptaTimeVec;

                % Compute the baseline and actual stim PTA
                numPTAs = size(smData.pulse.indv.pta(ptaIdx, :), 1);
                numPTAs = numPTAs - mod(numPTAs, numFolds);

                indvPTAs = smData.pulse.indv.pta(ptaIdx, validTimeIdx);
                baselinePTAs = cell2mat(smData.baseline.pulse.pta.count(bsTrainIdx)');
                baselinePTAs = baselinePTAs(:, validTimeIdx);

                foldIdx = randperm(numPTAs);
                foldIdx = reshape(foldIdx, [length(foldIdx) / numFolds, numFolds]);

                tmpPTA = zeros(numFolds, length(ptaTimeVec));
                tmpBaselinePTA = zeros(numFolds, length(ptaTimeVec));
                for ff = 1:size(foldIdx, 2)
                    tmpPTA(ff, :) = mean(indvPTAs(foldIdx(:, ff), :), 'omitnan');
                    tmpBaselinePTA(ff, :) = mean(baselinePTAs(foldIdx(:, ff), :), 'omitnan');
                end

                sm.pulse.indvPTA(cont, se, :, :) = tmpPTA;
                sm.pulse.avgPTA(cont, se, :) = mean(tmpPTA, 1, 'omitnan');
                sm.pulse.baselinePTA(cont, se, :, :) = tmpBaselinePTA;

                % Find the maximum deviation from baseline for the PTAs
                [maxValue, maxIdx] = max(sm.pulse.avgPTA(cont, se, :));
                sm.pulse.peakTime(cont, se) = ptaTimeVec(maxIdx);
                sm.pulse.maxProbSpike(cont, se) = maxValue;


                if maxIdx ~= 1 && maxIdx ~= length(ptaTimeVec)
                    sm.pulse.probSpike(cont, se) = mean(sm.pulse.avgPTA(cont, se, maxIdx - 1:maxIdx + 1), 'omitnan');
                    tmp = sum(indvPTAs(:, maxIdx - 1:maxIdx + 1), 2);
                elseif maxIdx == 1
                    sm.pulse.probSpike(cont, se) = mean(sm.pulse.avgPTA(cont, se, maxIdx:maxIdx + 1), 'omitnan');
                    tmp = sum(indvPTAs(:,  maxIdx:maxIdx + 1), 2);
                else
                    sm.pulse.probSpike(cont, se) = mean(sm.pulse.avgPTA(cont, se, maxIdx - 1:maxIdx), 'omitnan');
                    tmp = sum(indvPTAs(:, maxIdx - 1:maxIdx), 2);
                end

                sm.pulse.pSpikeAny(cont, se) = mean(tmp);
                numTrains = length(ptaIdx) / freqId;
                sm.pulse.pSpikePulse(cont, se, :) = mean(reshape(tmp, [freqId, numTrains])');

                % Find a second peak (if any)
                [peakValues, peakTimeValues] = findpeaks(squeeze(sm.pulse.avgPTA(cont, se, :))', ptaTimeVec);
                [~, idx] = sort(peakValues);
                if length(peakValues) > 1
                    sm.pulse.probSecondPeak(cont, se) = peakValues(idx(end - 1));
                    sm.pulse.secondPeakTime(cont, se) = peakTimeValues(idx(end - 1));
                else
                    sm.pulse.probSecondPeak(cont, se) = 0;
                    sm.pulse.secondPeakTime(cont, se) = NaN;
                end

                % Ratio Tests
                sm.pulse.medianProbSpike(cont, se) = median(squeeze(sm.pulse.avgPTA(cont, se, :)));
                sm.pulse.ratio(cont, se) = sm.pulse.probSpike(cont, se) - sm.pulse.medianProbSpike(cont, se);
                sm.pulse.secondPeakRatio(cont, se) = sm.pulse.probSecondPeak(cont, se) - sm.pulse.medianProbSpike(cont, se);

                %% Significance Testing
                numSpikes = cellfun(@length, smData.pulse.indv.spikeTimes(ptaIdx));
                numDraws = numPTAs * 0.2; % of the data
                numReps = 5000;

                [nullRatioDist_Avg, nullRatioDist_Max, peakTimeDist, secondPeakTimeDist, secondPeakRatioDist] = deal(zeros(1, numReps));

                if numDraws ~= 0
                    for rr = 1:numReps
                        permIdx = randperm(numPTAs);
                        permIdx = permIdx(1:numDraws);

                        shuffledPTA = zeros(numDraws, length(ptaTimeVec));
                        for dd = 1:numDraws
                            if ~isempty(numSpikes(permIdx(dd)))
                                idx = randperm(length(ptaTimeVec), numSpikes(permIdx(dd)));
                                shuffledPTA(dd, idx) = 1;
                            end
                        end

                        % Get the peak of the PTA
                        meanShuffledPTA = mean(shuffledPTA);
                        [maxProbSpike, maxIdx] = max(meanShuffledPTA);
                        if maxIdx ~= 1 && maxIdx ~= length(ptaTimeVec)
                            avgProbSpike = mean(meanShuffledPTA(maxIdx - 1:maxIdx + 1));
                        elseif maxIdx == 1
                            avgProbSpike = mean(meanShuffledPTA(maxIdx:maxIdx + 1));
                        else
                            avgProbSpike = mean(meanShuffledPTA(maxIdx - 1:maxIdx));
                        end

                        medianProbSpike = median(meanShuffledPTA);

                        % Ratio
                        nullRatioDist_Avg(rr) = avgProbSpike - medianProbSpike;
                        nullRatioDist_Max(rr) = maxProbSpike - medianProbSpike;

                        % Second Peak values
                        [peakValues, peakValueTimes] = findpeaks(meanShuffledPTA, ptaTimeVec);
                        [~, idx] = sort(peakValues);
                        if length(peakValues) > 1
                            secondPeakRatioDist(rr) = peakValues(idx(end - 1)) - medianProbSpike;
                        end


                        % Peak Time Jitter
                        tmpPTA = mean(indvPTAs(permIdx, :), 'omitnan');
                        [maxValue, maxIdx] = max(tmpPTA);
                        peakTimeDist(rr) = ptaTimeVec(maxIdx);

                        [peakValues, peakValueTimes] = findpeaks(tmpPTA, ptaTimeVec);
                        [~, idx] = sort(peakValues);
                        if length(peakValues) > 1
                            secondPeakTimeDist(rr) = peakValueTimes(idx(end - 1));
                        end
                    end

                    rightTail = 1 - (sum(sm.pulse.ratio(cont, se) > nullRatioDist_Avg) / numReps);
                    sm.pulse.p(cont, se) = rightTail;
                    sm.pulse.isModulated(cont, se) = sm.pulse.p(cont, se) <= 0.01;

                    rightTail = 1 - (sum(sm.pulse.ratio(cont, se) > nullRatioDist_Max) / numReps);
                    sm.pulse.p_Max(cont, se) = rightTail;
                    sm.pulse.isModulated_Max(cont, se) = sm.pulse.p_Max(cont, se) <= 0.01;

                    rightTail = 1 - (sum(sm.pulse.secondPeakRatio(cont, se) > secondPeakRatioDist) / numReps);
                    sm.pulse.p_SecondPeak(cont, se) = rightTail;
                    sm.pulse.isModulated_SecondPeak(cont, se) = sm.pulse.p_SecondPeak(cont, se) <= 0.01;

                    sm.pulse.peakTimeJitter(cont, se) = var(peakTimeDist);
                    sm.pulse.peakLatency(cont, se) = mean(peakTimeDist);
                    sm.pulse.secondPeakTimeJitter(cont, se) = var(secondPeakTimeDist);
                    sm.pulse.secondPeakLatency(cont, se) = mean(secondPeakTimeDist);

                end
            end % stim channel loop
            cont = cont + 1;

        end % amp loop
    end % unit loop
end % motor channel loop


if saveData
    % Saving Data
    if sortedSpikes
        saveDataFilename = sprintf('PulseData_%iHz_%s_Sorted', freqId, subjectID);
    else
        saveDataFilename = sprintf('PulseData_%iHz_%s_Unsorted', freqId, subjectID);
    end
    save([dataFolder, saveDataFilename], 'sm', '-v7.3')
end

