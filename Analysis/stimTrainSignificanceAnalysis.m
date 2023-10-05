clear; clc;
subjectID = 'P3';
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

dataFolder = sprintf('/%i/', sessionDate);

% Saving Data
saveDataType = 'Stim Modulation';
saveDataFolder = sprintf('/%s/%i/', saveDataType, sessionDate);
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
        load(sprintf('Processed Raw Files/%i/Snippets/MC%i_Snippets_%i.mat', sessionDate, mcId, sessionDate))
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
