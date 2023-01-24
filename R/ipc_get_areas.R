#' Get areas resource from IPC API
#'
#' Accesses the areas resource on the IPC API. More details to come.
#'
#' @param country ISO2 country code.
#' @param year Single numeric year to filter analysis, calculated from the
#'     maximum year of current period dates. If `NULL`, the default, returns
#'     data for all years.
#' @param type Single string value of 'A' or 'C', corresponding to food security
#'     conditions, either acute or chronic. If `NULL`, the default, returns
#'     data for all types.
#'
#' @inheritParams ipc_get
ipc_get_areas <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    api_key = NULL
  ) {
  assert_country(country)
  assert_year(year)
  type <- assert_type(type)

  df <- ipc_get(
    resource = "areas",
    api_key = api_key,
    year = year,
    type = type
  )

  # clean up output
  df %>%
    dplyr::mutate(
      "phases" := purrr::map(.x = .data$phases, .f = area_phases_as_df),
    ) %>%
    dplyr::mutate(
      "analysis_period_start" := lubridate::floor_date(
        x = lubridate::dmy(paste("15", .data$from)),
        unit = "month"
      ),
      "analysis_period_end" := lubridate::ceiling_date(
        x = lubridate::dmy(paste("15", .data$to)),
        unit = "month"
      ) - lubridate::days(1),
      .after = "to"
    ) %>%
    tidyr::unnest(
      cols = "phases"
    ) %>%
    dplyr::rename(
      "num" := "population",
      "pct" := "percent"
    ) %>%
    dplyr::arrange(
      .data$country,
      .data$year,
      .data$analysis_period_start,
      .data$title,
      .data$phase
    ) %>%
    tidyr::pivot_wider(
      names_from = "phase",
      values_from = c("num", "pct"),
      names_glue = "phase{phase}_{.value}",
      values_fn = unique # errors in database have a single duplicate
    )
}

#' Convert areas phase list to data frame.
#'
#' Cleans up the phases list to allow unnesting. Drops the `color`
#' column, then converts to data frame.
#'
#' @param phases_list Phases list
area_phases_as_df <- function(phases_list) {
  phases_list[["color"]] <- NULL
  dplyr::as_tibble(phases_list)
}


