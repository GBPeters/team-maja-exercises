##
#' @title createLinearModel
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Creates a tree cover model based on input raster brick
#' @param rbrick The raster brick to create the model for
#' @param yband The bandname of the dependent variable band
#' @return The fitted model
createLinearModel <- function(rbrick, yband) {
  rdf <- as.data.frame(getValues(rbrick))
  frm <- paste0(yband, " ~ .")
  frm <- as.formula(frm)
  fit <- lm(frm, data=rdf, na.action=na.omit)
  return(fit)
}