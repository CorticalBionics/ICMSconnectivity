function confusionMatrix(data, varargin)

fsize = 7;
for vv = 1:2:numel(varargin)
    if strcmp(varargin{vv}, 'FontSize')
        fsize = varargin{vv + 1};
    end
end

numRows = size(data, 1);
numCols = size(data, 2);

h = imagesc(data);
set(h, 'AlphaData', ~isnan(data))
caxis([0 1])
for rr = 1:numRows
    for cc = 1:numCols
        if ~isnan(data(rr, cc))
        text(cc, rr, sprintf('%.2f', data(rr, cc)), 'Color', 'k', 'FontSize', fsize, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle')
        end
    end
end
axis square


end