#' Get icons resources from the IPC API
#'
#' Accesses the icons resources on the IPC API. Contains links from analysis and
#' area IDs to the icon resource the IPC uses in maps and publications. This
#' is likely **not useful for the general user**. If `year` and/or `type`
#' parameters are passed, accesses the **icons** simplified API endpoint, pulls in
#' data filtered to those parameters. To get all icons for a specific analysis
#' and period, available on the **types/\{id\}/\{period\}** advanced API endpoint,
#' pass in `id` and `period`. You cannot pass in both sets of parameters.
#'
#' Icons data is used internally by the IPC to link up analyses for areas and a
#' relevant icon for display on maps and in publications. The icons are stored
#' in an Amazon S3 bucket that is not publicly accessible and therefore not
#' useful for general users. Provided here for convenience.
#'
#' See the [IPC website](https://www.ipcinfo.org) and
#' [API documentation](https://docs.api.ipcinfo.org) for more information.
#'
#' @inheritParams ipc_get_areas
#'
#' @section Tidy:
#' When `tidy_df` is `TRUE`, `aar_id` is renamed to `area_id` and `area` to
#' `area_name`.
#'
#' @examplesIf !is.na(Sys.getenv("IPC_API_KEY", unset = NA))
#'
#' # get all icons from the simplified API
#' ipc_get_icons()
#'
#' # get icons for specific analysis ID and period from advanced API
#' ipc_get_icons(id = 12135625, period = "C")
#'
#' @returns
#' Data from of icons for analysis publications.
#' Refer to the [IPC-CH Public API documentation](https://docs.api.ipcinfo.org)
#' for details on the returned values, with variables described in full in the
#' [extended documentation](https://observablehq.com/@ipc/ipc-api-extended-documentation).
#'
#' @export
ipc_get_icons <- function(
    year = NULL,
    type = NULL,
    id = NULL,
    period = NULL,
    api_key = NULL,
    tidy_df = TRUE
  ) {
  assert_id_period(id, period, year, type)
  assert_year(year)
  type <- assert_type(type)

  df <- ipc_get(
    return_format = "json",
    pass_format = FALSE,
    resource = paste(c("icons", id, period), collapse = "/"),
    api_key = api_key,
    year = year,
    type = type
  )

  if (tidy_df) {
    clean_icons_df(df)
  } else {
    df
  }
}

#' Clean up icons data
#'
#' @noRd
clean_icons_df <- function(df) {
  df %>%
    dplyr::rename(
      "area_id" := "aar_id",
      "area_name" := "area"
    ) %>%
    dplyr::mutate(
      "year" := as.numeric(.data$year)
    ) %>%
    dplyr::as_tibble()
}
