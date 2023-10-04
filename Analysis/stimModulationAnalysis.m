clear; clc;

% Load specific files
subjectID = 'CRS08';
sessionDate = 20230831;
stimElectrode = 1:64;
motorChannel = [1:64, 97:192, 225:256];
freqId = 100;

sortSpikes = 0;
saveData = 1;
plotFigures = 0;
saveFigures = 0;
clearData = 1;

% Save Data Params
saveDataType = 'Stim Modulation';
saveDataFolder = sprintf('S:/UserFolders/NatalyaShelchkova/BCI/Data/%s/%i/', saveDataType, sessionDate);
fileSizeThresh = 5; % GB

% Data Params
dataFolder = sprintf('S:/UserFolders/NatalyaShelchkova/BCI/Data/Processed Raw Files/%i/StimMod/', sessionDate);

loadedData = zeros(length(stimElectrode), length(motorChannel));

for se = 1:size(stimElectrode, 2)
    for mc = 1:length(motorChannel)

        % Save Data filename
        if saveData
            seStr = strrep(num2str(stimElectrode(:,se)'), '  ', '+');
            if sortSpikes
                saveDataFilename = sprintf('SE%s_MC%i_%iHz_StimMod_%i_Sorted', seStr, motorChannel(mc), freqId, sessionDate);
            else
                saveDataFilename = sprintf('SE%s_MC%i_%iHz_StimMod_%i_Unsorted', seStr, motorChannel(mc), freqId, sessionDate);
            end
        end

        % Pulling Data
        datafile = sprintf('SE%i_MC%i_%iHz_Raw_%i.mat', stimElectrode(se), motorChannel(mc), freqId, sessionDate);
        fprintf('Loading SE %i MC %i\n', stimElectrode(se), motorChannel(mc));
        try
            load([dataFolder, datafile])
            if (isempty(smRaw.spike.unitIds) || all(smRaw.spike.unitIds == 0)) && sortSpikes
                continue
            elseif isempty(smRaw.spike.time)
                continue
            end
            loadedData(se, mc) = 1;
        catch
            continue
        end


        if sortSpikes
            numUnits = smRaw.spike.numUnits;
            unitIds = smRaw.spike.unitIds;
        else
            numUnits = 1;
            unitIds = 0;
        end

        %% Analysis Start
        smData.stimElectrode = stimElectrode(:, se);
        smData.motorChannel = motorChannel(mc);

        % Get the baseline firing rate in between stim trains
        paddingWindow = .2; % seconds
        baselineDur = 1; % seconds, on either side of train
        dt = .0005; % seconds

        smData.baseline = calculateBaselineFR(smRaw.spike, smRaw.stim, baselineDur, dt, sortSpikes);
        smData.permutation = permutationFR(smRaw.spike, smRaw.stim, 1, sortSpikes);

        %% Pulse Analysis
        % Params
        prePTA = -0.005; % 5ms prior
        postPTA = .005; % 5ms after start of next pulse
        dt = 0.0005; % used for stim pulse and stim train PTAs
        blankingInterval = 0.002; % seconds

        % Get the PTA time vector sorted
        freq = unique(smRaw.stim.pulse.freq);
        for ff = 1:numel(freq)
            interpulseDur = (1 / freq(ff));
            pulseEdges = prePTA:dt:interpulseDur;
            timeVec = round((pulseEdges(2:end) - (dt / 2)) * 1000, 2);

            smData.pulse.pta.freq(ff) = freq(ff);
            smData.pulse.pta.interpulseDur(ff) = interpulseDur;
            smData.pulse.pta.pulseEdges{ff} = pulseEdges;
            smData.pulse.pta.timeVec{ff} = timeVec;

            % The indices and timestamps of the blanking interval
            smData.pulse.pta.blankingIdx(ff, :) = find(timeVec > 0 & timeVec < (blankingInterval * 1000));
            smData.pulse.pta.stimInterval(ff, :) = [0, 1.5];
        end

        % Get the counts for indexing
        numStimPulses = smRaw.stim.pulse.numPulses;
        smData.pulse.indv.pta = NaN(numUnits * numStimPulses, max(cellfun(@length, smData.pulse.pta.timeVec)));

        pulseCont = 1;
        fprintf('Processing pulse information\n');
        for sp = 1:numStimPulses

            % Get stim pulse information
            smData.pulse.indv.pulseIdx(pulseCont:(pulseCont + numUnits - 1)) = sp;
            smData.pulse.indv.freqIdx(pulseCont:(pulseCont + numUnits - 1)) = smRaw.stim.pulse.freq(sp);
            smData.pulse.indv.ampIdx(pulseCont:(pulseCont + numUnits - 1)) = smRaw.stim.pulse.amp(sp);

            % Get PTA information
            freqIdx = find(smData.pulse.pta.freq == smRaw.stim.pulse.freq(sp));
            pulseEdges = smData.pulse.pta.pulseEdges{freqIdx};
            interpulseDur = smData.pulse.pta.interpulseDur(freqIdx);
            blankingIdx = smData.pulse.pta.blankingIdx(freqIdx, :);

            % Get the train number for normalizing pta
            trainIdx = smData.baseline.info.trainIdx == smRaw.stim.pulse.trainIdx(sp);

            for uu = 1:numUnits
                smData.pulse.indv.channelIdx(pulseCont) = unique(smRaw.spike.channel);
                smData.pulse.indv.unitIdx(pulseCont) = unitIds(uu);

                if sortSpikes
                    unitIdx = smRaw.spike.unit == unitIds(uu);
                else
                    unitIdx = smRaw.spike.unit >= unitIds(uu);
                end
                spikeTimes = smRaw.spike.time(unitIdx);

                % PTA
                tmp = histcounts(spikeTimes, pulseEdges + smRaw.stim.pulse.time(sp));
                pta = tmp;
                pta(blankingIdx) = NaN;
                smData.pulse.indv.pta(pulseCont, 1:numel(pta)) = pta;

                % Interpulse Counts
                interpulseTime = [smRaw.stim.pulse.time(sp) + blankingInterval, smRaw.stim.pulse.time(sp) + interpulseDur];
                smData.pulse.indv.interpulseCount(pulseCont) = histcounts(spikeTimes, interpulseTime);
                smData.pulse.indv.interpulseTime(pulseCont) = abs(diff(interpulseTime));

                % ISIs
                [~, ~, idx] = histcounts(spikeTimes, interpulseTime);
                smData.pulse.indv.pulseTime(pulseCont) = smRaw.stim.pulse.time(sp);
                smData.pulse.indv.spikeTimes{pulseCont} = spikeTimes(idx > 0);

                pulseCont = pulseCont + 1;

            end % unit loop
        end % stim pulse loop

        %% Pulse Averages
        fprintf('Computing pulse averages\n');

        freq = unique(smData.pulse.indv.freqIdx);
        amp = unique(smData.pulse.indv.ampIdx);
        modThresh = 3;

        pulseCont = 1;
        for ff = 1:numel(freq)
            freqIdx = smData.pulse.indv.freqIdx == freq(ff);
            ptaFreqIdx = smData.pulse.pta.freq == freq(ff);

            for aa = 1:numel(amp)
                ampIdx = smData.pulse.indv.ampIdx == amp(aa);
                for uu = 1:numUnits
                    unitIdx = smData.pulse.indv.unitIdx == unitIds(uu);
                    pulseIdx = find(unitIdx & freqIdx & ampIdx);

                    % Pulse average index vectors
                    smData.pulse.avg.freqIdx(pulseCont) = freq(ff);
                    smData.pulse.avg.ampIdx(pulseCont) = amp(aa);
                    smData.pulse.avg.unitIdx(pulseCont) = unitIds(uu);

                    % PTA
                    pta = mean(smData.pulse.indv.pta(pulseIdx, :), 'omitnan');
                    pta = smoothdata(pta, 'Gaussian', 5, 'omitnan'); % 5 ms smoothing window centered at current data point
                    pta(blankingIdx) = NaN;
                    smData.pulse.avg.pta(pulseCont, :) = pta;
                    %                     smData.pulse.avg.pta_norm(pulseCont, :) = mean(smData.pulse.indv.pta_norm(pulseIdx, :), 'omitnan');

                    % Find Peaks
                    %                     interpulseIdx = find(smData.pulse.pta.timeVec{ptaFreqIdx} > 1.5 & smData.pulse.pta.timeVec{ptaFreqIdx} <= (smData.pulse.pta.interpulseDur(ptaFreqIdx) * 1000));
                    %                     interpulsePTA = smData.pulse.avg.pta(pulseCont, interpulseIdx);
                    %                     [peakValue, peakLoc] = findpeaks(interpulsePTA); %peakLoc = tmp.loc';
                    %                     if ~isempty(peakLoc)
                    %                         smData.pulse.avg.peakTime(pulseCont) = smData.pulse.pta.timeVec{ptaFreqIdx}(interpulseIdx(peakLoc(1)));
                    %                         smData.pulse.avg.peakMod(pulseCont) = smData.pulse.avg.pta_norm(pulseCont, interpulseIdx(peakLoc(1)));
                    %                     else
                    %                         smData.pulse.avg.peakTime(pulseCont) = NaN;
                    %                         smData.pulse.avg.peakMod(pulseCont) = NaN;
                    %                     end

                    % Variance Ratio Tests
                    nanIdx = find(isnan(smData.pulse.avg.pta), 1, 'last') + 1;
                    smData.pulse.avg.ptaVar(pulseCont) = var(smData.pulse.avg.pta(nanIdx:end));

                    if sortSpikes && any(smRaw.spike.unitIds > 0)
                        % Snippet Info
                        smData.unitInfo.unitId(pulseCont) = unitIds(uu);
                        smData.unitInfo.snr(pulseCont) = smRaw.spike.unitInfo.snr(unitIds(uu));
                        smData.unitInfo.amp(pulseCont) = smRaw.spike.unitInfo.amp(unitIds(uu));
                        smData.unitInfo.waveform(pulseCont, :) = smRaw.spike.unitInfo.waveform(unitIds(uu), :);
                        smData.unitInfo.sem_waveform(pulseCont, :) = smRaw.spike.unitInfo.sem_waveform(unitIds(uu), :);
                        smData.unitInfo.numSnips(pulseCont) = sum(smRaw.spike.unit == unitIds(uu));
                    end

                    pulseCont = pulseCont + 1;
                end % unit loop
            end % amplitude loop
        end % freq loop

        %% Modulation by Stim Trains
        fprintf('Processing train data\n');

        % Params
        psthDt = .02; % seconds
        numSegments = 5;
        numTrains = smRaw.stim.train.numTrains;
        smData.train.indv.segmentsFR = NaN(numTrains * numUnits, numSegments);

        trainCont = 1;
        for st = 1:numTrains
            pulseIdx = ismember(smData.pulse.indv.pulseIdx, smRaw.stim.train.pulseIdx{st});
            trainIdx = smData.baseline.info.trainIdx == st;

            for uu = 1:numUnits
                smData.train.indv.freqIdx(trainCont) = smRaw.stim.train.freq(st);
                smData.train.indv.ampIdx(trainCont) = smRaw.stim.train.amp(st);
                smData.train.indv.unitIdx(trainCont) = unitIds(uu);

                %                 % Segmented FR
                unitIdx = smData.pulse.indv.unitIdx == unitIds(uu);
                interpulseFR = smData.pulse.indv.interpulseCount(pulseIdx & unitIdx);
                interpulseTime = smData.pulse.indv.interpulseTime(pulseIdx & unitIdx);
                %                 interpulseFR = reshape(interpulseFR, [length(interpulseFR) / numSegments, numSegments])';
                %                 interpulseTime = reshape(interpulseTime, [length(interpulseTime) / numSegments, numSegments])';
                %                 smData.train.indv.segmentFR(trainCont, :) = sum(interpulseFR, 2) ./ sum(interpulseTime, 2);

                % Stim Train FR
                smData.train.indv.stimFR(trainCont) = sum(interpulseFR(:)) / sum(interpulseTime(:));

                % PSTH
                if sortSpikes
                    unitIdx = smRaw.spike.unit == unitIds(uu);
                else
                    unitIdx = smRaw.spike.unit >= unitIds(uu);
                end
                spikeTimes = smRaw.spike.time(unitIdx);
                trainStart = smRaw.stim.train.time{st}(1);
                trainEnd = smRaw.stim.train.time{st}(end);
                spikesIdx = spikeTimes >= trainStart & spikeTimes <= trainEnd;
                smData.train.indv.spikeTimes{trainCont} = spikeTimes(spikesIdx) - trainStart;
                smData.train.indv.psth(trainCont, :) = histcounts(smData.train.indv.spikeTimes{trainCont}, .1:psthDt:.9) / psthDt;
                trainCont = trainCont + 1;

            end % unit loop
        end % train loop

        %% Train Averages: Across Frequency and Amplitude
        fprintf('Computing train averages\n');
        freq = unique(smData.train.indv.freqIdx);
        amp = unique(smData.train.indv.ampIdx);

        trainCont = 1;
        for ff = 1:numel(freq)
            freqIdx = smData.train.indv.freqIdx == freq(ff);
            for aa = 1:numel(amp)
                ampIdx = smData.train.indv.ampIdx == amp(aa);
                for uu = 1:numUnits
                    unitIdx = smData.train.indv.unitIdx == unitIds(uu);
                    trainIdx = find(unitIdx & freqIdx & ampIdx);

                    % Train Index
                    smData.train.avg.freqIdx(trainCont) = freq(ff);
                    smData.train.avg.ampIdx(trainCont) = amp(aa);
                    smData.train.avg.unitIdx(trainCont) = unitIds(uu);

                    % Means
                    smData.train.avg.stimFR(trainCont) = mean(smData.train.indv.stimFR(trainIdx));
                    %                     smData.train.avg.segmentFR(trainCont, :) = mean(smData.train.indv.segmentFR(trainIdx, :), 'omitnan');

                    % PSTH Mean and Variance
                    smData.train.avg.psth(trainCont, :) = mean(smData.train.indv.psth(trainIdx, :));
                    smData.train.avg.psthVar(trainCont) = var(smData.train.avg.psth(trainCont, :));

                    %% Statistical Tests

                    % Segmented Train
                    %                 anovaTrainTable = [smData.train.indv.preStimFR(trainIdx)', smData.train.indv.segmentFR(trainIdx, :), smData.train.indv.postStimFR(trainIdx)'];
                    %                 [smData.train.avg.anova_p(trainCont), ~, stats] = anova1(anovaTrainTable, [], 'off');
                    %                 smData.train.avg.multcomp{trainCont} = multcompare(stats, 'Display', 'off');
                    %                 if smData.train.avg.anova_p(trainCont) < 0.05
                    %                     smData.train.avg.segment_isModulated(trainCont) = 1;
                    %                 else
                    %                     smData.train.avg.segment_isModulated(trainCont) = 0;
                    %                 end

                    trainCont = trainCont + 1;
                end % unit loop
            end % amplitude loop
        end % freq loop

        %% Saving the data
        if saveData
            if exist(saveDataFolder, 'dir') ~= 7; mkdir(saveDataFolder); end
            fileSize = whos('smData');
            fileSizeGB = fileSize.bytes / 1e9;
            if fileSizeGB >= fileSizeThresh
                fprintf('The current size of wd is %.2f GB. Save data as separate channels.', fileSizeGB);
            else
                fprintf('Saving data\n')
                save(sprintf('%s.mat', [saveDataFolder, saveDataFilename]), 'smData', '-v7.3')
            end
        end

        if clearData
            clear smRaw smData
        end
        clc;

    end
end
