function hmap = createHeatmapMatrix(data, coi, hmapType, arrayInfo)

% Generate heatmap matrices based on the array type
if strcmpi(hmapType, 'motor')
    aoi = [1,3]; 
else
    aoi = [2,4];
end
[hmap.medial, hmap.lateral] = deal(NaN(size(arrayInfo.GridLoc{aoi(1)})));

% Insert the hmap values for the channels that exist into the heatmap
for cc = 1:numel(coi)
    chInfo = getChannelInfo(coi(cc), hmapType, arrayInfo);
    if chInfo.array == 1 || chInfo.array == 2 % Medial array
        hmap.medial(chInfo.hmapRow, chInfo.hmapCol) = data(cc);
    else % Lateral arrays
        hmap.lateral(chInfo.hmapRow, chInfo.hmapCol) = data(cc);
    end
end

end


