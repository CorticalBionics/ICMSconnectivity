function [minValue, maxValue] = getLimits(data, roundingInt)

% minValue = data;
% maxValue = data;
% 
% % Recursive min/max -> keep doing this until you run out of dimensions
% for ss = 1:numel(size(data))
    minValue = min(data(:));
    maxValue = max(data(:));
% end

minValue = floor(minValue / roundingInt) * roundingInt; 
maxValue = ceil(maxValue / roundingInt) * roundingInt;

% % Get the minimum value
% if ~isempty(minValue) && minValue >= possValues(1)
%     yMin = possValues(find(minValue >= possValues, 1, 'last'));
% end
% 
% % Get the maximum value
% if ~isempty(maxValue) && maxValue <= possValues(end)
%     yMax = possValues(find(maxValue <= possValues, 1, 'first'));
% end


end