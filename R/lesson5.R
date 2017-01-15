##
# Lesson 5, functions for preprocessing Landsat data for NDVI calculations
# 13-01-17, Team Maja - Simon Veen & Gijs Peters

# imports
library(raster)
library(dismo)

# Locations of downloadable data
DATA_LOCATIONS <- c("https://dl.dropboxusercontent.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz", 
                    "https://dl.dropboxusercontent.com/s/akb9oyye3ee92h3/LT51980241990098-SC20150107121947.tar.gz")
# Data folder
DATA_DIR <- "./data"

# Bands
BANDS_5 <- c("band3", "band4", "cfmask")
BANDS_8 <- c("band4", "band5", "cfmask")

# Plot constants
TITLE = "NDVI Differences between 1990 and 2014"

##
#' @title downloadAndExtract
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Function for downloading and extracting data from specified url
#' @param url The file url
#' @param datadir the directory to store downloaded data in. Data will be extracted in this directory.
#' @example downloadAndExtract("https://dl.dropboxusercontent.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz")
downloadAndExtract <- function(url, datadir=DATA_DIR) {
  dest = file.path(datadir, basename(url))
  download.file(url, dest)
  untar(dest, exdir=datadir)
}

##
#' @title downloadData
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Create data folder and download specified files
#' @param locations a vector containing urls
#' @param datadir the data directory to be used for downloading data
downloadData <- function(locations=DATA_LOCATIONS, datadir=DATA_DIR) {
  dir.create(datadir, showWarnings = FALSE)
  lapply(locations, downloadAndExtract)
  print (list.files(datadir))
}

##
#' @title createLandsatBrick
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Create raster brick from Landsat files
#' @param prefix the start of the Landsat filenames to select files on
#' @param datadir the data directory for searching data in
#' @return a raster brick containing data from the landsat files found by the pattern
#' @example createLandsatBrick("LC81970242014109")
createLandsatBrick <- function(prefix, bands, datadir = DATA_DIR) {
  # Create pattern for matching relevant files, based on the prefix and the band names
  bands = paste(bands, collapse="|")
  pattern <- paste0("^", prefix, ".*(", bands, ")\\.tif$")
  # Get relevant file list
  files <- list.files(datadir, pattern = pattern)
  files <- paste(datadir, files, sep="/")
  print (files)
  # Create raster layers and brick
  rasters = lapply(files, raster)
  lbrick = brick(rasters)
  return (lbrick)
}

##
#' @title cropRasterBricks
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Crops two raster bricks to their shared extent
#' @param brick1 The first brick
#' @param brick2 The second brick
#' @param filename1 Filename for the first crop
#' @param filename2 Filename for the second crop
#' @return a vector with two bricks
cropRasterBricks <- function(brick1, brick2, filename1="", filename2="") {
  crop1 <- crop(brick1, brick2, filename=filename1, overwrite=TRUE)
  crop2 <- crop(brick2, crop1, filename=filename2, overwrite=TRUE)
  return(c(crop1, crop2))
}

##
#' @title maskCloudsInBrick
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Uses one cloud layer to mask others in the raster brick
#' @param lbrick The Landsat raster brick
#' @param masklayer The number or name of the mask layer
#' @param filename Filename for writing to disk
#' @return a brick with the masked layers
maskCloudsInBrick <- function(lbrick, masklayer=1, filename="") {
  mask <- lbrick[[masklayer]]
  maskedbrick = dropLayer(lbrick, masklayer)
  maskedbrick <- overlay(maskedbrick, mask, fun=function(x, y) {x[y != 0] <- NA; return(x)}, filename=filename)
  return(maskedbrick)
}

##
#' @title calculateNDVI
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Calculate the NDVI based on a Red and NIR layer
#' @param lbrick The raster brick to use for calculations
#' @param red The layer name or number of the red band
#' @param nir The layer name or number of the NIR band
#' @return A raster layer with NDVI
calculateNDVI <- function(lbrick, red, nir, filename="") {
  ndvi <- calc(lbrick, fun=function(r) {(r[[nir]] - r[[red]]) / (r[[nir]] + r[[red]])}, filename=filename)
  return(ndvi)
}

##
#' @title calculateNDVIDiff
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Calculates the difference between NDVI in the first and the last layer of provided raster brick, assuming it is a time series. With more than two layers, the middle layers will be ignored.
#' @param ndvibrick A raster brick containing layers with NDVI values.
#' @param filename The file to store the resulting raster in
#' @return A raster containing the NDVI difference.
calculateNDVIDiff <- function(lbrick, filename="") {
  diff <- calc(lbrick, fun=function(r) {r[[length(r)]]-r[[1]]}, filename=filename)
  return(diff)
}

##
#' @title plotDiffMap
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Plots a raster onto a Google satellite image
#' @param The (difference) raster to plot
plotDiffMap <- function(diffraster) {
  # Reproject to  web mercator
  projdiff <- projectRaster(diffraster, crs="+init=epsg:3857", filename="data/projdiff.tif", overwrite=TRUE)
  # Get map and plot tiles
  gmap(projdiff, type="hybrid", scale=1)
  plot(map, legend=F, main=TITLE)
  plot(projdiff, add=T, legend=F, alpha=0.8)
}


