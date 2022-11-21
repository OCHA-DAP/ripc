#' Download IPC data
#'
#' `ipc_download()` downloads IPC country data from the [Humanitarian
#' Data Exchange](https://data.humdata.org/dataset/ipc-country-data).
#'
#' @param wrangle If `True` (the default), wrangles the data into a coherent
#'     data structure. Details on the wrangling in the documentation of
#'     [ipc_wrangle()].
#' @param configuration Configuration to pass on to [rhdx::pull_dataset()].
#'
#' @return IPC data frame.
#'
#' @export
ipc_download <- function(wrangle = TRUE, configuration = NULL) {
  res <- rhdx::pull_dataset(
    identifier = "ipc-country-data",
    configuration = configuration
  ) %>%
    rhdx::get_resource(index = 1)

  df <- suppressMessages(
    rhdx::read_resource(resource = res, sheet = "IPC")
  )

  if (wrangle) {
    df <- ipc_wrangle(df)
  }

  df
}
