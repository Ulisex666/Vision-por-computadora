% Se empieza leyendo la imagen y convirtiendola a double%
img = imread("Fig3.45(a).jpg");
img = double(img);

% Funcion para hacer padding y agregar ceros a los extremos de la imagen
% De esta manera, hacemos la convolucion sin perder informacion
function padded_img = padding(m)
    padded_img = [zeros(1,size(m,2)+2); [zeros(size(m,1),1), m, ...
        zeros(size(m,1),1)]; zeros(1,size(m,2)+2)];
end

% Imagen con ceros agregados
pad_img = padding(img);

% Operadores de sobel para parcial en x e y
sobel_x = [-1 -2 -1; 0 0 0; 1 2 1];
sobel_y = [-1 0 1; -2 0 2; -1 0 1];

% Creacion de las matrices donde se guardaran los resultados
[rows, cols] = size(pad_img);
gx = zeros(size(img));
gy = zeros(size(img));

% Proceso de convolucion. Se realiza con ambos operadores para
% ahorrar tiempo de computo. Al hacerlo sobre pad_img, no se
% pierde informacion
for i=2:rows-1
    for j=2:cols-1
        f = pad_img(i-1:i+1, j-1:j+1);
        gx(i-1, j-1) = sum(sum(sobel_x.*f));
        gy(i-1,j-1) = sum(sum(sobel_y.*f));
    end
end

% Obtenemos la magnitud del gradiente
grad_norm = sqrt(gx.^2 + gy.^2);

% Obtenemos las direcciones de los vectores
grad_dir = atan(gy ./ gx);

%%%% Graficacion de los resultados %%%

% Componentes x e y
f1 = figure('Name', 'Resultados');
subplot(2,2,1);
imagesc(gx);
title('Componente X del gradiente');
set(gca,'XTick',[], 'YTick', []);
axis square;


subplot(2,2,2);
imagesc(gy);
title('Componente Y del gradiente');
set(gca,'XTick',[], 'YTick', []);
axis square;


%%% Valor de la norma y direccion del gradiente
subplot(2,2,3);
imagesc(grad_norm);
title('\nabla f');
set(gca,'XTick',[], 'YTick', []);
axis square;


subplot(2,2,4);
imagesc(grad_dir);
title('\theta');
set(gca,'XTick',[], 'YTick', []);

colormap("gray");
axis square;

%%% Nueva figura, resultado del quiver para la gradiente
f2 = figure('Name', 'Vector con quiver');
q = quiver(gx, gy, 1);

