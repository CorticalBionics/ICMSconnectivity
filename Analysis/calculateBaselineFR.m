function fr = calculateBaselineFR(spikeData, stimInfo, baselineDur, dt, sortedSpikes)

blankingInterval = .002; % (sec) duration of the stimulation pulse + blanking period
prePTA = -0.005;

if sortedSpikes
    unitIds = spikeData.unitIds;
else
    unitIds = 0;
end

% Stim Train Information
numTrains = stimInfo.train.numTrains;
stimTrainStarts = cellfun(@(z) z(1), stimInfo.train.time);

trainCont = 1;
for uu = unitIds
    if sortedSpikes
        spikesIdx = find(spikeData.unit == uu);
    else
        spikesIdx = find(spikeData.unit >= uu);
    end
    spikeTimes = spikeData.time(spikesIdx);

    for st = 1:numTrains
        % Generate pulse times and stim mask
        interpulseTime = 1 / stimInfo.train.freq(st);
        stimPulses = 0:interpulseTime:baselineDur;
        stimBlank = stimPulses + blankingInterval;
        stimOverlay = sort([stimPulses, stimBlank]);
        if mod(length(stimOverlay) - 1, 2) == 0
            stimMask = logical(repmat([0, 1], [1, (length(stimOverlay) - 1) / 2]));
        else
            stimMask = logical(repmat([0, 1], [1, length(stimOverlay) / 2]));
            stimMask = stimMask(1:end - 1);
        end

        % Generate PTA Time Vecs
        numPulses = stimInfo.train.freq(st);
        pulseEdges = prePTA:dt:interpulseTime;
        ptaTimeVec = round((pulseEdges(2:end) - (dt / 2)) * 1000, 2);
        % The indices and timestamps of the blanking interval
        blankingIdx = find(ptaTimeVec > 0 & ptaTimeVec < (blankingInterval * 1000));

        % Generate Binostat Time Vecs
        binostatTimeVec = 0:dt:baselineDur;
        binostatOverlay = [zeros(1, blankingInterval / dt), ones(1, (interpulseTime - blankingInterval) / dt)];
        if mod(length(binostatTimeVec) - 1, length(binostatOverlay)) == 0
            binostatMask = logical(repmat(binostatOverlay, [1, (length(binostatTimeVec) - 1) / length(binostatOverlay)]));
        else
            binostatMask = logical(repmat(binostatOverlay, [1, (length(binostatTimeVec)) / length(binostatOverlay)]));
            binostatMask = stimMask(1:end - 1);
        end

        % Find which spikes occur in the baseline interval and get their
        % timestamps
        preTrainTime = stimTrainStarts(st) - 1; %stimTrainStarts(st) - paddingWindow;
        preTrainSpikesIdx = spikeTimes > preTrainTime & spikeTimes < stimTrainStarts(st);
        preTrainSpikes = spikeTimes(preTrainSpikesIdx) - preTrainTime;
        baselineSpikes = preTrainSpikes;

        fr.info.trainIdx(trainCont) = st;
        fr.info.unitIdx(trainCont) = uu;

        % Baseline Calculation: PTA Method
        ptaCounts = zeros(numPulses, length(pulseEdges) - 1);
        for sp = 1:numPulses
            tmp = histcounts(baselineSpikes, pulseEdges + stimPulses(sp));
            pta = tmp; % / dt;
            pta(blankingIdx) = NaN;
            pta = smoothdata(pta, 'Gaussian', 5, 'omitnan'); % 5 ms smoothing window centered at current data point
            pta(blankingIdx) = NaN;
            ptaCounts(sp, :) = pta;
        end
        fr.pulse.pta.count{trainCont} = ptaCounts;
        fr.pulse.pta.mean(trainCont, :) = mean(ptaCounts);
        fr.pulse.pta.std(trainCont, :) = std(ptaCounts);
        clear ptaCounts

        % Binostat PTAs
        pulseCounts = histcounts(baselineSpikes, binostatTimeVec);
        pulseCounts = pulseCounts(binostatMask);
        [fr.pulse.mean(trainCont), fr.pulse.var(trainCont)] = binostat(2000, mean(pulseCounts));
        fr.pulse.std(trainCont)= sqrt(fr.pulse.var(trainCont));
        fr.pulse.count(trainCont, :) = pulseCounts;

        % Baseline Calculation: Stim FR
        stimCounts = histcounts(baselineSpikes, stimOverlay);
        stimCounts = stimCounts(stimMask);
        stimTime = diff(stimOverlay);
        fr.train.mean(trainCont) = sum(stimCounts) / sum(stimTime(stimMask));
        fr.train.std(trainCont) = std(stimCounts / (interpulseTime - blankingInterval));

        % Baseline Calculation: PSTH
        fr.train.indv_psth(trainCont, :) = histcounts(baselineSpikes, .1:.02:.9);

        trainCont = trainCont + 1;
        clear ptaCounts pulseCounts
    end % stim period loop

    % Pulse PTA
    if sortedSpikes
        unitIdx = fr.info.unitIdx == uu;
        fr.pulse.pta.avg(uu, :) = mean(fr.pulse.pta.mean(unitIdx, :));
        nanIdx = find(isnan(fr.pulse.pta.avg(uu, :)), 1, 'last') + 1;
        fr.pulse.ptaVar(uu) = var(fr.pulse.pta.avg(uu, nanIdx:end));

        % Train PSTH
        fr.train.psth(uu, :) = mean(fr.train.indv_psth(unitIdx, :));
        fr.train.psthVar(uu) = var(fr.train.psth(uu, :));
    else
        fr.pulse.pta.avg = mean(fr.pulse.pta.mean);
        nanIdx = find(isnan(fr.pulse.pta.avg), 1, 'last') + 1;
        fr.pulse.ptaVar = var(fr.pulse.pta.avg(nanIdx:end));

        % Train PSTH
        fr.train.psth = mean(fr.train.indv_psth);
        fr.train.psthVar = var(fr.train.psth);

    end
end % unit loop

end