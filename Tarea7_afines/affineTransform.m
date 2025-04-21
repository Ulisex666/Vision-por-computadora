function new_img = affineTransform(img, tx, ty, scale, theta)
%
% AFFINETRANSFORM Applies affine transformations to input image with given
% parameters.
% 
% NEWIMG = AFFINETRANSFORMS(img, tx, ty, scale, theta) applies x 
% translation, y translation, scaling and rotation with given parameters
% in that specific order.

    % Type checking
    arguments
        img (:,:) {mustBeNumeric, mustBeNonempty}
        tx (1,1) {mustBeNumeric, mustBeFinite}
        ty (1,1) {mustBeNumeric, mustBeFinite}
        scale (1,1) {mustBeNumeric, mustBePositive}
        theta (1,1) {mustBeNumeric, mustBeFinite}
    end
    
    % Reading image size
    [height, width] = size(img);
    % Generating new image with same size
    new_img = zeros(size(img));
    % Matrix for translation on x and y axis
    translation_matrix = [1, 0, tx; 0, 1, ty; 0, 0, 1];
    % Matrix for scaling in the same factor over the x and y axis
    scale_matrix = [scale, 0, 0; 0, scale, 0; 0, 0, 1];
    % Matrix for rotation over the origin (top left corner)
    rot_matrix = [cosd(theta), sind(theta), 0;
        -sind(theta), cosd(theta), 0;
        0, 0, 1];

    % Transformation matrix. Translation, scaling and then rotation
    trans_matrix = translation_matrix * scale_matrix * rot_matrix;
    
    % Iterating over every pixel, not efficient but practical
    for row=1:height
        for col=1:width
            % Reverse transformation. We start on the output image, and
            % calculate position in original image. Use interpolation to
            % get the right color
            new_pos = [row; col; 1];
            % Position in original image. Matlab recommends inverted bar
            % division over the use of inv(A).
            og_pos = trans_matrix\new_pos;
            % x and y coordinates in original position. x indicates the 
            % row for the axis used in image analysis
            x = og_pos(2);
            y = og_pos(1);
            % Interpolation. Based on assignment 2:
            % 1. Deal with positions outside of the original image.
            % Let it stay black and continue with the next pixel
            if x<0 || x > width || y<0 || y > height
                continue
            end
            % Calculate neighbor pixels in original image. Making sure we
            % stay inside the image boundaries
            x_low = max(floor(x), 1); 
            y_low = max(floor(y), 1);
            x_top = min(x_low + 1, width);
            y_top = min(y_low+1, height);
            
            % Calculating four nearest pixels using coordinates
            top_left = img(y_low, x_low);
            top_right = img(y_low, x_top);
            bottom_left = img(y_top, x_low);
            bottom_right = img(y_top, x_top);
            
            % Needed for interpolation formula
            x_diff = x - x_low;
            y_diff = y - y_low;


            % Interpolation formula
            intensity_value = ((1 - x_diff) * (1 - y_diff) * top_left + ...
                     x_diff * (1 - y_diff) * top_right + ...
                     (1 - x_diff) * y_diff * bottom_left + ...
                     x_diff * y_diff * bottom_right);

            % Assigning value to pixel in new image
            new_img(row, col) = intensity_value;
        end
    end
    % Giving the right format to output image
    new_img = uint8(new_img);
end
