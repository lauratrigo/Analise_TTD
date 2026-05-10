clc
clear all
close all

% epicentro do terremoto na argentina (22/08/2025)
lat0 = -60.186;
lon0 = -61.821;

files = {'tolh234-2025-08-22.Cmn', 'autf234-2025-08-22.Cmn', 'rio2234-2025-08-22.Cmn', 'unpa234-2025-08-22.Cmn', ...
    'pde3234-2025-08-22.Cmn', 'sarm234-2025-08-22.Cmn', 'rwsn234-2025-08-22.Cmn', ...
    'esqu234-2025-08-22.Cmn', 'bols234-2025-08-22.Cmn', 'pata234-2025-08-22.Cmn', 'bch1234-2025-08-22.Cmn', ...
    'sico234-2025-08-22.Cmn', 'nesa234-2025-08-22.Cmn', 'pelu234-2025-08-22.Cmn', 'sman234-2025-08-22.Cmn', ...
    'chim234-2025-08-22.Cmn', 'bate234-2025-08-22.Cmn', 'pbca234-2025-08-22.Cmn', 'grca234-2025-08-22.Cmn', ...
    'vbca234-2025-08-22.Cmn', 'neqn234-2025-08-22.Cmn', '3aro234-2025-08-22.Cmn', 'zpla234-2025-08-22.Cmn', ...
    'pwro234-2025-08-22.Cmn', 'lhcl234-2025-08-22.Cmn', 'mpl2234-2025-08-22.Cmn', 'bcar234-2025-08-22.Cmn', ...
    '25ma234-2025-08-22.Cmn', 'suar234-2025-08-22.Cmn', 'vcop234-2025-08-22.Cmn', 'rsau234-2025-08-22.Cmn', ...
    'azul234-2025-08-22.Cmn', 'srlp234-2025-08-22.Cmn', 'lmhs234-2025-08-22.Cmn', 'dore234-2025-08-22.Cmn', ...
    'sais234-2025-08-22.Cmn', 'peji234-2025-08-22.Cmn', 'smdm234-2025-08-22.Cmn', 'mgue234-2025-08-22.Cmn', ...
    'gvil234-2025-08-22.Cmn', 'choy234-2025-08-22.Cmn', 'lpgs234-2025-08-22.Cmn', 'aggo234-2025-08-22.Cmn', ...
    'mzga234-2025-08-22.Cmn', 'igm1234-2025-08-22.Cmn', 'uyco234-2025-08-22.Cmn', 'mzrf234-2025-08-22.Cmn', ...
    'rufi234-2025-08-22.Cmn', 'peba234-2025-08-22.Cmn', 'mglo234-2025-08-22.Cmn', 'vime234-2025-08-22.Cmn', ...
    'fmat234-2025-08-22.Cmn', 'mzau234-2025-08-22.Cmn', 'vcon234-2025-08-22.Cmn'};

load('dados_workspace-terremoto.mat')

pc1 = score(:,1);
tempo_pca = t_minutos;  % em minutos

% -------------------------
% LER ARQUIVOS
% -------------------------


selected_files = {};
selected_data = {};

h_store = cell(length(files),1);

i = 1;
while i <= length(files)
    
    file = files{i};
    
    fid = fopen(file, 'rt');
    
    if fid == -1
        disp(['Erro ao abrir arquivo: ', file])
        i = i + 1;
        continue
    end
    
    fgetl(fid); % linha 1
    fgetl(fid); % linha 2
    
    % localiza??o da esta??o
    loc = textscan(fid, '%f %f %f');
    lat_orig = loc{1};
    lon_orig = loc{2};
    
    dist_orig=distancia_radial(lat0,lon0,lat_orig,lon_orig);
    
    fgetl(fid);
    
    data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f');
    fclose(fid);
    
    MJdate = data{1};
    time   = data{2};
    prn    = data{3};
    az     = data{4};
    ele    = data{5};
    lat    = data{6};
    lon    = data{7};
    stec   = data{8};
    vtec   = data{9};
    s4     = data{10};
    
    % -------------------------
    % FILTRO: ELEVA??O > 30
    % -------------------------

    t_inicio1 = datenum(2025,8,22,2,16,0)- 678942;   % 22 Aug 02:16
%     t_fim1    = datenum(2025,8,22,3,06,0)- 678942;   % 22 Aug 03:06 (50 minutos)
    t_fim1    = datenum(2025,8,22,3,0,0)- 678942;   % 22 Aug 04:16 (2 horas)


    %idx_tempo = (MJdate>t_inicio1);

    prn_escolhido = 1;

    idx = (ele > 30) & (prn == prn_escolhido);

    MJdate_f = MJdate(idx);
    time_f = time(idx);
    prn_f  = prn(idx);
    stec_f = stec(idx);
    vtec_f = vtec(idx);
    lat_f  = lat(idx);
    lon_f  = lon(idx);
    ele_f  = ele(idx);
    
    % condicional caso alguma esta??o n?o tenha o prn escolhido
    if isempty(time_f)
        disp(['Esta??o ', file, ' n?o possui PRN ', num2str(prn_escolhido), ' -> pulando'])
        i = i + 1;
        continue
    end
    
       
    % ==============================
    % FIT
    % ==============================
    
%     [exp_tr,gof_tr] = fit(time_f,stec_f,"exp2");
%     fit_vals = exp_tr(time_f);   % avalia o ajuste
%     stec_f = stec_f - fit_vals;  % agora sim funciona
    
   
          
    % ==============================
    % M?DIA CORRIDA 16 PONTOS
    % ==============================
