img = imread('pca4_quiet_days.png');

% Se tiver canal alpha, remove (fica só RGB)
if size(img,3) == 4
    img = img(:,:,1:3);
end

% Converter para escala de cinza
gray = rgb2gray(img);

% Detectar pixels "não brancos"
threshold = 250; % ajuste se necessário (0-255)
mask = gray < threshold;

% Encontrar limites onde existe conteúdo
rows = any(mask, 2);
cols = any(mask, 1);

row_min = find(rows, 1, 'first');
row_max = find(rows, 1, 'last');
col_min = find(cols, 1, 'first');
col_max = find(cols, 1, 'last');

% Cortar imagem
cropped = img(row_min:row_max, col_min:col_max, :);

% Salvar resultado
imwrite(cropped, 'pca4_quiet_days2.png');

imshow(cropped)