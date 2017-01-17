# Imports
library(sp)

##
#' @title downloadAndRepojectAdminBorders
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Downloads municipality data from GADM and reprojects it to given raster
#' @param country The country code to download municipality for
#' @param r The raster object to reproject for
#' @return A SpatialPolygonsDataFrame containing reprojected municipalities
downloadAndReprojectAdminBorders <- function(country="NLD", r, level=2) {
  mun <- getData('GADM',country=country, level=level)
  p4s <- proj4string(r)
  munproj <- spTransform(mun, p4s)
  return(munproj)
}