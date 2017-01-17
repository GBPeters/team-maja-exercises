##
# Download and extract function
# Team Maja - Simon Veen & Gijs Peters
# 17-01-17

# Imports
library(mime)

# Constants
DATADIR <- "./data"

##
#' @title downloadAndExtract
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Download and extract the files of a given url to target directory. 
#' If the file extenstion is a zip archive or tarbal, it will be extracted locally.
#' @param url The url to download from
#' @param datadir The folder to download in
downloadAndExtract <-function(url, datadir=DATADIR) {
  dir.create(datadir, showWarnings = FALSE)
  dest <- file.path(datadir, basename(url))
  download.file(url, dest)
  mt <- guess_type(dest)
  if (mt == "application/zip") {
    unzip(dest, exdir=datadir)
  } else if (mt == "application/x-tar" ||
             mt == "application/gzip" ||
             mt == "application/bzip" ||
             mt == "application/tgz") {
    untar(dest, exdir=datadir)
  }
}