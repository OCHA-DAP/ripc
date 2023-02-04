#' Get country resources from the IPC API
#'
#' Accesses the country resources on the IPC API. Contains detailed
#' country-level data. If `country`, `year` and/or `type` parameters are passed,
#' accesses the **country** public API endpoint and pulls in all country data
#' filtered to those parameters.
#'
#' Country data is the highest level of aggregation for IPC analysis. Data is
#' the population estimates and other details aggregated from area and point
#' analyses within the country for that specific analysis. No phase
#' classifications are made at the country level. Data is currently output only
#' for current periods through the **country** endpoint. Use
#' [ipc_get_population()] to get detailed population data for all analysis
#' periods.
#'
#' See the [IPC website](https://www.ipcinfo.org) and
#' [API documentation](https://docs.api.ipcinfo.org) for more information.
#'
#' @inherit ipc_get_areas return params
#'
#' @examples
#' \dontrun{
#' # get all areas from the public API
#' ipc_get_country()
#'
#' # get country data just for Somalia
#' ipc_get_country(country = "SO")
#' }
#'
#' @return A data frame.
#'
#' @export
ipc_get_country <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    api_key = NULL
  ) {
  assert_country(country)
  assert_year(year)
  type <- assert_type(type)

  df <- ipc_get(
    resource = "country",
    api_key = api_key,
    country = country,
    year = year,
    type = type
  )

  clean_country_df(df)
}

#' Convert phases list to data frame.
#'
#' Cleans up the phases list to allow unnesting. Drops the `overall_phase`
#' column, then converts to data frame.
#'
#' @param phases_list Phases list
#'
#' @noRd
point_phases_as_df <- function(phases_list) {
  phases_list[["overall_phase"]] <- NULL
  dplyr::as_tibble(phases_list)
}


#' Clean areas data frame
#'
#' @noRd
clean_country_df <- function(df) {
  # clean up output
  # generate analysis period start and end if present

  if (all(c("to", "from") %in% names(df))) {
    df <- dplyr::mutate(
      df,
      "analysis_period_start" := lubridate::floor_date(
        x = lubridate::dmy(paste("15", .data$from)),
        unit = "month"
      ),
      "analysis_period_end" := lubridate::ceiling_date(
        x = lubridate::dmy(paste("15", .data$to)),
        unit = "month"
      ) - lubridate::days(1),
      .after = "to"
    )
  }

  # unpack values from phases

  df %>%
    dplyr::mutate(
      "phases" := purrr::map(.x = .data$phases, .f = area_phases_as_df)
    )%>%
    tidyr::unnest(
      cols = "phases"
    ) %>%
    dplyr::rename(
      "num" := "population",
      "pct" := "percentage"
    ) %>%
    dplyr::arrange(
      dplyr::across(
        dplyr::any_of(
          c(
            "country",
            "year",
            "analysis_period_start",
            "title",
            "phase"
          )
        )
      )
    ) %>%
    tidyr::pivot_wider(
      names_from = "phase",
      values_from = c("num", "pct"),
      names_glue = "phase{phase}_{.value}",
      values_fn = unique # errors in database have a single duplicate
    )
}
