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
    zones <- unique(zonepolygons@data[zonevar])
    rmse <- c()
    for (z in zones) {
      zone <- zonepolygons[zonepolygons@data[,zonevar] == z,]
      rmse <- c(rmse, sqrt(extract(sqe, zone, fun = mean, na.rm=T)))
    }
    names(rmse) <- zones
  } else {
    rmse <- sqrt(extract(sqe, extent(rbrick), fun = mean, na.rm=T))
  }
  return(rmse)
}