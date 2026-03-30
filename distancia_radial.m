function dist_km=distancia_radial(lat0,lon0,lat_f,lon_f)

% Converter para radianos
lat0 = deg2rad(lat0);
lon0 = deg2rad(lon0);

lat = deg2rad(lat_f);
lon = deg2rad(lon_f);

% Diferenças
dlat = lat - lat0;
dlon = lon - lon0;

% Haversine
a = sin(dlat/2).^2 + cos(lat0).*cos(lat).*sin(dlon/2).^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));

R = 6371; % km
dist_km = R * c;

