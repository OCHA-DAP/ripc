#' Assert year is 2015 or beyond
#'
#' @noRd
assert_year <- function(year) {
  if (!is.null(year) && (length(year) != 1 || year < 2015)) {
    stop(
      "`year` must be a single year value from 2015 or later.",
      call. = FALSE
    )
  }
}

#' Assert type is either A or C
#'
#' @noRd
assert_type <- function(type) {
  if (!is.null(type)) {
    type <- rlang::arg_match(type, c("A", "C"))
  }
  type
}

#' Assert country is a valid ISO2 country code
#'
#' @noRd
assert_country <- function(country) {
  if (!is.null(country)) {
    if (length(country) != 1 && !(country %in% countrycode::codelist$iso2c)) {
      stop(
        "`country` must be a single valid ISO2 country-code.",
        call. = FALSE
      )
    }
  }
}

