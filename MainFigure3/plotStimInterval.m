function plotStimInterval(stimStart, stimEnd, yMax, varargin)

color = rgbt('LightSlateGrey');
figHandle = gca;
for vv = 1:2:length(varargin)
    if strcmpi(varargin{vv}, 'Color')
        color = varargin{vv + 1};
    elseif strcmpi(varargin{vv}, 'Parent')
        figHandle = varargin{vv + 1};
    end
end
patch([stimStart, stimEnd, stimEnd, stimStart], [0, 0, yMax, yMax], ...
    'r', 'FaceColor', color, 'FaceAlpha', 0.2, ...
    'EdgeColor', 'none', 'Parent', figHandle)

end