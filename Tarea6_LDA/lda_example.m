% Lectura de los datos
wine_quality = readtable("winequality/winequality-red.csv");
quality = categorical(wine_quality.quality);
data = table2array(wine_quality);
data = data(:, 1:end-1);

% Determinacion del numero de clases presente
classes = unique(quality);
num_classes = length(classes);

% Aplicacion de LDA
[Y, W, lambda] = LDA(data, quality);

% Graficacion de los datos
graph_data = Y(:, 1:3);
for i=1:num_classes
    current_data = graph_data(quality==classes(i), :);
    scatter3(current_data(:,1), current_data(:,2), current_data(:,3), ...
        10, 'filled')
    hold on
end
title('LDA, 3 dimensiones')
legend(classes)
hold off

figure
[coeff, scores] = pca(data);
for i=1:num_classes
    current_data = scores(quality==classes(i), 1:3);
    scatter3(current_data(:,1), current_data(:,2), current_data(:,3), ...
        10, 'filled')
    hold on
end
title('PCA, primeros 3 componentes')
legend(classes)