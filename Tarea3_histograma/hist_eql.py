import numpy as np
import cv2
import matplotlib.pyplot as plt

# Reading the files and asserting a correct path
img = cv2.imread('/media/ulisex/3AEEAC75EEAC2B59/Users/Ulises/Documents/laptop/Nova 3/File_Restore/Screenshot_20201201_191429_com.instagram.android.jpg', 0)
assert img is not None, "file could not be read, check path"

# Getting the dimensions of the image and creating a flat
# copy for efficiency
width, height = img.shape
img_flat = img.flatten()
# Function for creating the histogram. We try not to use 
# the predefined functions
def generate_hist(img, int_levels=256):
    img_flat = img.flatten()
    # Creating an array of zeros for the histogram. Each
    # index corresponds to an intensity value, going from
    # 0 to 255
    hist = np.zeros(256, dtype=int)
    
    # We iterate over every pixel in the image, and when 
    # we encounter a specific intensity value we augment
    # its counter in the histogram by 1
    for pixel in img_flat:
        hist[pixel] += 1
        
    return hist

# Function for plotting an image next to its histogram
def plot_hist(img, hist, img_title:str, hist_title:str, file_name:str =None):
    fig, (ax1, ax2) = plt.subplots(1,2, layout='constrained')
    # Indicating the colormap and the correct range for the intensity values
    ax1.imshow(img, cmap='gray', vmin=0, vmax=255)
    ax1.set_title(img_title)
    ax1.axis('off')
    
    ax2.bar(np.arange(0,256,1), hist, width=1)
    ax2.set_title(hist_title)
    ax2.set_xlabel('Intensidad')
    ax2.set_ylabel('Conteo')
    fig.set_size_inches(7, 3, forward=True)
    # Given a file name, it saves the resulting image
    if file_name:
        fig.savefig(file_name, dpi=150)
    return

# Generating an histogram from the image
hist = generate_hist(img) 
# Normalizing the histogram dividing by the total amount
# of pixels in the image
hist_norm = hist/(width*height)

# Creating an empty array for the cumulative probability function.
# Same size as the histogram
cpf = np.zeros(len(hist))
# We make the first value equal to the normalized histogram
cpf[0] = hist_norm[0]

# We calculate the cumulative sum iterating over the histogram
# and adding the value at the current index to the previous sum
for i in range(1, len(hist_norm)):
    cpf[i] = hist_norm[i] + cpf[i-1]

# We scale the cpf to 0-255, so that it gives us the required
# intensity values
scaled_cpf = cpf*255
# Correct typing for image plotting
scaled_cpf = scaled_cpf.astype(np.uint8)

# We create the new image as a flat array. Using the original
# flat image and advanced indexing, we map the original value 
# to the equalized one, following the cpf
# For example, if the original pixel value is 0, it will look
# at the corresponding index in the cpf and assign the equalized
# value
img_new = scaled_cpf[img_flat]
# Correcting the shape of the new image
img_new = np.reshape(img_new, img.shape)

# Generating an histogram for the equalized image
new_hist = generate_hist(img_new)
new_hist_norm = new_hist / (width*height)

# Plotting results
plot_hist(img, hist_norm, 'Imagen original', 'Histograma original')
plot_hist(img_new, new_hist_norm, 'Imagen procesada', 'Histograma ecualizado')

fig, ax = plt.subplots()
ax.plot(scaled_cpf)
ax.set_title('Funcion de distribucion acumulada')
ax.set_xlabel('Intensidad original')
ax.set_ylabel('Intensidad respuesta')
#fig.savefig('cdf3.png')

plt.show()
