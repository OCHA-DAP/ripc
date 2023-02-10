#' Get analyses resources from the IPC API
#'
#' Accesses the areas resources on the IPC API. Contains detailed analysis
#' information. If `country`, `year` and/or `type` parameters are passed,
#' accesses the **analyses** public API endpoint and pulls in all analyses or
#' filtered to those parameters. To get the details for a specific analysis
#' available on the **anales/{id}/{period}** developer API endpoint,
#' pass in `id`. You cannot pass in both sets of parameters.
#'
#' Analyses data is metadata related to specific analyses conducted by the IPC,
#' including title of the analysis, link to its release page on the IPC website,
#' and creation/modification dates.
#'
#' @inherit ipc_get_areas params return
#'
#' @examples
#' \dontrun{
#' # get all analyses details from the public API
#' ipc_get_analyses()
#'
#' # get analysis details for a specific ID
#' ipc_get_analyses(id = 12856213)
#' }
#'
#' @export
ipc_get_analyses <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    id = NULL,
    api_key = NULL
  ) {
  assert_id(id, country, year, type)
  assert_country(country)
  assert_year(year)
  type <- assert_type(type)

  resource <- if (is.null(id)) "analyses" else paste(c("analysis", id), collapse = "/")
  df <- ipc_get(
    resource = resource,
    api_key = api_key,
    year = year,
    type = type
  )

  clean_analyses_df(df)
}

#' Clean outputs from analyses API
#'
#' @noRd
clean_analyses_df <- function(df) {
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
    ) %>%
    dplyr::rename(
      "anl_id" := "id"
    )
}
