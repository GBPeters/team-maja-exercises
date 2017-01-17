##
# Main script, loads functions from lesson6.R
# 13-01-17, Team Maja - Simon Veen & Gijs Peters
#

require(tmap) || install.packages("tmap")
require(mime) || install.packages("mime")
require(sp) || install.packages("sp")

# Imports
source("./R/7_downloadAndReprojectMunicipalities.R")
source("./R/7_extractMeanValueForMunicipality.R")
source("./R/7_plotGreenness.R")

# Constants
DL_MODIS <- "https://raw.githubusercontent.com/GeoScripting-WUR/VectorRaster/gh-pages/data/MODIS.zip"
MODIS_FILE <- "data/MOD13A3.A2014001.h18v03.005.grd"


# Download Data
downloadAndExtract(DL_MODIS)

# Load Brick
ndvibrick <- brick(MODIS_FILE)

# Download municpalities
mun <- downloadAndReprojectAdminBorders(r=ndvibrick)

# Download provinces
prov <- downloadAndReprojectAdminBorders(r=ndvibrick, level=1)

# Add mean NDVI values for months to municipalities
mun <- extractMeanValueForMunicipality(ndvibrick[["January"]], mun, name="NDVI_January")
mun <- extractMeanValueForMunicipality(ndvibrick[["August"]], mun, name="NDVI_August")
mun <- extractMeanValueForMunicipality(mean(ndvibrick), mun, name="NDVI_Mean")
prov <- extractMeanValueForMunicipality(ndvibrick[["January"]], prov, name="NDVI_January")

# Print greenest municipalities
print(paste("January:", mun$NAME_2[mun$NDVI_Mean == max(mun$NDVI_Mean)]))
print(paste("August:", mun$NAME_2[mun$NDVI_August == max(mun$NDVI_August)]))
print(paste("Mean:", mun$NAME_2[mun$NDVI_January == max(mun$NDVI_January)]))
print(paste("January:", prov$NAME_1[prov$NDVI_January == max(prov$NDVI_January)]))

# Plot greenness!
plotGreenness(mun, "NDVI_January")
plotGreenness(mun, "NDVI_August")
plotGreenness(mun, "NDVI_Mean")
plotGreenness(prov, "NDVI_January")


