% Load Data
subjectID = 'C1';
seId = 9;
mcId = 165;

switch subjectID
    case 'C1'
        sessionDate = 20211228;
    case 'P2'
        sessionDate = 20211215;
    case 'P3'
        sessionDate = 20220128;
end
load(sprintf('%s/SE%i_MC%i_100Hz_Raw_%i.mat', subjectID, seId, mcId))


% Raster and PSTH Params
padding = 1;
maxSnippets = 500;
dt = .04;
psthBins = -1:dt:2;
psthTimeVec = (psthBins(1:end - 1)) + (dt / 2);

rasterColors = [rgb(173, 20, 87); rgb(106, 27, 154); rgb(0, 105, 92); rgb(216, 67, 21); rgb(40, 53, 147); rgb(46, 125, 50)];

spikeTimes = [];
validSpikes = smRaw.spike.time(smRaw.spike.unit >= 0);
blankingPeriod = .002;
psth = [];

for st = 1:smRaw.stim.train.numTrains
    trainStart = smRaw.stim.train.time{st}(1);
    trainEnd = smRaw.stim.train.time{st}(end) + padding;
    trainPulses = smRaw.stim.pulse.time(smRaw.stim.pulse.trainIdx == st) - trainStart;
    tmpSpikes = validSpikes(validSpikes >= (trainStart - padding) & validSpikes <= trainEnd) - trainStart;
    if ~isempty(tmpSpikes)
        blankedSpikesIdx = [];
        % blank out spikes
        for sp = 1:length(trainPulses)
            blankedSpikesIdx = [blankedSpikesIdx, find(tmpSpikes >= trainPulses(sp) & tmpSpikes <= trainPulses(sp) + blankingPeriod)];
        end
        validSpikesIdx = ~ismember(1:length(tmpSpikes), blankedSpikesIdx);
        if validSpikesIdx == 0
            spikeTimes{st} = [];
        else
            spikeTimes{st} = tmpSpikes(validSpikesIdx);
        end
    else
        spikeTimes{st} = tmpSpikes;
    end
    psth(st, :) = histcounts(spikeTimes{st}, psthBins);
end

% Raster
r = rasterfy(spikeTimes, 0.5);
for rr = 1:length(r)
    plot(r{rr,1}, r{rr,2}, 'Color', rasterColors(ii, :), 'LineWidth', .5)
    hold on
end
plot([0 1], [length(r) + 1.5 length(r) + 1.5], 'k', 'LineWidth', 1)
ylim([0.5 length(r) + 2])
set(gca, 'YTick', [], 'YColor', 'w', 'XTick', [], 'XColor', 'w')
axis off

% PSTH
plot(psthTimeVec, smoothdata(nanmean(psth) ./ dt, 'Gaussian', 5, 'omitnan'), 'Color', rasterColors(ii, :), 'LineWidth', 1)
hold on
set(gca, 'YTick', [], 'YColor', 'none', 'XTick', [], 'XColor', 'none')
box off
