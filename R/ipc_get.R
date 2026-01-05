#' Get resource from IPC API
#'
#' Back-end function used to drive the API calls of the other `ipc_get_...()`
#' family of functions.
#'
#' @param resource One of the resources exposed in the IPC API, such
#'     `"areas"` , `"analyses"`, `"points"`, or `"country"`.
#' @param return_format The format that should be returned by the API. Allows
#'     `"csv"` (the default) and `"geojson"`.
#' @param pass_format Pass format explicitly in the API call.
#' @param api_key IPC API key. If `NULL` (the default), looks for `IPC_API_KEY`
#'     in the environment.
#' @param ... Named parameters passed to the API call URL in the form of
#'     `argument=value`.
#'
#' @importFrom httr GET
#' @return Data frame from the API
ipc_get <- function(
    resource,
    return_format,
    pass_format,
    api_key = NULL,
    ...
  ) {
    api_key <- get_api_key(api_key)

    # get parameters from ellipsis, removing nulls for string concatenation
    args <- list(...)
    args <- args[!sapply(args, is.null)]
    if (pass_format) {
      params <- paste(c("format", names(args)), c(return_format, args), sep = "=", collapse = "&") # get params
    } else {
      params <- paste(names(args), args, sep = "=", collapse = "&")
    }

    # pull together into IPC URL format
    url <- sprintf(
      "https://api.ipcinfo.org/%s?key=%s&%s", resource, api_key, params
    )
    resp <- httr::GET(url = url)

    # error code wrangling
    if (resp$status_code %in% c(401, 404)) {
      stop(
        httr::http_status(resp)$message,
        ". Check your API key is correct, has access to the resource you are ",
        "requesting, and parameters are passed correctly.",
        call. = FALSE
      )
    }

    # check that the expected return value is correct
    expected_format <- ifelse(return_format == "csv", "text/csv", "application/json; charset=utf-8")
    resp_format <- httr::headers(resp)$`content-type`

    if (resp_format != expected_format) {
      stop(
        "API returned '",
        resp_format,
        "'not the expected '",
        expected_format,
        "'. Check the API and consider raising an issue on the {ripc} GitHub.",
        call. = FALSE
      )
    }

    ret <- httr::content(
      x = resp,
      as = "text",
      encoding = "UTF-8"
    )

    switch(
      return_format,
      "csv" = readr::read_csv(ret, show_col_types = FALSE, na = ""),
      "geojson" = sf::st_read(ret, quiet = TRUE),
      "json" = jsonlite::fromJSON(ret)
    )
}

#' Get IPC API key
#'
#' @noRd
get_api_key <- function(api_key) {
  if (is.null(api_key)) {
    api_key <- Sys.getenv("IPC_API_KEY", unset = NA)
    if (is.na(api_key)) {
      stop(
        "IPC API key missing. Keys can be requested from the IPC directly ",
        "at https://www.ipcinfo.org/ipc-country-analysis/api/. ",
        "Save the key in your project or global environment as `IPC_API_KEY` ",
        "or explicitly pass as `api_key` in function calls.",
        call. = FALSE
      )
    }
  }
  api_key
}
