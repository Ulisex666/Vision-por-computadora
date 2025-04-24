% Leer la imagen en escala de grises
img = imread('/media/ulisex/3AEEAC75EEAC2B59/Users/Ulises/Documents/laptop/Nova 3/File_Restore/Screenshot_20201201_191429_com.instagram.android.jpg');
if isempty(img)
    error('El archivo no pudo ser leído, verifica la ruta.');
end

if size(img, 3) == 3
    img = rgb2gray(img);
end

[width, height] = size(img);
img_flat = img(:);

% Función para generar histograma
function hist = generate_hist(img)
    hist = zeros(256, 1);
    img_flat = img(:);
    for i = 1:length(img_flat)
        hist(img_flat(i) + 1) = hist(img_flat(i) + 1) + 1;
    end
end

% Generar histograma
hist = generate_hist(img);
hist_norm = hist / (width * height);

% Calcular función de probabilidad acumulada
cpf = zeros(length(hist), 1);
cpf(1) = hist_norm(1);
for i = 2:length(hist_norm)
    cpf(i) = cpf(i-1) + hist_norm(i);
end

% Escalar a rango [0, 255] y convertir a uint8
scaled_cpf = uint8(cpf * 255);

% Aplicar mapeo a imagen original
img_new = reshape(scaled_cpf(double(img_flat) + 1), size(img));

% Generar histograma de la imagen nueva
new_hist = generate_hist(img_new);
new_hist_norm = new_hist / (width * height);

% Mostrar imagen original y su histograma
figure;
subplot(1, 2, 1);
imshow(img);
title('Imagen original');

subplot(1, 2, 2);
bar(0:255, hist_norm);
title('Histograma original');
xlabel('Intensidad');
ylabel('Conteo');

% Mostrar imagen ecualizada y su histograma
figure;
subplot(1, 2, 1);
imshow(img_new);
title('Imagen procesada');

subplot(1, 2, 2);
bar(0:255, new_hist_norm);
title('Histograma ecualizado');
xlabel('Intensidad');
ylabel('Conteo');

% Mostrar la función de distribución acumulada
figure;
plot(0:255, scaled_cpf);
title('Función de distribución acumulada');
xlabel('Intensidad original');
ylabel('Intensidad respuesta');
