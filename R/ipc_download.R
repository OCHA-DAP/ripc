#' Download point IPC data from the API
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `ipc_download()` has been deprecated in favor of the `ipc_get_...()` family
#' of functions which download from the IPC API, rather than HDX.
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
  .Deprecated(
    new = "ipc_get_population()",
    msg = paste(
      "`ipc_download()` has been deprecated as the recommended functions for",
      "downloading IPC data directly pull from the IPC API.",
      "`ipc_get_population()` most directly replicates the functionality of",
      "the deprecated `ipc_download()` function."
    )
  )

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
