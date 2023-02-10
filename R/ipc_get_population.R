#' Get population resources from the IPC API
#'
#' Accesses the population resources on the IPC API. Contains detailed
#' population data. If `country` and/or `start` and `end` parameters are passed,
#' accesses the **population** developer API endpoint and pulls in all data.
#' filtered by those parameters. To get the population data for a specific
#' analysis, available on the **types/{id}** developer API endpoint,
#' pass in `id`. You cannot pass in both sets of parameters.
#'
#' Unlike the other `ipc_get_..()` family of functions, this returns a list of
#' datasets, corresponding to `country` data, `groups` data, and
#' `areas`/`points`data. The benefit of `ipc_get_population()` is that the
#' returned data for each level of analysis contains all periods of analysis.
#' Areas and points data is the lowest level of IPC analysis where population
#' estimates for each phase are provided and a general area-level classification
#' is made. Groups data, where available, are geographies within a country that
#' comprise multiple areas and/or points. There is no phase classification at
#' the group level, but populations in each phase are provided. The same applies
#' to country-level data.
#'
#' These datasets are available elsewhere through:
#'
#' * Country data: [ipc_get_country()]
#' * Groups data: Not available through other functions
#' * Areas and points data: [ipc_get_areas()]
#'
#' See the respective function documentation for more details on what each
#' dataset comprises or the [IPC website](https://www.ipcinfo.org) and
#' [API documentation](https://docs.api.ipcinfo.org) for more detailed and
#' comprehensive information on the data and analysis.
#'
#' @inheritParams ipc_get_areas
#' @param start Start year.
#' @param end End year.
#'
#' @examples
#' \dontrun{
#' # get all areas from the public API
#' ipc_get_population()
#'
#' # get areas for specific analysis ID and period from developer API
#' ipc_get_population(id = 12856213)
#' }
#'
#' @return A list of 3 data frames:
#' * Country data frame
#' * Groups data frame
#' * Areas data frame
#'
#' @export
ipc_get_population <- function(
    country = NULL,
    start = NULL,
    end = NULL,
    id = NULL,
    api_key = NULL
  ) {
  assert_country(country)
  assert_start_end(start, end)
  assert_id(id, country, start, end)

  df <- ipc_get(
    resource = paste(c("population", id), collapse = "/"),
    api_key = api_key,
    country = country,
    start = start,
    end = end,
    drop_metadata = TRUE
  )

  clean_population_df(df)
}

#' Convert phases list to data frame.
#'
#' Cleans up the phases list to allow unnesting. Drops the `overall_phase`
#' column, then converts to data frame.
#'
#' @param phases_list Phases list
#'
#' @noRd
point_phases_as_df <- function(phases_list) {
  phases_list[["overall_phase"]] <- NULL
  dplyr::as_tibble(phases_list)
}


