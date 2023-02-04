#' Get points resources from the IPC API
#'
#' Accesses the points resources on the IPC API. Contains detailed area and
#' population data. If `year` and/or `type` parameters are passed, accesses
#' the **types** public API endpoint and pulls in all types data or filtered to
#' either `year` or `type`. To get all types for a specific analysis
#' and period, available on the **types/{id}/{period}** developer API endpoint,
#' pass in `id` and `period`. You cannot pass in both sets of parameters.
#'
#' Points data is IPC data generated from analysis on geographic
#' entities that are smaller than the standard areas. These are typically
#' urban areas or displacement sites where food insecurity conditions might
#' differ significantly from the wider context and justify specific analysis.
#' Population estimates as well as an overall phase classification are provided
#' for each point. Data is currently output only for current
#' periods through the **points** endpoint. Use [ipc_get_population()] to get
#' detailed population data and classifications for all analysis periods. Points
#' data is contained within the `areas` dataset returned from
#' [ipc_get_population()].
#'
#' See the [IPC website](https://www.ipcinfo.org) and
#' [API documentation](https://docs.api.ipcinfo.org) for more information.
#'
#' @inheritParams ipc_get_areas
#'
#' @examples
#' \dontrun{
#' # get all areas from the public API
#' ipc_get_points()
#'
#' # get areas for specific analysis ID and period from developer API
#' ipc_get_points(id = 18978466, period = "P")
#' }
#'
#' @return A data frame.
#'
#' @export
ipc_get_points <- function(
    year = NULL,
    type = NULL,
    id = NULL,
    period = NULL,
    api_key = NULL
  ) {
  assert_id_period(id, period, year, type)
  assert_year(year)
  type <- assert_type(type)

  df <- ipc_get(
    resource = paste(c("points", id, period), collapse = "/"),
    api_key = api_key,
    year = year,
    type = type
  )

  clean_points_df(df)
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

#' Clean up points data
#'
#' @noRd
clean_points_df <- function(df) {
  df %>%
    dplyr::mutate(
      "phases" := purrr::map(.x = .data$phases, .f = point_phases_as_df)
    ) %>%
    tidyr::unnest(
      cols = "phases"
    ) %>%
    dplyr::rename(
      "num" := "population",
      "pct" := "population_percentage"
    ) %>%
    dplyr::arrange(
      dplyr::across(
        .cols = dplyr::any_of(
          c(
            "country",
            "year",
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
    ) %>%
    dplyr::rename(
      "area_id" := "aar_id"
    )
}
