function generar_rostro_GUI
% Cargar datos a utilizar para generar los puntos del rostro: media y
% matriz de componentes principales. Se utilizan los parámetros de ajuste 
% obtenidos para limitar la interfaz a valores a 3 desviaciones estándar de
% la media 0
load("faces_eigenvecs.mat", "pcV")
load("faces_mean.mat", "mu")
load("alphas_caras.mat", "alphas")

% Crear figura sobre la que se graficará el rostro
f = figure('Name', 'Generar rostros con modelo estadístico de forma', ...
    'Position',[100 100 600 600], 'NumberTitle','off');

% Se muestra el primer rostro como base de la interfaz
ax = axes('Parent', f, 'Position',[0.1 0.4 0.8 0.55]);
cara1 = imread("BioID_0001.pgm");


% Iniciar los parámetros ajustados a la cara de fondo
alpha = [67.96569,	-8.3865,	33.8527,	-3.3955];

% Generar rostro mediante PCA
new_face = alpha*pcV' + mu;
graph_face(new_face)

% Los límites de cada parámetro están dados por los máximos y mínimos
% encontrados en el PCA de las 100 imágenes
mins = min(alphas, [], 1);
maxs = max(alphas, [], 1);
% Crear botones deslizables para ajustar parámetros alpha
slider_pos_y = linspace(0.3, 0.05, 4);

% Barras deslizantes
sliders = gobjects(1,4);

% Texto
labels = gobjects(1,4);

% Cajas de texto editables. Muestran el valor actual del parámetro
edit_boxes = gobjects(1,4);
for j=1:4
    min_val = mins(j);
    max_val = maxs(j);

    % Texto que indica el parámetro que se ajusta
    labels(j) = uicontrol('Style','text', ...
    'Position',[50 100 * slider_pos_y(j) * 6 150 20], ...
    'String', sprintf('Alfa %d [%.1f, %.1f]', j, min_val, max_val), ...
    'FontSize', 10);

    % Barras deslizantes para manipular el valor del parámetro
    sliders(j) = uicontrol('Style','slider', ...
    'Min', min_val, 'Max', max_val, ...
    'Value', alpha(j), ...
    'Position',[200 100 * slider_pos_y(j) * 6 300 20], ...
    'Callback', @(src, ~) sliderCallback(j));

    % Cajas de texto editable para mostrar el valor actual del parámetro o 
    % para ajustarlo de forma exacta
    edit_boxes(j) = uicontrol('Style', 'edit', ...
    'String', num2str(alpha(j), '%.2f'), ...
    'Position', [510 100 * slider_pos_y(j) * 6 60 20], ...
    'Callback', @(src, ~) editCallback(j));
end

% Actualización de la cara cuando se ajustan los parámetros en la interfaz

    % Actualización cuando se mueve una barra deslizante
    function sliderCallback(idx)
        alpha(idx) = sliders(idx).Value; % Re-evaluar parámetro alfa
        edit_boxes(idx).String = sprintf('%.2f', alpha(idx)); % Ajustar cajas de texto
        new_face = alpha * pcV' + mu; % Encontrar nueo rostro
        graph_face(new_face) % Graficar nuevo rostro
    end

    % Actualización cuando se alteran las cajas de texto
    function editCallback(index)
    val = str2double(edit_boxes(index).String); % obtener valor numérico del texto
    if isnan(val) % Error si no es un número
        return;
    end
    val = max(sliders(index).Min, min(sliders(index).Max, val)); % Limitar al rango adecuado
    alpha(index) = val; % Actualizar alfa
    sliders(index).Value = val;  % Actualizar barra deslizante
    edit_boxes(index).String = sprintf('%.2f', val);  % Actualizar caja de texto
    new_face = alpha * pcV' + mu;
    graph_face(new_face); % Graficar nueva cara
    end

    % Función para graficar la cara dada lista de coordenadas (1x40)
    function graph_face(point_list)
        cla(ax); % Limpiar imagen
        imshow(cara1, 'Parent',ax) % Volver a graficar rostro
        hold(ax, "on")

        points = reshape(point_list, 2, [])'; % Darle forma de matriz a los 
                                              % puntos (20, 2)
        
        % Struct donde se indica a que parte del cuerpo pertenece cada
        % índice
        partes = {
        [3, 18, 4, 19, 3], 'Labios';
        [10, 1, 11, 10], 'Ojo Izquierdo';
        [12, 2, 13, 12], 'Ojo Derecho';
        [16, 15, 17, 16], 'Nariz';
        [20, 14, 8, 7, 6, 5, 9, 20], 'Contorno'
        };
        
        % Se grafica cada parte del cuerpo, uniendo los puntos
        for i = 1:size(partes,1)
            idx = partes{i,1};
            plot(ax, points(idx,1), points(idx,2), 'r.-', 'DisplayName', partes{i,2});
        end

        hold(ax, 'off')
    end

end
