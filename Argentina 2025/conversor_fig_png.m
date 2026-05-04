files = dir('*.fig');

for k = 1:length(files)
    fig = openfig(files(k).name, 'invisible'); % não abre janela
    
    % garante que não deforma
    set(fig, 'Units','pixels');
    pos = get(fig,'Position');
    set(fig, 'PaperPositionMode','auto');
    
    [~, name, ~] = fileparts(files(k).name);
    print(fig, [name '.png'], '-dpng', '-r300');
    
    close(fig);
end