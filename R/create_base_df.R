#' Creates base data frame from list
#'
#' Creates the base data frame from a list by removing `NULL` entries from the
#' lists, converting to a tibble, and then converting anything numeric to
#' character to prevent join issues later on.
#'
#' The data is then prepared for use to create the `country`, `areas`, and `groups`
#' data frame.
#'
#' @param json_list List coerced from JSON string
#'
#' @noRd
create_base_df <- function(json_list) {
  df <- extract_base_data_frame(json_list)
  prepare_base_df(df)
}

#' Prepare base data frame
#'
#' Prepares the base data frame by renaming it, pivoting it, and then converting
#' to the correct column types before creating the necessary date columns. This
#' data frame is then ready for all 3 final outputs.
#'
#' @noRd
prepare_base_df <- function(df) {
  df <- rename_initial_df(df)
  df <- pivot_population_df(df)
  df <- type_convert_silent(df)
  df <- create_pop_date_cols(df)
}

#' Renames the initial data frame to create base
#'
#' @noRd
rename_initial_df <- function(df) {
  df <- rename_estimate_columns(df)
  df <- rename_date_columns(df)
  dplyr::rename(df, "analysis_id" := "id")
}

#' Rename the date columns in the data frame
#'
#' @noRd
rename_date_columns <- function(df) {
  dplyr::rename_with(
    .data = df,
    .fn = function(x) {
      x <- stringr::str_remove(x, "_period_dates")
      paste("period_dates", x, sep = "-")
    },
    .col = dplyr::ends_with("period_dates")
  )
}

#' Create date columns
#'
#' Extract date columns from the data frame by first splitting the string
#' dates and then using `extract_dates()` to create actual date columns.
#'
#' @noRd
create_pop_date_cols <- function(df) {
  df_split <- tidyr::separate(
    data = df,
    col = "period_dates",
    into = c("from", "to"),
    sep = " - "
  )

  extract_dates(
    df = df_split,
    from_col = "from",
    to_col = "to"
  )
}

#' Get the base data frame from list
#'
#' Extracts the base data frame the list returned from the API. Does this by
#' removing `NULL` entries from the lists, converting to a tibble, and
#' then converting anything numeric to character to prevent join issues later on.
#'
#' @noRd
extract_base_data_frame <- function(json_list) {
  df_list <- purrr::map(
    .x = json_list,
    .f = function(x) {
      x_list <- null_converter(x, drop_metadata = TRUE)
      df <- dplyr::as_tibble(x_list)
      dplyr::mutate(
        df,
        dplyr::across(
          .cols = dplyr::everything(),
          .fns = function(x) if (is.numeric(x)) as.character(x) else x
        )
      )
    }
  )

  purrr::list_rbind(df_list)
}
