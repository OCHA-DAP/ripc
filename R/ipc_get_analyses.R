#' Get analyses resource from IPC API
#'
#' Accesses the analyses resource on the IPC API. More details to come.
#'
#' @inheritParams ipc_get_areas
ipc_get_analyses <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    api_key = NULL
  ) {
  assert_country(country)
  assert_year(year)
  type <- assert_type(type)

  df <- ipc_get(
    resource = "analyses",
    api_key = api_key,
    year = year,
    type = type
  )

# clean up output
df %>%
  dplyr::mutate(
    dplyr::across(
      .cols = c("created", "modified"),
      as.Date
    )
  ) %>%
  dplyr::arrange(
    .data$country,
    .data$year,
    .data$created
  )
}
