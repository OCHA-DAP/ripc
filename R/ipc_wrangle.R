#' Wrangle IPC data
#'
#' `ipc_wrangle()` transforms the IPC data [stored on
#' HDX](https://data.humdata.org/dataset/ipc-country-data). The outcome is a
#' tidy dataset where each row corresponds to an analytical output (e.g. first
#' projection for a specific date) and geographical area. Performed by default
#' in [ipc_download()].
#'
#' There are a variety of transformations done in `ipc_wrangle()`.
#'
#' ## Renaming
#'
#' Column names are extracted from the dataset and then cleaned up before
#' applying them to the dataframe. Special characters are converted to
#' alphanumeric and strings converted to lower case.
#'
#' ## Area classifications
#'
#' Area and country classifications are mixed in the raw output dataset. In some
#' cases, the country column contains the specific area being classified. This
#' is usually when an analysis has been done without area level phase
#' classification, and is seen in Yemen, South Sudan and particularly Somalia
#' analyses. This code detects these cases and extracts the correct country and
#' area names.
#'
#' ## Pivot
#'
#' Data is pivoted so that instead of specific columns based on the analytical
#' type (i.e. current, first projection, or second projection), they are stored
#' in individual rows.
#'
#' ## Final cleaning
#'
#' Extraneous columns are dropped, as are rows without data or those that are
#' aggregated from component rows (to fit the tidy principle of one level of
#' analysis being in the rows). Additional columns are produced from the
#' analysis period to specify in date format the start and end dates of the
#' analysis period, useful for future analysis or plotting.
#'
#' @param df Raw IPC data returned from `ipc_download(wrangle = FALSE)`.
#'
#' @return Wrangled IPC data.
#'
#' @export
ipc_wrangle <- function(df) {
  df %>%
    ipc_rename() %>%
    ipc_clean_area() %>%
    ipc_pivot() %>%
    ipc_clean_columns()
}

#' Rename IPC dataset
#'
#' Names for the dataset are stored in rows 3 to 5 of the data frame. They
#' are extracted and then infilled down to account for merged cells, and then
#' some small symbol clean up is done.
#'
#' @noRd
ipc_rename <- function(df) {
  # get names from rows 3 to 5
  df_names <- as.data.frame(t(df[3:5,])) %>%
    tidyr::fill(
      tidyr::everything()
    ) %>%
    tidyr::unite(
      col = "names",
      sep = "_",
      na.rm = TRUE
    )

  # apply these names and clean other names
  names(df) <- df_names$names %>%
    tolower() %>%
    stringr::str_replace_all(
      c(
        " " = "_",
        "#" = "num",
        "%" = "pct"
      )
    )

  df
}


#' Clean country and area names for IPC dataset
#'
#' Country and area names are not always similarly presented in the dataset.
#' There are some uniques cases, primarily in Somalia as well as a couple in
#' Yemen and South Sudan where there are no area level classifications and
#' in these instances, the country column is used to specify the area of
#' analysis.
#'
#' This function finds these instances and cleaned up the columns so the
#' country column contains country names and area column the area names. Areas
#' are recognized by finding when there are consecutive non-missing values in
#' the country column but the area column is entirely empty.
#'
#' @importFrom rlang := .data
#'
#' @noRd
ipc_clean_area <- function(df) {
  df %>%
    dplyr::slice(
      -c(1:5)
    ) %>%
    dplyr::mutate(
      "country_group" := cumsum(is.na(dplyr::lag(.data$country)) | is.na(.data$country))
    ) %>%
    dplyr::group_by(
      .data[["country_group"]]
    ) %>%
    dplyr::mutate(
      "mutate_group_temp_" := any(is.na(.data$country)) | !all(is.na(.data$area)) | dplyr::n() == 1,
      "area" := dplyr::case_when(
        mutate_group_temp_ ~ .data$area,
        dplyr::row_number() == 1 ~ NA_character_,
        TRUE ~ .data$country
      ),
      "country" := dplyr::case_when(
        mutate_group_temp_ ~ .data$country,
        dplyr::row_number() > 1 ~ stringr::str_extract(.data$country[1], ".*(?=:)"),
        TRUE ~ .data$country
      )
    ) %>%
    dplyr::ungroup()
}

#' Pivot the IPC data
#'
#' Pivots the IPC data so that a row is a projection or analysis and area and
#' columns are data specific to that, such as current phase.
#'
#' @noRd
ipc_pivot <- function(df) {
  df %>%
    dplyr::filter(
      !is.na(.data$area)
    ) %>%
    tidyr::pivot_longer(
      cols = tidyr::matches("^current|^first|^second"),
      names_to = c("analysis_type", "name"),
      names_pattern = "(^current|^first_projection|^second_projection)_(.*)"
    ) %>%
    tidyr::pivot_wider()

}

#' Clean column data for the IPC
#'
#' Columns get cleaned up for the dataset. A few columns are dropped, and rows
#' are filtered out to those with data. And the start and end of analysis
#' periods are stored in date format for easy plotting or analysis later.
#'
#' @noRd
ipc_clean_columns <- function(df) {
  df %>%
    dplyr::select(
      -c(
        "country_population",
        "population_analysed_pct_of_total_county_pop"
      )
    ) %>%
    dplyr::filter(
      !is.na(.data$phase_1_num)
    ) %>%
    dplyr::rename(
      "population" := "population_analysed_num",
      "phase" := "population_analysed_area_phase",
      "analysis_period" := "population_analysed_analysis_period"
    ) %>%
    readr::type_convert() %>%
    dplyr::mutate(
      "analysis_period_start" := lubridate::floor_date(
        lubridate::dmy(
          x = paste(
            "15",
            stringr::str_extract(
              .data$analysis_period,
              "(.*) - "
            )
          )
        ),
        "month"
      ),
      "analysis_period_end" := lubridate::ceiling_date(
        lubridate::dmy(
          x = paste(
            "15",
            stringr::str_extract(
              .data$analysis_period,
              " - (.*)$"
            )
          )
        ),
        "month"
      ) - lubridate::days(1),
      .after = "analysis_period"
    )
}
