clc
clear all
close all

% Epicentro
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

% -------------------------
% LER ARQUIVOS
% -------------------------

for i = 1:length(files)
    
    file = files{i};
    
    fid = fopen(file, 'rt');
    
    fgetl(fid); % linha 1
    fgetl(fid); % linha 2
    
    % localização da estação
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
    % FILTRO: ELEVAÇÃO > 30
    % -------------------------

    t_inicio1 = datenum(2025,8,22,2,16,0)- 678942;   % 22 Aug 02:16
%     t_fim1    = datenum(2025,8,22,3,06,0)- 678942;   % 22 Aug 03:06 (50 minutos)
    t_fim1    = datenum(2025,8,22,4,16,0)- 678942;   % 22 Aug 04:16 (2 horas)


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
        
    % ==============================
    % MÉDIA CORRIDA 16 PONTOS
    % ==============================
    janela_longa = 16*4;   % 16 minutos
    media_longa = movmean(stec_f, janela_longa, 'omitnan');

    
    % Se quiser manter a banda tipo 2–10 mHz,
    % mantenha uma janela curta pequena
    janela_curta = 2;    % 3 minutos
    media_curta = movmean(stec_f, janela_curta, 'omitnan');

    % Residual tipo passa-banda aproximado
%     stec_f = media_curta - media_longa;
    
    
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

    % 2. Identifique os índices que caem exatamente entre 02:16 e 06:16 do dia 22
    idx_evento = find((MJdate_f>=t_inicio1) & (MJdate_f <= t_fim1));

   dist_km(idx_evento)=dist_orig;
              
   c_norm = (stec_f(idx_evento) - min(stec_f(idx_evento))) / (max(stec_f(idx_evento)) - min(stec_f(idx_evento))); % normaliza 0–1
    
   c_norm(isnan(c_norm) | isinf(c_norm)) = 0;
   
   map = jet(256);  % pode trocar: parula, turbo, hot...

   idx2 = round(c_norm * 255) + 1;  % índice de cor

   rgb = map(idx2, :);  % matriz Nx3 (RGB)
   
   figure(1)
   
    x = time_f(idx_evento);
    y = dist_km(idx_evento)' + (1000*stec_f(idx_evento));
   
%    s=scatter(time_f(idx_evento), dist_km(idx_evento)'+(1000*vtec_f(idx_evento)), 10, rgb, 'filled');
%    s.SizeData = 75;

    h = gobjects(length(x)-1,1); % pré-alocar array para handles

    for k = 1:length(x)-1
        h(k) = plot(x(k:k+1), y(k:k+1), 'Color', rgb(k,:), 'LineWidth', 3);
        hold on
    end

    title(['Arquivo: ', file])
    drawnow

    resp_str = input(['Manter estação ', file, '? (1 = sim, 0 = nao, -1 = sair): '], 's');
    resp = str2double(resp_str);

    if isnan(resp)  % Se não digitou número, assumir sim
        resp = 1;
    end

    if resp == -1
        disp('Execução encerrada')
        break
    elseif resp == 0
        delete(h) 
    end
    
   hold on;
    
end

  % c_norm = (stec_f - min(stec_f)) / (max(stec_f) - min(stec_f)); % normaliza 0–1
   
%figure; hold on;

ylim([700 3000])
xlim([2.25 3.1])

xlabel('Tempo')
ylabel('Distância epicentral (km)')
