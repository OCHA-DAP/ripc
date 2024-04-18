#' @title population_raw
#'
#' Create `ipc_population_raw` dataset for use in package examples and unit-testing
#' population_raw contain a list of data.frame representing the output of `ipc_get_population(tidy_df = F)`
#' subset to Palestine and Sudan for convenience/size reduction purposes.


# load raw (untidy) population data from ipc API
list_pop_raw <- ipc_get_population(tidy_df = F)

# check size of full raw dataset
list_size <- object.size(
  x=list_pop_raw
)
print(list_size, units = "Mb")  # a bit big (>65 mb)

# lets reduce the size to 2-3 countries
# Palestine,
# Sudan
# Ethiopia (removing to reduce size)
country_subset <- c(
  Palestine= "PS",
  Sudan= "SD"
  # Ethiopia="ET"
)

# filter each dataset to the `country_subset`
list_pop_raw_subset <- list_pop_raw |>
  purrr::map(
    ~.x |>
      dplyr::filter(
        country %in% country_subset
      )
  )

# check size of new data set
list_subset_size <- object.size(
  x=list_pop_raw_subset
)
print(list_subset_size, units = "Mb") # 4.3 mb

# change name for saving `.rda` file
ipc_population_raw <- list_pop_raw_subset

# write data for use in package
usethis::use_data(ipc_population_raw, overwrite = TRUE)

