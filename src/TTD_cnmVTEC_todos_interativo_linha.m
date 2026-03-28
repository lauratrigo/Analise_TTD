clc
clear all
close all

% Epicentro
lat0 = -60.186;
lon0 = -61.821;

files = dir('*-2025-08-22.Cmn');



% -------------------------
% LER ARQUIVOS
% -------------------------

todos_vtec = [];

for i = 1:length(files)
    
    file = files(i).name;
    
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
    t_fim1    = datenum(2025,8,22,3,06,0)- 678942;   % 22 Aug 03:06 (50 minutos)

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
    media_longa = movmean(vtec_f, janela_longa, 'omitnan');

    % Se quiser manter a banda tipo 2–10 mHz,
    % mantenha uma janela curta pequena
    janela_curta = 2;    % 3 minutos
    media_curta = movmean(vtec_f, janela_curta, 'omitnan');

    % Residual tipo passa-banda aproximado
    vtec_f = media_curta - media_longa;
    
    
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
    
    
    
    todos_vtec = [todos_vtec; vtec_f(idx_evento)];
    
    
    
    amp_global = max(abs(todos_vtec));

    

   dist_km(idx_evento)=dist_orig;
              
   c_norm = (vtec_f(idx_evento) - min(vtec_f(idx_evento))) / (max(vtec_f(idx_evento)) - min(vtec_f(idx_evento))); % normaliza 0–1
    
   c_norm(isnan(c_norm) | isinf(c_norm)) = 0;
   
   map = jet(256);  % pode trocar: parula, turbo, hot...
    
   idx2 = round(c_norm * 255) + 1;  % índice de cor

   rgb = map(idx2, :);  % matriz Nx3 (RGB)
   
   
   figure(1)
   
    x = time_f(idx_evento);
%     y = dist_km(idx_evento)' + (1000*vtec_f(idx_evento));




%     v = vtec_f(idx_evento);
% 
%     % normalização GLOBAL
%     v_norm = v / amp_global;
% 
%     % suavização (opcional, mas recomendado)
%     v_norm = smoothdata(v_norm, 'gaussian', 10);
% 
%     % offset fixo por estação
%     offset = dist_orig;
% 
%     % escala visual
%     escala = 150;
% 
%     y = offset + escala * v_norm;
%     x = time_f(idx_evento);



v = vtec_f(idx_evento);

% Normalizar todas as ondas para a mesma amplitude máxima global
v_norm = v / amp_global;

% Suavização (opcional)
v_norm = smoothdata(v_norm, 'gaussian', 10);

% Offset para separação entre as ondas
offset = dist_orig;

% Defina a escala (tamanho da oscilação)
escala = 150;  % Ajuste este valor conforme necessário

% Aplique a amplitude uniformizada
y = offset + escala * v_norm;

% Plote os dados
x = time_f(idx_evento);

   
    
    
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
    
end

  % c_norm = (stec_f - min(stec_f)) / (max(stec_f) - min(stec_f)); % normaliza 0–1
   
%figure; hold on;


%scatter(time_f, dist_km, 10, rgb, 'filled');
ylim([700 3000])
xlim([2.25 3.1])

xlabel('Tempo')
ylabel('Distância epicentral (km)')
