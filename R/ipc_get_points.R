#' Get points resource from IPC API
#'
#' Accesses the points resource on the IPC API. More details to come.
#'
#' @inheritParams ipc_get_areas
ipc_get_points <- function(year = NULL, type = NULL, api_key = NULL) {
  assert_year(year)
  type <- assert_type(type)

  df <- ipc_get(
    resource = "points",
    api_key = api_key,
    year = year,
    type = type
  )

  # clean up output
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
      .data$country,
      .data$year,
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

#' Convert phases list to data frame.
#'
#' Cleans up the phases list to allow unnesting. Drops the `overall_phase`
#' column, then converts to data frame.
#'
#' @param phases_list Phases list
point_phases_as_df <- function(phases_list) {
  phases_list[["overall_phase"]] <- NULL
  dplyr::as_tibble(phases_list)
}


