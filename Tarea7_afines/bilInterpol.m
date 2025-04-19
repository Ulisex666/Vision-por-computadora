function newImg = bilInterpol(img, new_height, new_width)
%
% BILINTERPOL Applies bilinear interpolation to input image with an 
% output of given size.
% 
% NEWIMG = BILINTERPOL(IMG, 500, 500) takes the original image and returns
% a reescaled one with size [500, 500].

validateattributes(img, {'numeric'}, {'2d', 'nonempty'}, ...
    mfilename, 'img', 1);
validateattributes(new_height, {'numeric'}, {'scalar', 'integer', ...
    'positive'}, mfilename, 'new_height', 2);
validateattributes(new_width, {'numeric'}, {'scalar', 'integer', ...
    'positive'}, mfilename, 'new_width', 3);


[height, width] = size(img);
newImg = zeros([new_height, new_width]);

width_ratio = width/new_width;
height_ratio = height/new_height;

for row=1:new_height
    for col=1:new_width
        x = col*width_ratio;
        y = row*height_ratio;

        x_low = max(floor(x), 1);
        y_low = max(floor(y), 1);

        x_top = min(x_low + 1, width);
        y_top = min(y_low+1,height);

        x_diff = x - x_low;
        y_diff = y - y_low;
        
        top_left = img(y_low, x_low);
        top_right = img(y_low, x_top);
        bottom_left = img(y_top, x_low);
        bottom_right = img(y_top, x_top);

        inter_value = ((1 - x_diff) * (1 - y_diff) * top_left + ...
                     x_diff * (1 - y_diff) * top_right + ...
                     (1 - x_diff) * y_diff * bottom_left + ...
                     x_diff * y_diff * bottom_right);

        newImg(row, col) = inter_value;
    end
end

newImg = uint8(newImg);

end
