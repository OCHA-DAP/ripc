#' Creates base data frame from list
#'
#' Creates the base data frame from a list by removing `NULL` entries from the
#' lists, converting to a tibble, and then converting anything numeric to
#' character to prevent join issues later on.
#'
#' @param json_list List coerced from JSON string
#'
#' @noRd
create_base_df <- function(json_list) {
  df <- purrr::map_dfr(
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

  # clean up data frame for all 3 outputs
  df <- rename_base_df(df)
  df <- pivot_population_df(df)
  df <- reconvert_df(df)
  df <- create_pop_date_cols(df)

  # create sub data frame for areas and groups which has no estimate columns
  df_sub <- drop_estimate_columns(df)
  df_groups <- create_groups_df(df_sub)
  df
}

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
    df_long
  )

  dplyr::filter(
    df_wide,
    !is.na(.data$phase1_population)
  )
}

#' Renames the base data frame
#'
#' @noRd
rename_base_df <- function(df) {
  df <- rename_estimate_columns(df)
  df <- rename_date_columns(df)
  dplyr::rename(df, "analysis_id" := "id")
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

    dplyr::rename(
      .data = df_groups,
      "group_id" = "id",
      "group_name" = "name"
    )
  } else {
    NULL
  }
}

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

  dplyr::bind_rows(
    df_base_areas,
    df_groups_areas
  )
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
reconvert_df <- function(df) {
  if (is.data.frame(df)) {
    df <- suppressMessages(
      readr::type_convert(
        df = df
      )
    )
  }
  df
}
