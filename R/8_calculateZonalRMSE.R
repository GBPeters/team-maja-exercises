#

##
#' @title calculateZonalRMSE
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Calculate RMSE from raster
#' @param actual A Raster Layer containing the actual values
#' @param predicted A Raster Layer containing the predicted values
#' @return The RMSE
calculateZonalRMSE <- function(rbrick, actual, predicted, zonepolygons=NULL, zonevar=NULL) {
  if (is.null(zonevar) && !is.null(zonepolygons)) {
    stop("if zones is set, zonevar should not be null")
  }
  actual <- rbrick[[actual]]
  predicted <- rbrick[[predicted]]
  sqe <- (predicted - actual) ^ 2
  if (!is.null(zonepolygons)) {
    rzones <- rasterize(zonepolygons, rbrick, zonevar)
    rmse <- zonal(sqe, rzones)
    rmse <- sqrt(rmse[,"mean"])
    names(rmse) <- unique(zonepolygons@data[,zonevar])
  } else {
    rmse <- sqrt(extract(sqe, extent(rbrick), fun = mean, na.rm=T))
    names(rmse) <- "Full extent"
  }
  return(rmse)
}