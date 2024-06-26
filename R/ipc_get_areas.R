#' Get areas resources from the IPC-CH API
#'
#' Accesses the areas resources on the IPC-CH API. Contains detailed area and
#' population data. If `country`, `year` and/or `type` parameters are passed,
#' accesses the **areas** simplified API endpoint and pulls in all areas filtered to
#' those parameters. To get all areas for a specific analysis
#' and period, available on the **areas/\{id\}/\{period\}** advanced API endpoint,
#' pass in `id` and `period`. You cannot pass in both sets of parameters.
#'
#' Areas data is the typical unit of analysis in IPC-CH outputs. These are
#' typically administrative units (or clusters of them together). For each area,
#' estimates of the population in each phase is provided and a general phase
#' classification is assigned. Use [ipc_get_population()] to get
#' detailed population data and classifications for all analysis periods.
#'
#' See the [IPC website](https://www.ipcinfo.org) and
#' [API documentation](https://docs.api.ipcinfo.org) for more information.
#'
#' @section Tidy:
#' When `tidy_df` is `TRUE`, the following changes are made to the initial
#' output to ensure each row represents a single area analysis, and all estimates
#' and values are stored as columns:
#'
#' 1. `analysis_period_start` and `analysis_period_end` created as `Date` columns
#'    from the `from` and `to` columns respectively, allocating the day of the
#'    start and end periods to be the 15th of the month.
#' 2. `title` column is renamed to be `area_name`, `anl_id` to `analysis_id`,
#'    and `id` and `aar_id` are changed to `area_id`.
#' 3. Duplicated rows are removed from the data frame if the return value is CSV,
#'    because the duplicates are there due to polygon geometries.
#'
#' @param country ISO2 country code.
#' @param year Single numeric year to filter analysis, calculated from the
#'     maximum year of current period dates. If `NULL`, the default, returns
#'     data for all years.
#' @param type Single string value of 'A' or 'C', corresponding to food security
#'     conditions, either acute or chronic. If `NULL`, the default, returns
#'     data for all types.
#' @param id Analysis ID.
#' @param period Period code, either 'C', 'P', or 'A' for current, projection,
#'     and second projection.
#' @param tidy_df If `TRUE`, returns a tidy data frame wrangled as described in
#'     the Tidy section of the documentation. If `FALSE`, returns
#'     the data frame as returned direct from the IPC-CH API.
#'
#' @inheritParams ipc_get
#'
#' @examplesIf !is.na(Sys.getenv("IPC_API_KEY", unset = NA))
#' # get all areas from the simplified API
#' ipc_get_areas()
#'
#' # get areas for specific analysis ID and period from advanced API
#' ipc_get_areas(id = 12856213, period = "P")
#'
#' # request GeoJSON return
#' ipc_get_areas(id = 12856213, period = "P", return_format = "geojson")
#'
#' @returns
#' Data frame of IPC and CH analysis at the areas level. Refer to the
#' [IPC-CH Public API documentation](https://docs.api.ipcinfo.org) for details
#' on the returned values, with variables described in full in the [extended
#' documentation](https://observablehq.com/@ipc/ipc-api-extended-documentation).
#'
#' @export
ipc_get_areas <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    id = NULL,
    period = NULL,
    return_format = c("csv", "geojson"),
    api_key = NULL,
    tidy_df = TRUE
  ) {
  return_format <- rlang::arg_match(return_format)
  assert_id_period(id, period, country, year)
  assert_country(country)
  assert_year(year)
  assert_id(id)
  assert_period(period)

  type <- assert_type(type)

  df <- ipc_get(
    resource = paste(c("areas", id, period), collapse = "/"),
    return_format = return_format,
    pass_format = TRUE,
    api_key = api_key,
    country = country,
    year = year,
    type = type
  )

  if (tidy_df) {
    df <- clean_areas_df(df = df, return_format = return_format)
  }

  df
}

#' Clean areas data frame
#'
#' Runs `dplyr::distinct()` on the data as there is a duplicate row in the database,
#' and renames a few columns.
#'
#' @noRd
clean_areas_df <- function(df, return_format) {
  # only deduplicate if CSV is returned, as the duplication is due to polygon geometries
  if (return_format == "csv") {
    df <- dplyr::distinct(df)
    df <- dplyr::as_tibble(df)
  }

  df <- dplyr::rename(
      df,
      "area_name" := "title",
      "analysis_id" := "anl_id"
  )

  df <- dplyr::rename_with(
    df,
    .cols = dplyr::any_of(c("id", "aar_id")),
    .fn = ~ "area_id"
  )

  df <- extract_dates(
    df,
    from_col = "from",
    to_col = "to"
  )

  df
}
