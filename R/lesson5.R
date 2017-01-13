##
# Lesson 5, functions for preprocessing Landsat data for NDVI calculations
# 13-01-17, Team Maja - Simon Veen & Gijs Peters

# Locations of downloadable data
DATA_LOCATIONS <- c("https://dl.dropboxusercontent.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz", 
                    "https://dl.dropboxusercontent.com/s/akb9oyye3ee92h3/LT51980241990098-SC20150107121947.tar.gz")
# Data folder
DATA_DIR <- "../data"

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
  untar(dest, exdir=datadir, extras="--overwrite")
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

