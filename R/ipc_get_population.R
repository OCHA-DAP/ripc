#' Get population resources from the IPC API
#'
#' Accesses the population resources on the IPC API. Contains detailed
#' population data. If `country` and/or `start` and `end` parameters are passed,
#' accesses the **population** advanced API endpoint and pulls in all data.
#' filtered by those parameters. To get the population data for a specific
#' analysis, available on the **types/\{id\}** advanced API endpoint,
#' pass in `id`. You cannot pass in both sets of parameters.
#'
#' Unlike the other `ipc_get_..()` family of functions, this returns a list of
#' datasets, corresponding to `country`, `areas`, and `groups` data. The benefit of
#' `ipc_get_population()` is that the
#' returned data for each level of analysis contains all periods of analysis.
#'
#' Groups data, where available, are geographies within a country that
#' comprise multiple areas and/or points.
#' Areas and points data is the lowest level of IPC analysis where population
#' estimates for each phase are provided and a general area-level classification
#' is made. There is no phase classification at
#' the group level, but populations in each phase are provided. The same applies
#' to country-level data.
#'
#' These datasets are available elsewhere through:
#'
#' * Country data: [ipc_get_country()]
#' * Areas data: [ipc_get_areas()]
#' * Groups data: Not available through other functions
#'
#' See the respective function documentation for more details on what each
#' dataset comprises or the [IPC website](https://www.ipcinfo.org) and
#' [API documentation](https://docs.api.ipcinfo.org) for more detailed and
#' comprehensive information on the data and analysis.
#'
#' @inheritParams ipc_get_areas
#' @param start Start year.
#' @param end End year.
#'
#' @section Tidy:
#' When `tidy_df` is `TRUE`, the data returned from the population end point is
#' transformed into a list of 3 data frames to ensure that each row represents a
#' single analysis, and all estimates and values are stored as columns, while
#' data at different levels of aggregation are in completely separate data
#' frames. The steps are:
#'
#' 1. `analysis_period_start` and `analysis_period_end` created as `Date` columns
#'     from the `period_dates` column respectively, allocating the day of the
#'     start and end periods to be the 15th of the month.
#' 2. `analysis_date` converted to a date column, using the 15th day of the month.
#' 2. `phases` is unnested from a list column to bring the phase data into
#'     the main data frame.
#' 3. The population estimates are pivoted to a wider format with names `phase#_num`
#'     and `phase#_pct`.
#' 4. `id` column renamed to `analysis_id`.
#' 5. Data frames are split out so multiple aggregations not present in a single
#'    single data frame.
#'
#' @examplesIf !is.na(Sys.getenv("IPC_API_KEY", unset = NA))
#' # get all populations from the simplified API
#' ipc_get_population()
#'
#' # get populations for specific analysis ID from advanced API
#' ipc_get_population(id = 12856213) # analysis with areas data frame
#' ipc_get_population(id = 65508276) # analysis with groups data frame

#' @returns A list of 3 data frames:
#' * Country data frame.
#' * Areas data frame.
#' * Groups data frame.
#'
#' Refer to the [IPC-CH Public API documentation](https://docs.api.ipcinfo.org)
#' for details on the returned values, with variables described in full in the
#' [extended documentation](https://observablehq.com/@ipc/ipc-api-extended-documentation).
#'
#' @export
ipc_get_population <- function(
    country = NULL,
    start = NULL,
    end = NULL,
    id = NULL,
    api_key = NULL,
    tidy_df = TRUE
  ) {
  assert_country(country)
  assert_start_end(start, end)
  assert_id(id, country, start, end)

  ret <- ipc_get(
    resource = paste(c("population", id), collapse = "/"),
    return_format = "json",
    pass_format = FALSE,
    api_key = api_key,
    country = country,
    start = start,
    end = end
  )

  ret <- ensure_list(ret)

  df_base <- create_base_df(ret)
  df_groups <- create_groups_df(df_base)
  df_areas <- create_areas_df(df_base, df_groups)
  df_country <- dplyr::select(df_base, -dplyr::any_of(c("groups", "areas")))

  list(
    country = df_country,
    groups = df_groups,
    areas = df_areas
  )
}

