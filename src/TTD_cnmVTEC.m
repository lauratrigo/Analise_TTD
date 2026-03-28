clc
clear all
close all

%load('zpla234-2025-08-22.Cmn')

clear; clc;

% Epicentro
lat0 = -60.186;
lon0 = -61.821;

file = 'zpla234-2025-08-22.Cmn';

% -------------------------
% LER ARQUIVO (pula cabeçalho)
% -------------------------
fid = fopen(file, 'rt');

for i = 1:2
    fgetl(fid);
end

localizacao = textscan(fid, '%f %f %f %f %f %f %f %f %f %f');

lat_orig    = localizacao{1};
lon_orig    = localizacao{2};

dist_orig=distancia_radial(lat0,lon0,lat_orig,lon_orig);

% ler os dados numéricos
data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f');

% pular as 3 primeiras linhas (header)
for i = 1:5
    fgetl(fid);
end

% ler os dados numéricos
data = textscan(fid, '%f %f %f %f %f %f %f %f %f %f');

fclose(fid);

% -------------------------
% ORGANIZAR COLUNAS
% -------------------------
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

MJdate_f=MJdate(idx);
time_f=time(idx);
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
    janela_curta = 3*4;    % 3 minutos
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
    
    
    dist_km(idx_evento)=dist_orig;
    
    
    
        
    
    
   c_norm = (vtec_f(idx_evento) - min(vtec_f(idx_evento))) / (max(vtec_f(idx_evento)) - min(vtec_f(idx_evento))); % normaliza 0–1

  % c_norm = (stec_f - min(stec_f)) / (max(stec_f) - min(stec_f)); % normaliza 0–1
   
map = jet(256);  % pode trocar: parula, turbo, hot...

idx2 = round(c_norm * 255) + 1;  % índice de cor

rgb = map(idx2, :);  % matriz Nx3 (RGB)

figure; hold on;




scatter(time_f(idx_evento), dist_km(idx_evento), 10, rgb, 'filled');

%scatter(time_f, dist_km, 10, rgb, 'filled');

xlabel('Tempo')
ylabel('Distância epicentral (km)')




