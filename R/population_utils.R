#' Pivots the base data frame
#'
#' Pivots the base data frame by identify columns with a hyphen. First it pivots
#' everything longer then pivots wider so each row is a period (current,
#' projected, or second projected). Then it filters out rows with missing values.
#'
#' @noRd
pivot_population_df <- function(df) {
  df_long <- tidyr::pivot_longer(
    df,
    cols = dplyr::contains("-"),
    names_sep = "-",
    names_to = c("name", "period")
  )

  df_wide <- tidyr::pivot_wider(
    df_long,
    names_from = "name",
    values_from = "value"
  )

  dplyr::filter(
    df_wide,
    !is.na(.data$phase1_population)
  )
}

#' Rename estimate columns
#'
#' Finds and restimates estimate columns in a data frame so that they can pivoted.
#' Does it by creating a "current" designation and separating the projections by
#' a hyphen rather than an underscore.
#'
#' @noRd
rename_estimate_columns <- function(df) {
    dplyr::rename_with(
      .data = df,
      .fn = function(x) {
        ifelse(
          !stringr::str_detect(x, "projected"),
          paste(x, "current", sep = "-"),
          # replace `_` that are followed by "projected" or "second" with `-`
          stringr::str_replace(
            x,
            "_(?=projected|second)",
            "-"
          )
        )
      },
      .cols = dplyr::matches("p[0-9]{1}|^phase|^estimated")
    )
}

#' Drop estimate columns
#'
#' Drops columns that are estimates, which are duplicated within `groups` and
#' `areas` nested data frames.
#'
#' @noRd
drop_estimate_columns <- function(df) {
  dplyr::select(
    .data = df,
    -dplyr::matches("p[0-9]{1}|^phase|^estimated")
  )
}

#' Double unnests list columns
#'
#' `areas` and `groups` columns require double unnesting. First wider to create
#' list columns, and then unnesting those list columns. This utility is used for both.
#'
#' @noRd
double_unnest <- function(df, col) {
  df_wide <- tidyr::unnest_wider(
    data = df,
    col = col,
    transform = function(x) if (is.numeric(x)) as.character(x) else x
  )

  tidyr::unnest(
    data = df_wide,
    cols = dplyr::where(is.list)
  )
}

#' Convenience function to suppress messages from [readr::type_convert()]
#'
#' @noRd
type_convert_silent <- function(df) {
  if (is.data.frame(df)) {
    df <- suppressMessages(
      readr::type_convert(
        df = df,
        na = ""
      )
    )
  }
  df
}

#' Ensure returned value is a list
#'
#' Sometimes if parameters are passed, the returned value is not a list of lists,
#' but is instead a data frame. If that is the case, we need to return it nested
#' within a list for parsing later.
#'
#' @param ret Return value from the API
#'
#' @noRd
ensure_list <- function(ret) {
  is_list <- purrr::map_lgl(
    .x = ret,
    .f = \(x) inherits(x, what = "list")
  )
  if (!all(is_list)) {
    ret <- list(ret)
  }
  ret
}
