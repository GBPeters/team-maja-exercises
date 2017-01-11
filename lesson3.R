## 11 January 2017

## Team Maja, Gijs Peters & Simon Veen

## source: https://en.wikipedia.org/wiki/Leap_year#Gregorian_calendar

## Leap year function
is.leap <- function(year) {
  ## Check if input is a numeric value, otherwise return error
  if (is.numeric(year)) {
    ## See if year fits in the Gregorian calender, otherwise return string
    if (year < 1582) {
      return(paste(year, "is out of the valid range"))
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

## Lear year tests
is.leap(1904)
is.leap(2000)
is.leap(1800)
is.leap(1407)
is.leap("Gijs")