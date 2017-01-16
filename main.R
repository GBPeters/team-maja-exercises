##
# Main script, loads functions from lesson6.R
# 13-01-17, Team Maja - Simon Veen & Gijs Peters
#
source("./R/lesson6.R")

# Download Data
downloadAndExtract(DL_PLACES)
downloadAndExtract(DL_RAILWAYS)

# Load shapefiles
places <- loadShapeFile("places")
railways <- loadShapeFile("railways")

# Reproject shapefiles
placesRD <- reproject(places)
railwaysRD <- reproject(railways)

# Select industrial railways
industrial <- selectIndustrialRailways(railwaysRD)
plot(industrial, axes=T)

# Select cities within range
buff <- bufferGeometries(industrial)
spoints <- selectPointsInBuffer(buff, placesRD)

# Print points, should be only one
print(spoints)

# Plot on Leaflet
plotLeaflet(spoints, buff)

# The tiny track of industrial railway is in Utrecht! Which, according to OSM, has 100000 inhabitants.