%     janela_longa = 16*4;   % 16 minutos
%     media_longa = movmean(stec_f, janela_longa, 'omitnan');
% 
%     
%     % Se quiser manter a banda tipo 2?10 mHz,
%     % mantenha uma janela curta pequena
%     janela_curta = 3*4;    % 3 minutos
%     media_curta = movmean(stec_f, janela_curta, 'omitnan');
% 
%     % Residual tipo passa-banda aproximado
%     stec_f =  media_curta - media_longa;
%     
    
    %idx_tempo = (MJdate_f>=t_inicio1)

    % -------------------------
    % RESULTADO FINAL
    % -------------------------
    resultado = [prn_f, stec_f, vtec_f, lat_f, lon_f, ele_f];

    %disp('PRN  STEC  VTEC  LAT  LON  ELE');
    %disp(resultado);

    % -------------------------
    % Distacia Radial do Epicento
    % -------------------------

    time_real = MJdate_f;

    % 2. Identifique os ?ndices que caem exatamente entre 02:16 e 06:16 do dia 22
    idx_evento = find((MJdate_f>=t_inicio1) & (MJdate_f <= t_fim1));
    
%     tempo_dados_min = time_f * 60;

    x = time_f(idx_evento);
    x_min = x * 60;

    pc1_interp = interp1(tempo_pca, pc1, x_min, 'linear', 'extrap');

   dist_km(idx_evento)=dist_orig;
              
%    c_norm = (stec_f(idx_evento) - min(stec_f(idx_evento))) / (max(stec_f(idx_evento)) - min(stec_f(idx_evento))); % normaliza 0?1

    c_norm = (pc1_interp - min(pc1_interp)) / (max(pc1_interp) - min(pc1_interp));
%     y = dist_km(idx_evento)' + (100*c_norm);
   
    c_norm(isnan(c_norm) | isinf(c_norm)) = 0;
   
   map = cool(256);  % pode trocar: parula, turbo, hot...

   idx2 = round(c_norm * 255) + 1;  % ?ndice de cor

   rgb = map(idx2, :);  % matriz Nx3 (RGB)
   
   figure(1)
   
    x = time_f(idx_evento);
%     y = stec_f(idx_evento);
    y = pc1_interp;
   
%    s=scatter(time_f(idx_evento), dist_km(idx_evento)'+(1000*vtec_f(idx_evento)), 10, rgb, 'filled');
%    s.SizeData = 75;

 h = gobjects(length(x)-1,1); % pr?-alocar array para handles

    for k = 1:length(x)-1
        h(k) = plot(x(k:k+1), y(k:k+1), 'Color', rgb(k,:), 'LineWidth', 3);
        hold on
    end

    title(['Arquivo: ', file])
    drawnow

    resp_str = input(['Manter esta??o ', file, '? (1 = sim, 0 = nao, -1 = para retornar para o anterior, 9 = sair): '], 's');
    resp = str2double(resp_str);
    
    h_store{i} = h;

    if resp == -1
        if ~isempty(h_store{i})
            delete(h_store{i})
            h_store{i} = [];
    end
    i = i - 1;

    elseif resp == 0
        if ~isempty(h_store{i})
            delete(h_store{i})
            h_store{i} = [];
        end
        i = i + 1;

    elseif resp == 1
        % =========================
        % SALVAR IMAGEM
        % =========================
        nome_fig = ['plot_', file, '.png'];
        saveas(gcf, nome_fig);

        % =========================
        % GUARDAR DADOS
        % =========================
        selected_files{end+1} = file;

        temp.x = x;
        temp.y = y;
        temp.rgb = rgb;
        selected_data{end+1} = temp;

        clf

        i = i + 1;

    elseif resp == 9
        disp('encerrando o programa')
        break

    else
        i = i + 1;
    end
    
   hold on;
   
      
end

figure
hold on

fid = fopen('Distância radial.txt','r');

dist_map = containers.Map;

while ~feof(fid)
    
    linha = fgetl(fid);
    
    % tenta extrair: NOME e DISTANCIA
    tokens = regexp(linha, '([A-Z0-9]{4})\s*->\s*([\d\.]+)', 'tokens');
    
    if ~isempty(tokens)
        nome = tokens{1}{1};
        dist = str2double(tokens{1}{2});
        
        dist_map(nome) = dist;
    end
end

fclose(fid);

figure(2)
clf
set(gcf, 'Position', [100 100 600 850]) % altera o tamanho do gr?fico [left  bottom  width  height]

n = length(selected_data);

if n == 0
    disp('Nenhuma esta??o foi selecionada.')
else
    for i_plot = 1:n
        
        subplot(n,1,i_plot)
        hold on
        
        data = selected_data{i_plot};
        
        x = data.x;
        y = data.y;
        rgb = data.rgb;

        for j = 1:length(x)-1
            plot(x(j:j+1), y(j:j+1), 'Color', rgb(j,:), 'LineWidth', 2);
        end
        
        set(gca, 'FontSize', 16)

        if ~isempty(x) && min(x) < max(x)
            xlim([min(x) max(x)])
        end
        
%       title(['Esta??o: ', selected_files{i_plot}])
%         xlabel('Time (UT)')

        % plota s? os primeiros 4 caracteres no nome das esta??es em caps lock
        if i_plot == n
            xlabel('Time (UT)')
        end
        nome = upper(selected_files{i_plot}(1:4));
        if isKey(dist_map, nome)
            dist = dist_map(nome);
            label = sprintf('%s\n%.0f km', nome, dist);
        else
            label = nome;
        end

        ylabel(label, 'FontSize', 12)
    end
end

% linhas pretas PRN 3
% annotation('line',[0.3267 0.8083], [0.9518 0.0718]);
% annotation('line',[0.1583 0.6400], [0.9482 0.0682]);
% annotation('line',[0.1417 0.4500], [0.9435 0.0682]);

% linha preta PRN 1
annotation('line',[0.2066 0.5317], [0.9353 0.0965]);