clear 
close all

% Cargar los datos de las 100 mejores caras
load("best_faces.mat");
cara1 = imread("BioID_0001.pgm");

% Reorganizar los puntos (x,y) en una sola fila por cara: (100 × 40)
datos_fila = [];
for i = 1:100
    x = squeeze(best_faces(i,1,:))';  % Vector fila de x
    y = squeeze(best_faces(i,2,:))';  % Vector fila de y
    cara = reshape([x; y], 1, []);    % Alternar x1 y1 x2 y2 ...
    datos_fila = cat(1, datos_fila, cara);
end

% Se realiza PCA sobre los datos reordenados
% Cada fila es una cara, cada columna una coordenada 
[coeff, score, latent, ~, explained, mu] = pca(datos_fila);

% Se toman 4 componentes, que explican el 99% de la varianza en los datos
% originales
k = 4;
alphas = score(:, 1:k);         % Proyecciones de los datos, 4 parámetros 
pcV = coeff(:, 1:k);         % Eigenvectores 
pcD = latent(1:k) / sum(latent);  % Porcentaje de varianza explicada


% Reconstrucción de los datos
modelos = alphas*pcV' + mu; 

% Varianza acumulada explicada por componente
varianza_acumulada = cumsum(explained); 

% Graficar varianza
figure
plot(varianza_acumulada, 'o-','LineWidth',2)
xlabel('Número de componentes principales')
ylabel('Varianza explicada acumulada (%)')
title('Varianza explicada acumulada por PCA')
grid on

% Histograma de los 4 parámetros 
figure
subplot(2,2,1)
histogram(alphas(:,1))
title('Parámetro \alpha_1')
% Min = -0.049, Max = 0.27

subplot(2,2,2)
histogram(alphas(:,2))
title('Parámetro \alpha_2')
% Min = 0.004, Max = 0.23

subplot(2,2,3)
histogram(alphas(:,3))
title('Parámetro \alpha_3')
% Min = -0.25, Max = 0.36

subplot(2,2,4)
histogram(alphas(:,4))
title('Parámetro \alpha_4')
% Min = -0.32, Max = 0.48

% Generando una cara dados parámetros aleatorios
new_alpha = alphas(1,:);  
new_face = new_alpha * pcV' + mu;

% Visualización sobre la imagen

% Se convierte de lista de puntos a una matriz
points = [];
for i=1:2:40
    points = cat(1, points, [new_face(i), new_face(i+1)]);
end

% Se anota qué puntos corresponden a qué parte de la cara
idx_labios = [3, 18, 4, 19, 3];
idx_ojo_izquierdo = [10, 1, 11];
idx_ojo_derecho = [12, 2, 13, 12];
idx_nariz = [16, 15, 17, 16];
idx_contorno = [20, 14, 8, 7, 6, 5, 9, 20];


figure
imagesc(cara1)
colormap gray
hold on
% Graficando labios
plot(points(idx_labios,1), points(idx_labios,2), 'r.-')

% Graficando ojos
plot(points(idx_ojo_izquierdo, 1), points(idx_ojo_izquierdo, 2), 'r.-')
plot(points(idx_ojo_derecho, 1), points(idx_ojo_derecho, 2), 'r.-')

% Graficando nariz
plot(points(idx_nariz, 1), points(idx_nariz, 2), 'r.-')

% Graficando contorno de la cara
plot(points(idx_contorno, 1), points(idx_contorno, 2), 'r.-')
hold off
