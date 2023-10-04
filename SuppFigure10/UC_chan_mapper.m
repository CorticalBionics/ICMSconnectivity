function ChannelMap = UC_chan_mapper(file_path)
if nargin < 1
    [file,path] = uigetfile('*.txt');
    file_path = fullfile(path, file);
end

% load mapfile
tbl = readtable(file_path, 'Delimiter', '\t', 'HeaderLines', 14, 'ReadVariableNames', 1, 'ReadRowNames', 0);
tbl = sortrows(tbl,[3,4]);
ChannelMap.full_table = tbl;

ChannelMap.ArrayNames2 = {'Anterior Motor', 'Anterior Sensory', 'Posterior Motor', 'Posterior Sensory'};
ChannelMap.ArrayNames = {'Medial Motor', 'Medial Sensory', 'Lateral Motor', 'Lateral Sensory'};
ChannelMap.ChanIndices = {[1:64, 97:128], 65:96, [129:192, 225:256], 193:224};
ChannelMap.ArrayColors = [66,146,198; 251,106,74; 8,69,148; 203,24,29]/256;


ChannelMap.GridLoc = {};
for ar = 1:4
    row = 10 - tbl.row(ChannelMap.ChanIndices{ar});
    col = tbl.col(ChannelMap.ChanIndices{ar});
    col = col - min(col) + 1;
    N_row = length(unique(row));
    N_col = length(unique(col));
    lin_loc_indices = sub2ind([N_row N_col], row, col);
    ChannelMap.GridLoc{ar} = nan(N_row, N_col);
    ChannelMap.GridLoc{ar}(lin_loc_indices) = ChannelMap.ChanIndices{ar};
end

ChannelMap.MotorSubplotMapping = [1:10; 11:20; 21:30; 31:40; 41:50; 51:60; 61:70; 71:80; 81:90; 91:100];
ChannelMap.SensorySubplotMapping = [1:6; 7:12; 13:18; 19:24; 25:30; 31:36; 37:42; 43:48; 49:54; 55:60];
ChannelMap.ChanToElectrode = {[1:64, 97:128], [1:32], [129:192, 225:256], [33:64]};
badMotorColumns = [1:105 111:115 121:125 131:160 166:170 176:185 191:195 201:480 516:530 581:590];
motorChannelMask = (badMotorColumns + 4) / 5;
motorChannelMask = round(motorChannelMask(1:5:end));
motorChannels = [ChannelMap.ChanIndices{1}, ChannelMap.ChanIndices{3}];
ChannelMap.ValidMotorChannels = setdiff(motorChannels, motorChannelMask);
ChannelMap.ValidMotorChannels = ChannelMap.ValidMotorChannels(ChannelMap.ValidMotorChannels ~= 112);
ChannelMap.ValidStimChannels = [1:31, 33:36, 38:64];

end