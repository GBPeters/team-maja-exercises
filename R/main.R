##
# Main script, loads functions from lesson5.R
# 13-01-17, Team Maja - Simon Veen & Gijs Peters
#
source("./R/lesson5.R")

# Download and extract data
downloadData()

# Create Bricks
l8brick <- createLandsatBrick("LC81970242014109", BANDS_8)
l5brick <- createLandsatBrick("LT51980241990098", BANDS_5)

# Crop bricks
crops <- cropRasterBricks(l5brick, l8brick, "l5crop.tif", "l8crop.tif")

# Mask clouds
masked <- lapply(crops, maskCloudsInBrick, masklayer=1)

# Calculate NDVI
ndvis <- lapply(masked, calculateNDVI, red=1, nir=2)

# Calculate difference
ndvis <- brick(ndvis)
diff <- calculateNDVIDiff(ndvis)
plot(diff)
