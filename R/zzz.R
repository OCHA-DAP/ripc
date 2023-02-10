# memoise ipc_get() so as not to make repeated calls to the API each session
.onLoad <- function(lib, pkg) {
  ipc_get <<- memoise::memoise(ipc_get)
}
