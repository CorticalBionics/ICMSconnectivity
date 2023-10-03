function h = generateHeatmap(data, varargin) 

% Possible arguments
% cmap = colormap to be used
% clims = c axis limits
% plotOutline = plot the outline of the array

plotOutline = 0;
cmap = [];
clims = [];
for vv = 1:2:length(varargin)
    if strcmpi(varargin{vv}, 'cmap')
        cmap = varargin{vv + 1};
    elseif strcmpi(varargin{vv}, 'clim')
        clims = varargin{vv + 1};
    elseif strcmpi(varargin{vv}, 'plotOutline')
        plotOutline = varargin{vv + 1};
    else
        warning('Unrecognized argument: %s', varargin{vv}) 
    end
end

h = imagesc(data);
set(h, 'AlphaData', ~isnan(data))
axis off

if ~isempty(cmap)
    colormap(gca, cmap);
end

if ~isempty(clims)
    caxis(clims);
end

if plotOutline
    hold on
    % Big Outer Lines
    plot([1.5 9.5], [10.5, 10.5], 'k', 'LineWidth', 1); % bottom
    plot([1.5 9.5], [.5, .5], 'k', 'LineWidth', 1); % top
    plot([.5 .5], [1.5, 9.5], 'k', 'LineWidth', 1); % left
    plot([10.5 10.5], [1.5, 9.5], 'k', 'LineWidth', 1); % right
    
    % Corners
    plot([.5 1.5], [9.5, 9.5], 'k', 'LineWidth', 1); plot([1.5 1.5], [9.5, 10.5], 'k', 'LineWidth', 1); % bottom left
    plot([9.5 10.5], [9.5, 9.5], 'k', 'LineWidth', 1); plot([9.5 9.5], [9.5, 10.5], 'k', 'LineWidth', 1); % bottom right
    plot([.5 1.5], [1.5, 1.5], 'k', 'LineWidth', 1); plot([1.5 1.5], [1.5, 0.5], 'k', 'LineWidth', 1); % top left
    plot([9.5 10.5], [1.5, 1.5], 'k', 'LineWidth', 1); plot([9.5 9.5], [1.5, 0.5], 'k', 'LineWidth', 1); % top 
end

end
