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
    df <- dplyr::select(df, -dplyr::any_of("areas"))
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

    df_groups <- dplyr::rename(
      .data = df_groups,
      "group_id" = "id",
      "group_name" = "name"
    )
    type_convert_silent(df_groups)
  } else {
    NULL
  }
}
