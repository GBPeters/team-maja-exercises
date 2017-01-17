# Imports
library(tmap)
library(RColorBrewer)

##
#' @title plotGreenness
#' @author Team Maja - Gijs Peters @ Simon Veen
#' @description Plot greenness!
#' @param spdf SpatialPolygonsDataFrame containing greenness!
#' @param colname Column name for greenness columns!
#' @return A green plot!
plotGreenness <- function(spdf, colname) {
  p <- brewer.pal(n=12, "YlGn")
  return(tm_shape(spdf) + tm_fill(col=colname, palette=p, style="pretty", n=12) + tm_borders(col="Burlywood4", lwd=0.5))
}