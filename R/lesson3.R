
#' @title  Leap year function
#' @author  Team Maja, Gijs Peters & Simon Veen
#' @source https://en.wikipedia.org/wiki/Leap_year#Gregorian_calendar
#' @description  Function returns wether a year is a leap year.
#' @param year the year to check. This should be an integer equal or larger than 1582
#' @return TRUE if it is a leap year, FALSE otherwise
#' @examples 
#' is.leap(2000)
#' is.leap(1900)
is.leap <- function(year) {
  ## Check if input is a numeric value, otherwise return error
  if (is.numeric(year)) {
    ## See if year fits in the Gregorian calender, otherwise return string
    if (year %% 1 != 0) {
      stop("Error: year is not an integer")
    }
    if (year < 1582) {
      stop(paste("Error: year (", year, ") is out of the valid range", sep=""))
    }
    ## leap year algoritm
    if (year %% 4 != 0) {
      return (FALSE)
    } 
    if (year %% 100 != 0) {
      return (TRUE)
    }
    if (year %% 400 != 0) {
      return (FALSE)
    }
    return (TRUE)
  } else {
    stop("Error: argument of class numeric expected")
  }
}

## Leap year tests
is.leap(1904)
is.leap(2000)
is.leap(1800)
try(is.leap(1407))
try(is.leap("Gijs"))