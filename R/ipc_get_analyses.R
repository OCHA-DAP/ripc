#' Get analyses resources from the IPC API
#'
#' Accesses the areas resources on the IPC API. Contains detailed analysis
#' information. If `country`, `year` and/or `type` parameters are passed,
#' accesses the **analyses** simplified API endpoint and pulls in all analyses or
#' filtered to those parameters. To get the details for a specific analysis
#' available on the **analyses/\{id\}/\{period\}** advanced API endpoint,
#' pass in `id`. You cannot pass in both sets of parameters.
#'
#' Analyses data is metadata related to specific analyses conducted by the IPC,
#' including title of the analysis, link to its release page on the IPC website,
#' and creation/modification dates.
#'
#' @inheritParams ipc_get_areas
#'
#' @section Tidy:
#' When `tidy_df` is `TRUE`, the following changes are made to the initial
#' output to ensure each row represents a single analysis:
#'
#' 1. The data is arranged by `country`, `year`, and `created`.
#' 2. `id` column is renamed to be `analysis_id`.
#'
#' @examplesIf !is.na(Sys.getenv("IPC_API_KEY", unset = NA))
#' # get all analyses details from the simplified API
#' ipc_get_analyses()
#'
#' # get analysis details for a specific analysis ID
#' ipc_get_analyses(id = 12856213)
#'
#' @returns
#' Data frame of analysis metadata. Refer to the
#' [IPC-CH Public API documentation](https://docs.api.ipcinfo.org) for details
#' on the returned values, with variables described in full in the [extended
#' documentation](https://observablehq.com/@ipc/ipc-api-extended-documentation).
#'
#' @export
ipc_get_analyses <- function(
    country = NULL,
    year = NULL,
    type = NULL,
    id = NULL,
    api_key = NULL,
    tidy_df = TRUE
  ) {
  assert_id(id, country, year, type)
  assert_country(country)
  assert_year(year)
  type <- assert_type(type)

  # different return values allowed depending on endpoint accessed
  if (is.null(id)) {
    resource <- "analyses"
    return_format <- "csv"
  } else {
    resource <- paste(c("analysis", id), collapse = "/")
    return_format <- "json"
  }

  df <- ipc_get(
    resource = resource,
    return_format = return_format,
    pass_format = TRUE,
    api_key = api_key,
    country = country,
    year = year,
    type = type
  )

  if (return_format == "json") {
    df <- null_converter(df) %>%
      dplyr::as_tibble()
  }

  if (tidy_df) {
    clean_analyses_df(df)
  } else {
    df
  }
}

#' Clean outputs from analyses API
#'
#' @noRd
clean_analyses_df <- function(df) {
  df %>%
    dplyr::arrange(
      .data$country,
      .data$year,
      .data$created
    ) %>%
    dplyr::rename(
      "analysis_id" := "id"
    ) %>%
    dplyr::as_tibble()
}
