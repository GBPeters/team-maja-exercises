##
# Lesson 6
# Team Maja - Simon Veen & Gijs Peters
# 16-01-17
# 

# imports
library(rgdal)
library(rgeos)
library(raster)

# constants
DL_PLACES <- "http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip"
DL_RAILWAYS <- "http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip"
DATADIR <- "./data"
RD_NEW_P4S <- "+init=epsg:28992"
INDUSTRIAL = "industrial"
RANGE = 1000

##
#' @title downloadAndExtract
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Download and extract data for lessen 6
#' @param url The url to download from
#' @param datadir The directory to unpack the downloaded data in
downloadAndExtract <- function(url, datadir=DATADIR) {
  dir.create(datadir, showWarnings = FALSE)
  dest <- file.path(datadir, basename(url))
  download.file(url, dest)
  unzip(dest, exdir=datadir)
}

##
#' @title loadShapeFile
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Load a downloaded shapefile into a Spatial Dataframe
#' @param name The shapefile's name
#' @param datadir The folder containing the shapefile
#' @return a SpatialPointsDataframe, SpatialLinesDataframe or SpatialPolygonsDataframe
loadShapeFile <- function(name, datadir=DATADIR) {
  shp <- readOGR(datadir, name)
  return(shp)
}

##
#' @title reproject
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Reproject Spatial Dataframe to chosen CRS
#' @param sdf Spatial Dataframe to reproject
#' @param crs Default RD New, CRS to reproject to
#' @return A reprojected Spatial Dataframe
reproject <- function(sdf, crs=RD_NEW_P4S) {
  return(spTransform(sdf, crs))
}

##
#' @title selectIndustrialRailways
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Select industrial railways from railways sdf
#' @param railways Spatial Dataframe containing railways
#' @return Spatial Dataframe containing only industrial railways
selectIndustrialRailways <- function(railways) {
  return(railways[railways$type == INDUSTRIAL,])
}

##
#' @title selectPointsWithinRange
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Select points within range of target Spatial Dataframe
#' @param sdf The spatial dataframe to find points in
#' @param points The SpatialPointsDataframe to find points in
#' @param range The target search (buffer) range
#' @return A SpatialPointsDataframe containing the points within range
selectPointsWithinRange <- function(sdf, points, range=RANGE) {
  buff <- gBuffer(sdf, width=range, byid=T)
  plot (buff, axes=T)
  spoints <- gIntersection(points, buff, id=as.character(points$osm_id), byid=T)
  splaces <- points[points$osm_id == rownames(spoints@coords),]
  return(splaces)
}
