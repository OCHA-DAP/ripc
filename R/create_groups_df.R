#' Creates the groups data frame
#'
#' Creates the groups data frame by unnesting group columns. Leaves the nested
#' `areas` column which will be used to create the `areas_df`. Created directly
#' from the base data frame.
#'
#' Returns `NULL` if there is no `groups` column in the base data frame.
#'
#' @noRd
create_groups_df <- function(df) {
  if ("groups" %in% names(df)) {
    # extract date cols and create date df before unnesting for joining later
    date_cols <- c("period", "from", "to", "analysis_period_start", "analysis_period_end")
    df_dates <- dplyr::select(df, dplyr::any_of(c("analysis_id", date_cols)))

    df <- dplyr::select(df, -dplyr::any_of(c("areas", date_cols)))
    df <- drop_estimate_columns(df)

    if (!is.data.frame(df$groups)) {
      df <- dplyr::filter(df, !is.na(.data$groups))

      df_groups <- double_unnest(
        df = df,
        col = "groups"
      )
    } else {
      df_groups <- tidyr::unnest(
        df,
        col = "groups"
      )
    }

    df_groups <- rename_groups_df(df_groups)

    # join back with date columns after pivoting
    df_pivoted <- pivot_population_df(
      dplyr::select(df_groups, -dplyr::any_of(c("period", date_cols)))
    )

    df_joined <- dplyr::left_join(
      df_pivoted,
      dplyr::distinct(df_dates),
      by = c("analysis_id", "period")
    )

    type_convert_silent(df_joined)
  } else {
    NULL
  }
}

#' Renames the groups columns
#'
#' Renames columns, and makes sure that redundant columns are dropped, like
#' `aag_id` (already contained as `group_id`) and `period`, which will be created
#' when pivoting the estimate columns
#'
#' @noRd
rename_groups_df <- function(df) {
  df <- rename_estimate_columns(df)
  dplyr::rename(
    .data = df,
    "group_id" = "id",
    "group_name" = "name"
  )
}
