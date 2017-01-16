##
# Lesson 6
# Team Maja - Simon Veen & Gijs Peters
# 16-01-17
# 

# imports
library(rgdal)
library(rgeos)
library(leaflet)

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
#' @title bufferGeometries
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Create buffer around lines
#' @param sdf spatial dataframe to create buffer for
#' @param range The target search (buffer) range
#' @return A SpatialPolygons object containing the buffer
bufferGeometries <- function(sdf, range=RANGE) {
  buff <- gBuffer(sdf, width=range, byid=T)
  return(buff)
}

##
#' @title selectPointsInBuffer
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Select points within range of target Spatial Dataframe
#' @param buffer The buffer spatial dataframe to find points in
#' @param points The points to find points in
#' @return A SpatialPointsDataframe containing the points within range
selectPointsInBuffer <- function(buffer, points) {
  spoints <- gIntersection(points, buffer, id=as.character(points$osm_id), byid=T)
  splaces <- points[points$osm_id == rownames(spoints@coords),]
  return(splaces)
}

##
#' @title plotLeaflet
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Plots the buffer and the first item from places onto a leaflet basemap
#' @param places A SpatialPointsDataFrame containing cities
#' @param buffer A SpatialPolygonsDataFrame
plotLeaflet <- function(places, buffer) {
  plcproj <- spTransform(places, CRS="+init=epsg:4326")
  coords <- plcproj@coords
  lon = coords[1, 1]
  lat = coords[1, 2]
  name = plcproj$name[1]
  buffproj <- spTransform(buffer, CRS="+init=epsg:4326")
  m <- leaflet(data=buffproj) %>% addTiles()
  m <- m %>% addPolygons()
  m %>% addMarkers(lon, lat, popup=name)
}