#' Clean population data frame
#'
#' @noRd
clean_population_df <- function(df) {
  # rename for all sub-data frames
  # only needed to do once
  renamed_df <- rename_population_df(df) %>%
    dplyr::rename("anl_id" := "id") %>%
    dplyr::rename_with(
      .cols = dplyr::ends_with("period_dates"),
      .f = ~ paste0(
        "period_dates_",
        stringr::str_remove(.x, "_period_dates")
      )
    )

  # get the country data frame
  country_df <- renamed_df %>%
    pivot_population_df() %>%
    create_date_columns() %>%
    dplyr::select(
      -dplyr::any_of(
        c("groups", "areas")
      )
    ) %>%
    dplyr::distinct() %>%
    arrange_population_df()

  # extract groups data frame
  if ("groups" %in% names(renamed_df)) {
    renamed_groups_df <- renamed_df %>%
      dplyr::filter(
        !sapply(.data$groups, is.null)
      ) %>%
      dplyr::select(
        -c(dplyr::any_of("areas"), dplyr::matches("^phase|^estimated"))
      ) %>%
      dplyr::mutate(
        "groups" := purrr::map(.data$groups, dplyr::as_tibble)
      ) %>%
      tidyr::unnest(
        cols = "groups"
      ) %>%
      rename_population_df() %>%
      dplyr::rename(
        "group_id" := "id",
        "group_name" := "name"
      )

    groups_df <- renamed_groups_df %>%
      dplyr::select(-dplyr::any_of("areas")) %>%
      dplyr::distinct() %>%
      pivot_population_df() %>%
      dplyr::filter(.data$period_dates != "") %>%
      create_date_columns() %>%
      arrange_population_df()
  } else {
    groups_df <- NULL
  }


  # extract areas data frame
  # have to do in two stages, extracting areas that don't have groups
  # then extracting again from areas under groups
  if ("areas" %in% names(renamed_df)) {
    renamed_areas_df1 <- renamed_df %>%
      dplyr::filter(
        !sapply(.data$areas, is.null)
      ) %>%
      dplyr::select(
        -c(dplyr::any_of("groups"), dplyr::matches("^phase|^estimated"))
      ) %>%
      dplyr::mutate(
        "areas" := purrr::map(.data$areas, dplyr::as_tibble)
      ) %>%
      tidyr::unnest(
        cols = "areas"
      ) %>%
      rename_population_df()
  } else {
    renamed_areas_df1 <- NULL
  }


  # now extract areas that are under groups
  if ("groups" %in% names(renamed_df)) {
    renamed_areas_df2 <- renamed_groups_df %>%
      dplyr::filter(
        !sapply(.data$areas, is.null)
      ) %>%
      dplyr::mutate(
        "areas" := purrr::map(.data$areas, dplyr::as_tibble)
      ) %>%
      dplyr::select(
        -c(dplyr::matches("^phase|^estimated"))
      ) %>%
      tidyr::unnest(
        cols = "areas"
      ) %>%
      rename_population_df()
  } else {
    renamed_areas_df2 <- NULL
  }


  # now combine into a single areas dataset
  # TODO: remove `-dplyr::starts_with("group")` once
  # the IPC team fixes the API, currently it duplicates
  # all areas in a country for each group
  areas_df <- dplyr::bind_rows(renamed_areas_df1, renamed_areas_df2) %>%
    pivot_population_df() %>%
    dplyr::filter(
      .data$period_dates != ""
    ) %>%
    create_date_columns() %>%
    dplyr::distinct(
      dplyr::across(
        -dplyr::starts_with("group") # TODO: remove once API is fixed
      )
    ) %>%
    dplyr::rename(
      "area_id" := "id",
      "area_name" := "name"
    ) %>%
    arrange_population_df()

  list(
    "country" = country_df,
    "groups" = groups_df,
    "areas" = areas_df
  )
}

#' Rename the population data frame
#'
#' Lots of renaming that needs to be done to ensure that the file is
#' able to be pivoted longer and then wider into a tidy format. Useful for
#' all levels of population data.
#'
#' @noRd
rename_population_df <- function(df) {
  df %>%
    dplyr::select(
      -dplyr::any_of(
        c(
          "period",
          "population",
          "population_percentage"
        )
      )
    ) %>%
    dplyr::rename_with(
      .cols = dplyr::everything(),
      .f = ~ stringr::str_replace_all(
        .x,
        c(
          "p3plus(?!_percentage|_number)" = "p3plus_population",
          "percentage" = "pct",
          "(?<!estimated)_population(?=$|_)" = "_num",
          "p3plus" = "phase3pl"
        )
      )
    ) %>%
    dplyr::rename_with(
      .cols = dplyr::matches("_pct$|_num$|_population$|overall_phase$"),
      .f = ~ paste0(.x, "_current")
    )
}

#' Pivot population data frame
#'
#' @noRd
pivot_population_df <- function(df) {
  df %>%
    tidyr::pivot_longer(
      cols = dplyr::matches("_projected$|_current$"),
      names_to = c(".value", "period"),
      names_pattern = "(.*)_(current|second_projected|(?<!second_)projected)"
    ) %>%
    dplyr::filter(
      !is.na(.data$phase2_num) # drops rows for periods that are missing
    )
}

#' Create new columns for dates
#'
#' Extracts new columns from `period_dates` for start and end of the period, while
#' ensuring that the `analysis_date` is converted to a date.
#'
#' @noRd
create_date_columns <- function(df) {
  df %>%
    dplyr::mutate(
      "analysis_date" := lubridate::dmy(paste("1", .data$analysis_date)),
      "analysis_period_start" := lubridate::floor_date(
        x = lubridate::dmy(
          paste("15", stringr::str_extract(.data$period_dates, "^(.*) -"))
        ),
        unit = "month"
      ),
      "analysis_period_end" := lubridate::ceiling_date(
        x = lubridate::dmy(
          paste("15", stringr::str_extract(.data$period_dates, "- (.*)$"))
        ),
        unit = "month"
      ) - lubridate::days(1),
      .after = "period_dates"
    )
}

#' Arrange population data frames
#'
#' @noRd
arrange_population_df <- function(df) {
  df %>%
    dplyr::arrange(
      dplyr::across(
        dplyr::any_of(
          c(
            "country",
            "groups_id",
            "areas_id",
            "analysis_period_start"
          )
        )
      )
    )
}
