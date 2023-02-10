#' Get resource from IPC API
#'
#' Back-end function used to drive the API calls of the other `ipc_get_...()`
#' family of functions.
#'
#' @param resource One of the resources exposed in the IPC API, such
#'     `"areas"` , `"analyses"`, `"points"`, or `"country"`.
#' @param api_key IPC API key. If `NULL` (the default), looks for `IPC_API_KEY`
#'     in the environment.
#' @param ... Named parameters passed to the API call URL in the form of
#'     `argument=value`.
#' @param drop_metadata Logical, whether or not to drop metadata from the
#'     original list return.
#'
#' @importFrom httr GET
#' @return Data frame from the API
ipc_get <- function(
    resource,
    api_key = NULL,
    ...,
    drop_metadata = FALSE
  ) {
    api_key <- get_api_key(api_key)

    # get parameters from ellipsis, removing nulls for string concatenation
    args <- list(...)
    args <- args[!sapply(args, is.null)]
    params <- paste(names(args), args, sep = "=", collapse = "&") # get params

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

    ipc_list <- httr::content(
      x = resp,
      as = "parsed",
      type = "application/json"
    )

    # check if list of lists or if not, convert to a list of single list
    if (!all(sapply(ipc_list, inherits, what = "list"))) {
      ipc_list <- list(ipc_list)
    }

    if (purrr::is_empty(ipc_list)) {
      stop(
        "API call was successful but no content was returned. Check that the ",
        "ID or other parameters passed are actually present in the resource.",
        call. = FALSE
      )
    }

    purrr::map_dfr(
      .x = ipc_list,
      .f = ~ null_converter(.x, drop_metadata = drop_metadata)
        %>% dplyr::as_tibble()
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

#' Convert NULL values in list to NA
#'
#' Used since NULL values generate errors when converting to data frame.
#' Drops metadata from lists if requested, used in [ipc_get_population()].
#'
#' @noRd
null_converter <- function(x, drop_metadata = FALSE) {
  if (is.list(x)) {
    if (drop_metadata) {
      x[["metadata"]] <- NULL
    }
    lapply(x, null_converter)
  }
  else {
    if (is.null(x)) {
      NA
    } else {
      x
    }
  }
}
