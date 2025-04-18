import numpy as np
import matplotlib.pyplot as plt
import cv2 as cv

def image_resize(img_path:str, new_width:int, new_height:int,
                 show_result:bool = False):
    '''Function used to change the size of an image by the nearest
    neighbor and bilinear interpolation methods. 
     
    It can show the original images and the two resulting ones.
    
    img_path: location path to the image \\
    new_height: desired height for the resulting image \\
    new_width: desired width for the resulting image \\
    show_result: show images for comparison. Default is False
    
    returns: (img using nearest neighbor, img using bilinear interpolation)'''
    
    # The modifier 0 indicates that the image must be read in grayscale 
    img = cv.imread(img_path, 0)
    
    # We obtain the width and height from the original image
    height, width = img.shape
    
    # A new empty matrix is created with the desired dimensions. It's gonna be
    # filled with the corresponding values based on the algorithm being used.
    # The data type is uint8, so the values are in the range [0,255]
    new_img_nn = np.empty((new_height, new_width), dtype=np.uint8)
    new_img_bi = np.empty((new_height, new_width), dtype=np.uint8)
    
    # We calculate the ratio within the original dimensions of the image and
    # the desired ones
    height_ratio = height/new_height
    width_ratio = width/new_width    
    
    # NEAREST NEIGHBOR METHOD.
    for row in range(new_height):
        for column in range(new_width):
            # Going from the new coordinates to the original ones using the
            # corresponding ratio. The int() function rounds the number down,
            # giving us the nearest pixel
            x = int(column * width_ratio)
            y = int(row * height_ratio)
            # Using the obtained values in the resized image
            new_img_nn[row, column] = img[y,x]
            
    # BILINEAR INTERPOLATION METHOD.
    for row in range(new_height):
        for column in range(new_width):
            # i = row, j = column
            
            # Going from the new coordinates to the original ones.
            x = column * width_ratio 
            y = row * height_ratio 

            # Calculating the position of the four nearest pixels. 
            x_low, y_low = int(np.floor(x)), int(np.floor(y)) 
            # We need to consider the edge cases using the min() function, to
            # stay inside the bounds of the image
            x_top, y_top = min(x_low + 1, width - 1), min(y_low + 1, height - 1)  

            # Differences required in the equation
            x_diff = x - x_low 
            y_diff = y - y_low

            # Coordinates of the closest pixels
            top_left = img[y_low, x_low]
            top_right = img[y_low, x_top]
            bottom_left = img[y_top, x_low]
            bottom_right = img[y_top, x_top]

            # Bilinear interpolation formula
            inter_value = ((1 - x_diff) * (1 - y_diff) * top_left + 
                         x_diff * (1 - y_diff) * top_right +
                         (1 - x_diff) * y_diff * bottom_left +
                         x_diff * y_diff * bottom_right)

            new_img_bi[row, column] = inter_value.astype(np.uint8)

    # Shows the original images and the resized ones for comparison, adjusting
    # the pixel size so they have an equal size on the screen
    if show_result:
        fig, (ax1,ax2,ax3) = plt.subplots(1, 3)
        ax1.imshow(img, cmap='gray')
        ax1.set_title('Original image')
        ax1.axis('off')
        ax2.imshow(new_img_nn, cmap='gray')
        ax2.set_title('Nearest neighbor method')
        ax2.axis('off')
        ax3.imshow(new_img_bi, cmap='gray')
        ax3.set_title('Bilinear interpolation method')
        ax3.axis('off')
        plt.show()
    
    return new_img_nn, new_img_bi


if __name__=='__main__':
    result = image_resize('reporte/imgs/rose.jpg', 500, 500, show_result=True)
    # cv.imwrite('expanded_img_bi2nn.png', result[0])
    # cv.imwrite('expanded_img_bi2bi.png', result[1])