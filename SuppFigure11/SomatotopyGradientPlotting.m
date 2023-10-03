function [] = SomatotopyGradientPlotting(sm, smData, pd, projectionFields, arrayInfo, arrayOfInterest)

numDigits = 5;
numChannels = 192;

% Use 3 for C1, 1 for P2 and P3
if arrayOfInterest == 1
    motChanMask = sm.motorChannel<129;
elseif arrayOfInterest == 3
    motChanMask = sm.motorChannel>128;
end

filtSize = 1; % Filter size to smooth the heatmaps prior to taking correlations
[smData.rf.hmap, smData.pf.hmap] = deal(zeros(5, 10, 10));


for dd = 1:numDigits
    
    % Get the motor channel heatmaps
     motorRF = zeros(1, numChannels);
     if arrayOfInterest == 1
         mcIdx = find(~isnan(pd.digit.avgFlexModIdx(1:96))); % Find which motor channels were modulated
         motorRF(mcIdx) = pd.digit.diffFlexResponse(mcIdx, dd);
     elseif arrayOfInterest == 3
         mcIdx = find(~isnan(pd.digit.avgFlexModIdx(97:192)))+96; % Find which motor channels were modulated
         motorRF(mcIdx-96) = pd.digit.diffFlexResponse(mcIdx, dd);
     end

     coi = arrayInfo.ChanIndices{arrayOfInterest};
     tmp = createHeatmapMatrix(motorRF', coi, 'motor', arrayInfo);
     if arrayOfInterest == 1
         tmp = tmp.medial;
     elseif arrayOfInterest == 3
         tmp = tmp.lateral;
     end

     % Smooth the heatmaps
     tmp(isnan(tmp)) = 0;
     tmp = imgaussfilt(tmp, filtSize);
     tmp([1, 1, end, end], [1, end, 1, end]) = NaN; % There are no channels in the corners of the arrays NEED TO ADJUST FOR P2
     smData.rf.hmap(dd, :, :) = tmp;

    % Get the stim channels with relevant PFs
    seFingerIdx = cellfun(@(x) any(x == dd) & ~isempty(x), projectionFields.digitPFs, 'UniformOutput', 1);
    stimElectrodes = projectionFields.stimElectrode(seFingerIdx);
    seIdx = ismember(sm.stimElectrode, stimElectrodes');

    % Compute projection field heatmap and overlap with motor RFs
    if sum(seIdx) > 0
        
        % Find the motor channels which are significantly modulated by
        % these stim electrodes
        mcIdx = find(sum(sm.isModulated(:, seIdx), 2) > 0);
        stimModMCs = sm.motorChannel(1, mcIdx);
        seID = find(seIdx);
        
        % Get the projection field heatmap
%         stimPF = zeros(1, numChannels);
        modStim = mean(sm.modValue(motChanMask, seID(seID > 0)), 2);
        %         modStim = max(sm.modValue(:, seID(seID > 0)), [], 2); 
        
        
        tmp = createHeatmapMatrix(modStim, sm.motorChannel(motChanMask), 'motor', arrayInfo);  
        if arrayOfInterest == 1
            tmp = tmp.medial;
        elseif arrayOfInterest == 3
            tmp = tmp.lateral;
        end
        %Smoothing steps
        tmp(isnan(tmp)) = 0;
        tmp = imgaussfilt(tmp, filtSize);
        tmp([1, 1, end, end], [1, end, 1, end]) = NaN;
        smData.pf.hmap(dd, :, :) = tmp;
        
        % Get the correlations
        tmpRF = squeeze(smData.rf.hmap(dd, :, :));
        tmpPF = squeeze(smData.pf.hmap(dd,:,:));
        smData.corr(dd) = corr(tmpRF(:), tmpPF(:), 'rows', 'pairwise');        
    end
end


normedPF = nan(5,10,10);
normedRF = nan(5,10,10);

for dig = 1:5
    digHMap = squeeze(smData.pf.hmap(dig,:,:));
    normedPF(dig,:,:) = (digHMap - mean(digHMap(:),'omitnan'))/std(digHMap(:),'omitnan');

    digHMap = squeeze(smData.rf.hmap(dig,:,:));
    normedRF(dig,:,:) = (digHMap - mean(digHMap(:),'omitnan'))/std(digHMap(:),'omitnan');
end

gradMotor = nan(10,10);
gradSense = nan(10,10);

for row = 1:10
    for col = 1:10
        
        tempDigVals = squeeze(normedRF(:, row, col));
        linFit = corr([1 2 3 4 5]',tempDigVals,'Type','Spearman');
        gradMotor(row,col) = linFit;

        tempDigVals = squeeze(normedPF(:, row, col));
        if arrayOfInterest == 1
            linFit = corr([1 2 3 4 5]',tempDigVals(1:5),'Type','Spearman');
        elseif arrayOfInterest == 3
            linFit = corr([1 2 3 4]',tempDigVals(1:4),'Type','Spearman');
        end
        
        gradSense(row,col) = linFit;

    end
end


mod_cmap = cmap_gradient([8 29 88;37 52 148;34 94 168;29 145 192;65 182 196;127 205 187]/256);


figure();
subplot(1,2,1);generateHeatmap(gradMotor, 'cmap', mod_cmap, 'plotOutline', 1, 'clim', [-1, 1]);title('Motor Map','FontSize',24);axis square;
subplot(1,2,2);generateHeatmap(gradSense, 'cmap', mod_cmap, 'plotOutline', 1, 'clim', [-1, 1]);title('Sensory Map','FontSize',24);axis square;

end