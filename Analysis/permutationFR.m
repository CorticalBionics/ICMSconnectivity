function fr = permutationFR(spikeData, stimInfo, dur, sortedSpikes)

blankingInterval = .002; % (sec) duration of the stimulation pulse + blanking period

if sortedSpikes
    unitIds = spikeData.unitIds;
else
    unitIds = 0;
end

% Stim Train Information
numTrains = stimInfo.train.numTrains;
stimTrainStarts = cellfun(@(z) z(1), stimInfo.train.time);
stimTrainEnds = cellfun(@(z) z(end), stimInfo.train.time);

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
        stimPulses = 0:interpulseTime:dur;
        stimBlank = stimPulses + blankingInterval;
        stimOverlay = sort([stimPulses, stimBlank]);
        if mod(length(stimOverlay) - 1, 2) == 0
            stimMask = logical(repmat([0, 1], [1, (length(stimOverlay) - 1) / 2]));
        else
            stimMask = logical(repmat([0, 1], [1, length(stimOverlay) / 2]));
            stimMask = stimMask(1:end - 1);
        end

        % Find which spikes occur in the two seconds post stimulation train
        % and break them up into 1 second bins
        preTrainTime = stimTrainStarts(st);
        pre1SpikesIdx = spikeTimes > (preTrainTime - 2 * dur) & spikeTimes < (preTrainTime - dur);
        pre2SpikesIdx = spikeTimes > (preTrainTime - dur) & spikeTimes < (preTrainTime);

        pre1Spikes = spikeTimes(pre1SpikesIdx) - (preTrainTime - 2 * dur);
        pre2Spikes = spikeTimes(pre2SpikesIdx) - (preTrainTime - dur);

        postTrainTime = stimTrainEnds(st) + blankingInterval;
        post1SpikesIdx = spikeTimes > postTrainTime & spikeTimes < (postTrainTime + dur);
        post2SpikesIdx = spikeTimes > (postTrainTime + dur) & spikeTimes < (postTrainTime + 2 * dur);

        post1Spikes = spikeTimes(post1SpikesIdx) - (postTrainTime);
        post2Spikes = spikeTimes(post2SpikesIdx) - (postTrainTime + dur);

        fr.trainIdx(trainCont) = st;
        fr.unitIdx(trainCont) = uu;

        % PreTrain 1 1 Counts
        stimCounts = histcounts(pre1Spikes, stimOverlay);
        stimCounts = stimCounts(stimMask);
        stimTime = diff(stimOverlay);
        fr.pre1_mean(trainCont) = sum(stimCounts) / sum(stimTime(stimMask));
        fr.pre1_std(trainCont) = std(stimCounts / (interpulseTime - blankingInterval));

        % PreTrain 2 Counts
        stimCounts = histcounts(pre2Spikes, stimOverlay);
        stimCounts = stimCounts(stimMask);
        stimTime = diff(stimOverlay);
        fr.pre2_mean(trainCont) = sum(stimCounts) / sum(stimTime(stimMask));
        fr.pre2_std(trainCont) = std(stimCounts / (interpulseTime - blankingInterval));

        % Interval 1 Counts
        stimCounts = histcounts(post1Spikes, stimOverlay);
        stimCounts = stimCounts(stimMask);
        stimTime = diff(stimOverlay);
        fr.post1_mean(trainCont) = sum(stimCounts) / sum(stimTime(stimMask));
        fr.post1_std(trainCont) = std(stimCounts / (interpulseTime - blankingInterval));

        % Interval 2 Counts
        stimCounts = histcounts(post2Spikes, stimOverlay);
        stimCounts = stimCounts(stimMask);
        stimTime = diff(stimOverlay);
        fr.post2_mean(trainCont) = sum(stimCounts) / sum(stimTime(stimMask));
        fr.post2_std(trainCont) = std(stimCounts / (interpulseTime - blankingInterval));

        trainCont = trainCont + 1;
    end % stim period loop
end % unit loop

end