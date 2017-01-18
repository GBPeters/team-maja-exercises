# Imports
library(mime)
source("./R/downloadAndExtract.R")

##
#' @title downloadRastersIntoBrick
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Downloads a collection of raster files into chosen directory, and loads them into a brick
#' @param rdir Remote directory
#' @param prefix File prefix
#' @param bands Band numbers or names
#' @param ext File extension
#' @param datadir Local directory to store data in
#' @param extras Extra layers to load into brick
#' @return A Raster Brick containing downloaded data
downloadRastersIntoBrick <- function(rdir, prefix, bands, ext="tif", datadir="./data", extras=c()) {
  bandsnoext <- sapply(bands, function(b) {paste0(prefix, b)})
  bandnames <- sapply(bandsnoext, function(b) {paste0(b, ".", ext)})
  bandnames <- c(bandnames, extras)
  bandsnoext <- c(bandsnoext, gsub("\\..*$", "", extras))
  rfiles <- sapply(bandnames, function(b) {file.path(rdir, b)})
  lfiles <- sapply(bandnames, function(b) {file.path(datadir, b)})
  sapply(rfiles, downloadAndExtract, datadir="./data")
  if (ext == "tif") {
    rasters <- sapply(lfiles, raster)
  } else if (ext == "rda") {
    sapply(lfiles, load, envir=.GlobalEnv)
    rasters<- sapply(bandsnoext, get)
  }
  br <- brick(rasters)
  names(br) <- bandsnoext
  return(br)
}
