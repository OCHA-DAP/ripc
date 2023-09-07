#' Extract dates from character columns
#'
#' Some data is stored in the IPC API as from/to columns. with different
#' formats. We extract the date into data format. Used in [ipc_get_country()]
#' and [ipc_get_areas()].
#'
#' @noRd
extract_dates <- function(
    df,
    from_col,
    to_col
) {
  # only make changes if all the columns exist in the data frame
  if (all(c(from_col, to_col) %in% names(df))) {
    # remove warnings for parsing NA cells
    has_dates <- !is.na(df[[from_col]]) & df[[from_col]] != ""

    # start date
    df[has_dates, "analysis_period_start"] <- lubridate::floor_date(
      x = lubridate::dmy(paste("15", df[[from_col]][has_dates])),
      unit = "month"
    )

    # end date
    df[has_dates, "analysis_period_end"] <- lubridate::ceiling_date(
      x = lubridate::dmy(paste("15", df[[to_col]][has_dates])),
      unit = "month"
    ) - lubridate::days(1)

    # move the columns around
    df <- dplyr::relocate(
      df,
      dplyr::starts_with("analysis_period_"),
      .after = "to"
    )
  }

  df
}
