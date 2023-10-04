function [chInfo] = getChannelInfo(ch, chType, arrayInfo)

% Find the array that the electrode belongs to
if strcmpi(chType, 'stim')
    aoi = [2, 4];
else
    aoi = [1,3];
end

for aa = aoi
    chIdx = arrayInfo.ChanToElectrode{aa} == ch;
    if logical(sum(chIdx))
        arrayIdx = aa;
        break;
    end
end

chInfo.array = arrayIdx;
chInfo.arrayName = arrayInfo.ArrayNames{arrayIdx};
chInfo.chNum = arrayInfo.ChanIndices{arrayIdx}(chIdx);
[row, col] = find(chInfo.chNum == arrayInfo.GridLoc{arrayIdx});
chInfo.hmapRow = row; chInfo.hmapCol = col;

if strcmpi(chType, 'stim')
    chInfo.subplotLoc = arrayInfo.SensorySubplotMapping(row, col);
else
    chInfo.subplotLoc = arrayInfo.MotorSubplotMapping(row, col);
end

end