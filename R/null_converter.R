#' Convert NULL values in list to NA
#'
#' Used since NULL values generate errors when converting to data frame.
#' Drops metadata from lists if requested, used in [ipc_get_population()].
#'
#' @noRd
null_converter <- function(x, drop_metadata = FALSE) {
  if (is.list(x)) {
    if (drop_metadata) {
      x[["metadata"]] <- NULL
    }
    if (!is.data.frame(x)) {
      lapply(x, null_converter)
    } else {
      x
    }
  }
  else {
    if (is.null(x)) {
      NA
    } else {
      x
    }
  }
}
