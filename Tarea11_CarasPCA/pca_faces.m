% Cargamos los datos de las 100 mejores caras, obtenidad en la tarea
% anterior
load("best_faces.mat");
cara1 = imread("Im_Faces\BioID_0001.pgm");

% Se ajusta la forma de los datos, de tal forma que sea una matriz con 100
% filas, una por cada cara, y 40 columnas de pares (x,y) de las coordenadas
% de los puntos

datos_fila = [];
for i=1:100
    x = squeeze(best_faces(i,1, :))';
    y = squeeze(best_faces(i,2,:))';
    cara = reshape([x;y], 1, []);
    datos_fila = cat(1, datos_fila, cara);
end

% Se calcula la media de los 20 puntos de control
mu = mean(datos_fila, 2);

% Se ajustan los datos para que la media sea cero
adjust_data = datos_fila-mu;

% Se calcula un número limitado de los componentes principales utilizando 
% la función proporcionada en clase

pcI = mypca(adjust_data', 10)';

% Regresión lineal de los datos utilizando los componentes principales
A = inv(pcI*pcI');
B = pcI * datos_fila';

alphas = A*B; % Parámetros de la regresión
modelos = alphas' * pcI + repmat(mu,1,40);

% Evaluando la variación de los parámetros para cada componente principal
figure
subplot(2,2,1)
hist(alphas(1,:),15)
title('Parámetro \alpha_1')

subplot(2,2,2)
hist(alphas(2,:),15)
title('Parámetro \alpha_2')

subplot(2,2,3)
hist(alphas(3,:),15)
title('Parámetro \alpha_3')

subplot(2,2,4)
hist(alphas(4,:),15)
title('Parámetro \alpha_4')

% Evaluando resultado del modelo
new_alpha = alphas(:,1)';
new_face = new_alpha * pcI +  152.53;

figure
imagesc(cara1)
colormap gray
hold on
for i = 1:2:40
    plot(new_face(i), new_face(i+1), '.r')
end