#' Creates the areas data frame
#'
#' Areas data is either directly available in the returned base data frame,
#' or nested within the groups nest in base. So we pass in the wrangled groups
#' data frame and the original base and extract all areas data before returning.
#'
#' @noRd
create_areas_df <- function(df_base, df_groups) {
  # first extract the areas column from df_base if the column exists
  if ("areas" %in% names(df_base)) {
    df_base_areas <- wrangle_areas_source_df(df_base)
  } else {
    df_base_areas <- NULL
  }

  # only extract from groups data frame if it exists and areas column is there
  if (!is.null(df_groups) & "areas" %in% names(df_groups)) {
    df_groups_areas <- wrangle_areas_source_df(df_groups)
  } else {
    df_groups_areas <- NULL
  }

  df_areas <- dplyr::bind_rows(
    df_base_areas,
    df_groups_areas
  )

  type_convert_silent(df_areas)
}

#' Wrangles data frames with areas data
#'
#' Extracts areas data from source data frames. Used to extract areas data
#' from base and groups data frame.
#'
#' @noRd
wrangle_areas_source_df <- function(df) {
  df <- drop_estimate_columns(df)
  df <- dplyr::select(df, -dplyr::any_of(c("population", "groups")))

  if (!is.data.frame(df$areas)) {
    df <- dplyr::filter(
      .data = df,
      !is.na(.data$areas)
    )

    df_areas <- double_unnest(
      df = df,
      col = "areas"
    )
  } else {
    df_areas <- tidyr::unnest(
      df,
      col = "areas"
    )
  }

  df_areas <- rename_areas_df(df_areas)
  df_areas <- pivot_population_df(df_areas)
}

#' Renames the areas columns
#'
#' Renames are columns, and makes sure that redundant columns are dropped, like
#' `aag_id` (already contained as `group_id`) and `period`, which will be created
#' when pivoting the estimate columns
#'
#' @noRd
rename_areas_df <- function(df) {
  df <- rename_estimate_columns(df)
  df <- dplyr::rename(
    df,
    "area_id" := "id",
    "area_name" := "name"
  )

  dplyr::select(
    df,
    -dplyr::any_of(
      c(
        "aag_id",
        "period"
      )
    )
  )
}
