#' Get icons resources from the IPC API
#'
#' Accesses the icons resources on the IPC API. Contains links from analysis and
#' area IDs to the icon resource the IPC uses in maps and publications. This
#' is likely **not useful for the general user**. If `year` and/or `type`
#' parameters are passed, accesses the **icons** public API endpoint, pulls in
#' data filtered to those parameters. To get all icons for a specific analysis
#' and period, available on the **types/{id}/{period}** developer API endpoint,
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
#' @inherit ipc_get_areas params return
#'
#' @examples
#' \dontrun{
#' # get all icons from the public API
#' ipc_get_icons()
#'
#' # get icons for specific analysis ID and period from developer API
#' ipc_get_icons(id = 12135625, period = "C")
#' }
#'
#' @export
ipc_get_icons <- function(
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
    resource = paste(c("icons", id, period), collapse = "/"),
    api_key = api_key,
    year = year,
    type = type
  )

  clean_icons_df(df)
}

#' Clean up icons data
#'
#' @noRd
clean_icons_df <- function(df) {
  df %>%
    dplyr::rename(
      "area_id" := "aar_id",
      "area_name" := "area"
    )
}
