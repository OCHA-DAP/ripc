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

#' Assert start and end
#'
#' @noRd
assert_start_end <- function(start, end) {
  nulls <- sum(c(!is.null(start), !is.null(end)))
  if (nulls == 1) {
    stop(
      "Both `start` and `end` must be provided together.",
      call. = FALSE
    )
  } else if (nulls == 2) {
    checks <- sapply(
      X = c(start, end),
      FUN = function(x) length(x) != 1 || x < 2015
    )
    if (checks || end < start) {
      stop(
        "`start` and `end` should both be numeric years from 2015 onward, and ",
        "`end` should not be less than the `start` value.",
        call. = FALSE
      )
    }
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

#' Assert ID is correct
#'
#' @noRd
assert_id <- function(id, ...) {
  if (!is.null(id)) {
    if (is.numeric(id)) {
      id <- as.character(id)
    }

    if (!is.character(id) || !grepl("[0-9]{8}", id)) {
      stop(
        "`id` must be a character or numeric vector of 8 digits ",
        "matching an IPC analysis ID.",
        call. = FALSE
      )
    }

    args <- list(...)
    non_null_args <- Filter(Negate(is.null), args)
    if (length(non_null_args) > 0) {
      stop(
        "If passing `id`, do not pass any other optional ",
        "parameters."
      )
    }
  }
}

#' Assert period
#'
#' @noRd
assert_period <- function(period) {
  if (!is.null(period)) {
    rlang::arg_match(period, values = c("C", "P", "A"))
  }
}

#' Assert if ID and period passed, other parameters not
#'
#' @noRd
assert_id_period <- function(id, period, ...) {
  id_passed <- !is.null(id)
  period_passed <- !is.null(period)
  passed <- id_passed + period_passed
  if (passed == 1) {
    stop(
      "Both `id` and `period` must be passed to access the ",
      "'areas/{id}/{period}', 'points/{id}/{period}', or ",
      "'icons/{id}/{period}' API endpoints.",
      call. = FALSE
    )
  } else if (passed == 2) {
    args <- list(...)
    non_null_args <- Filter(Negate(is.null), args)
    if (length(non_null_args) > 0) {
      stop(
        "If passing `id` and `period`, do not pass any other optional ",
        "parameters."
      )
    }
  }
}
