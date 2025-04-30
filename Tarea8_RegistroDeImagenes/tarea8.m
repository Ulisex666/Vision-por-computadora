%% Generar nube de puntos para las 1520 imagenes
% https://www.bioid.com/face-database/
% Cargar base de datos
load data_points

% Primera imagen como referencia
face1 = imread("Im_Faces\BioID_0001.pgm");

% Visualizacion de la primera imagen
imagesc(face1);
colormap gray

% Visualización de las 1520 nubes de puntos, correspondientes a cada cara
no_imgs = 1520;
hold on
for n=1:no_imgs
    plot(squeeze(data(n,1,:)), squeeze(data(n,2,:)), '.')
end
hold off
title("Nube de puntos para las 1520 imagenes")

%% Proceso de registro de imagenes
% Puntos correspondientes a la primera imagen
puntos_referencia = squeeze(data(1,:,:))'; % Se reducen a dos dimensiones

% Se eliminan los primeros puntos de los datos, no se necesita hacer
% registro sobre ellos
data_reduced = data;
data_reduced(1,:,:) = [];
% Celda para guardar los puntos después del registro
registros = cell(no_imgs-1, 1);

for idx=1:(no_imgs-1)
    puntos_actual = squeeze(data_reduced(idx,:,:))';
    % Ajuste de la transformacion afin
    trans_matrix = fitgeotform2d(puntos_actual, puntos_referencia, 'affine');
    % Proceso de registro mediante metodo transformPointsForward
    res = trans_matrix.transformPointsForward(puntos_actual);
    % Se guardan los puntos de referencia registrados en la celda de
    % registros
    registros{idx} = res;
end

%% Encontrar mejores 99 puntos 
no_mejores_puntos = 99;
% Matriz donde se guardara la diferencia de los puntos registrados a los
% puntos de referencia
diferencias = zeros([1519, 2]);

for n = 1:(no_imgs-1)
    % Se selecciona un conjunto de puntos de la celda de registros
    puntos_dif = registros{n};
    % Se calcula la diferencia promedio en la dimension x e y
    delta_x = mean(puntos_dif(:,1) - puntos_referencia(:,1));
    delta_y = mean(puntos_dif(:,2) - puntos_referencia(:,2));
    % Se calcula la distancia euclideana
    dist = sqrt(delta_x^2 + delta_y^2);
    % Se guarda la distancia en la primera columna de la matriz de
    % diferencias
    diferencias(n,1) = dist;
    % Se guarda el indice en la segunda columna de la matriz de diferencias
    diferencias(n,2) = n;
end

% Se ordena la matriz de diferencias en sus filas, en orden ascendente de
% acuerdo a la primera columna, que contiene las distancias
diferencias = sortrows(diferencias);

% Se eligen las primeras 99 filas, correspondientes a los 99 puntos mas
% cercanos a la referencia
puntos_seleccionados = diferencias(1:no_mejores_puntos, 2);

%% Visualizacion de los mejores 99 puntos 
% Puntos sin registrar
figure;
imagesc(face1);
colormap gray
hold on

cmap_puntos = hot(99);
for n=1:99
    idx_actual = puntos_seleccionados(n);
    plot(squeeze(data(idx_actual,1,:)), squeeze(data(idx_actual,2,:)), ...
        '.', Color=cmap_puntos(n,:))
end
hold off
title("Nube de puntos para las mejores 99 imágenes originales")

%Puntos registrados
figure;
imagesc(face1);
colormap gray

hold on
for n=1:99
    idx_actual = puntos_seleccionados(n);
    puntos_actual = registros{idx_actual};
    plot(puntos_actual(:,1), puntos_actual(:,2), '.',  ...
        Color=cmap_puntos(n,:))
end
hold off
title("Nube de puntos para las mejores 99 imágenes registradas")
