
close all; clear; clc;
sessionDate = 20230831;

stimElectrode = [2:30, 32:61, 63, 64];
motorChannel = [1:64, 97:192, 225:256]; %[177, 236, 237, 253, 255];

% motorChannel = [1:64, 97:192, 226:256]; % skipped mc = 136, 151 (mcId = 168, 183)
% motorChannel = [1:64, 97:167, 169:182, 184:192, 226:256]; 


for freqId = [100]
    for mc = 1:length(motorChannel)
        fprintf('Running motor channel: %i/%i\n', mc, length(motorChannel))
        mcId = motorChannel(mc);

        cont = 1;
        for se = 1:length(stimElectrode)
            seId = stimElectrode(se);
            try
                load(sprintf('S:/UserFolders/NatalyaShelchkova/BCI/Data/Stim Modulation/%i/SE%i_MC%i_%iHz_StimMod_%i_Unsorted.mat', sessionDate, seId, mcId, freqId, sessionDate))
            catch
                continue;
            end
            allSmData.stimElectrode(cont) = seId;
            allSmData.data(cont) = smData;
            cont = cont + 1;
        end

        if exist('allSmData', 'var')
            save(sprintf('S:/UserFolders/NatalyaShelchkova/BCI/Data/Stim Modulation/%i/MC%i_AllSE_%iHz_%i_Unsorted.mat', sessionDate, mcId, freqId, sessionDate), 'allSmData')
            clear allSmData
        end

    end
end