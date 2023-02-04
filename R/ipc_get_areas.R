#' Get areas resources from the IPC API
#'
#' Accesses the areas resources on the IPC API. Contains detailed area and
#' population data. If `country`, `year` and/or `type` parameters are passed,
#' accesses the **areas** public API endpoint and pulls in all areas filtered to
#' those parameters. To get all areas for a specific analysis
#' and period, available on the **areas/{id}/{period}** developer API endpoint,
#' pass in `id` and `period`. You cannot pass in both sets of parameters.
#'
#' Areas data is the typical unit of analysis in IPC outputs. These are
#' typically administrative units (or clusters of them together). For each area,
#' estimates of the population in each phase is provided and a general phase
#' classification is assigned. Data is currently output only for current
#' periods through **areas** endpoint. Use [ipc_get_population()] to get
#' detailed population data and classifications for all analysis periods.
#'
#' See the [IPC website](https://www.ipcinfo.org) and
#' [API documentation](https://docs.api.ipcinfo.org) for more information.
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
#'
#' @inheritParams ipc_get
#'
#' @examples
#' \dontrun{
#' # get all areas from the public API
#' ipc_get_areas()
#'
#' # get areas for specific analysis ID and period from developer API
#' ipc_get_areas(id = 12856213, period = "P")
#' }
#'
#' @return A data frame.
#'
#' @export
ipc_get_areas <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    id = NULL,
    period = NULL,
    api_key = NULL
  ) {
  assert_id_period(id, period, country, year)
  assert_country(country)
  assert_year(year)
  assert_id(id)
  assert_period(period)

  type <- assert_type(type)

  df <- ipc_get(
    resource = paste(c("areas", id, period), collapse = "/"),
    api_key = api_key,
    year = year,
    type = type
  )

  clean_areas_df(df)
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

#' Clean areas data frame
#'
#' @noRd
clean_areas_df <- function(df) {
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

  clean_df <- df %>%
    dplyr::mutate(
      "phases" := purrr::map(.x = .data$phases, .f = area_phases_as_df)
    )%>%
    tidyr::unnest(
      cols = "phases"
    ) %>%
    dplyr::rename(
      "num" := "population",
      "pct" := "percent"
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

  dplyr::rename(clean_df, "area_name" := "title") %>%
    dplyr::rename_with(
      .cols = dplyr::any_of(c("id", "aar_id")),
      .fn = ~ "area_id"
    )
}
