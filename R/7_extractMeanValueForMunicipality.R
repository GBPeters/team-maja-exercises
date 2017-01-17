##
#' @title extractMeanValueForMunicipality
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Extracts mean values and adds them to a new municipality SpatialPolygonsDataFrame
#' @param r Raster Layer to extract values from
#' @param mun SpatialPolygonsDataFrame to use for extraction
#' @param name Character, name for the new value column
#' @return A SpatialDataFrame containing the municipality data and a column for extracted values
extractMeanValueForMunicipality <-function(r, mun, name="mean_extracted_value") {
  oldname = names(r)[1]
  ext <- extract(r, mun, fun=mean, df=T, sp=T, na.rm=T)
  colnames(ext@data)[which(names(ext@data) == oldname)] <- name
  return(ext)
}