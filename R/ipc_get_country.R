#' Get country resources from the IPC API
#'
#' Accesses the country resources on the IPC API. Contains detailed
#' country-level data. If `country`, `year` and/or `type` parameters are passed,
#' accesses the **country** simplified API endpoint and pulls in all country data
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
#' @inheritParams ipc_get_areas
#'
#' @section Tidy:
#' When `tidy_df` is `TRUE`, the following changes are made to the initial
#' output to ensure each row represents a single country analysis, and all estimates
#' and values are stored as columns:
#'
#' 1. `analysis_period_start` and `analysis_period_end` created as `Date` columns
#'     from the `from` and `to` columns respectively, allocating the day of the
#'     start and end periods to be the 15th of the month.
#' 2. `phases` is unnested from a list column to bring the phase data into
#'     the main data frame.
#' 3. The population estimates are pivoted to a wider format with names `phase#_num`
#'     and `phase#_pct`.
#' 4. `id` column is renamed to be `analysis_id`.
#'
#' @examplesIf !is.na(Sys.getenv("IPC_API_KEY", unset = NA))
#' # get all areas from the simplified API
#' ipc_get_country()
#'
#' # get country data just for Somalia
#' ipc_get_country(country = "SO")
#'
#' @returns
#' Data frame of IPC and CH analysis at the country level. Refer to the
#' [IPC-CH Public API documentation](https://docs.api.ipcinfo.org) for details
#' on the returned values, with variables described in full in the [extended
#' documentation](https://observablehq.com/@ipc/ipc-api-extended-documentation).
#'
#' @export
ipc_get_country <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    api_key = NULL,
    tidy_df = TRUE
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

  if (tidy_df) {
    clean_country_df(df)
  } else {
    df
  }
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

  df <- extract_dates(
    df = df,
    from_col = "from",
    to_col = "to"
  )

  # unpack values from phases

  df %>%
    dplyr::mutate(
      "phases" := purrr::map(.x = .data$phases, .f = area_phases_as_df)
    )%>%
    tidyr::unnest(
      cols = "phases"
    ) %>%
    dplyr::rename(
      "analysis_id" := "id",
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
