##
# Main script, loads functions from lesson6.R
# 13-01-17, Team Maja - Simon Veen & Gijs Peters
#

# Imports
require(tmap) || install.packages("tmap")
require(mime) || install.packages("mime")
require(sp) || install.packages("sp")
require(raster) || install.packages("raster")

source("./R/downloadRastersIntoBrick.R")
source("./R/8_createLinearModel.R")
source("./R/downloadAndExtract.R")
source("./R/8_calculateZonalRMSE.R")

# Constants

# Load Gewata Data into raster brick
br <- downloadRastersIntoBrick("https://raw.githubusercontent.com/GeoScripting-WUR/AdvancedRasterAnalysis/gh-pages/data",
                         "Gewata", c("B1", "B2", "B3", "B4", "B5", "B7"), ext="rda", extras="vcfGewata.rda")

# Load training polygons
downloadAndExtract("https://github.com/GeoScripting-WUR/AdvancedRasterAnalysis/raw/gh-pages/data/trainingPoly.rda")
load("./data/trainingPoly.rda")

# Preprocessing, remove values higher than 100 in VCF
br[["vcfGewata"]][br[["vcfGewata"]] > 100] <- NA
for (n in 1:6) {
  br[[n]][br[[n]] > 10000] <- NA
}


# Plot pairwise correlations between raster layers
#pairs(br)

# Create model
fit <- createLinearModel(br, "vcfGewata")
summary(fit)

# Calculate RMSE
rmsebr <- brick(predict(br, model=fit), br[["vcfGewata"]])
names(rmsebr) <- c("predictions", "actual")
rmse <- calculateZonalRMSE(rmsebr, predict="predictions", actual="actual")

# Calculate RMSE for training polygon classes
rmses <- calculateZonalRMSE(rmsebr, predict="predictions", actual="actual", zonepolygons = trainingPoly, zonevar="Class")

print(rmse)
print(rmses)
