##
# Main script, loads functions from lesson5.R
# 13-01-17, Team Maja - Simon Veen & Gijs Peters
#
source("./R/lesson5.R")

# Download and extract data
#downloadData()

# Create Bricks
l8brick <- createLandsatNDVIBrick("LC81970242014109")
l5brick <- createLandsatNDVIBrick("LT51980241990098")
raster::plotRGB(l8brick)
