#' ipc_population_raw
#'
#' The `ipc_population_raw` dataset contains a list of data frames representing the output of `ipc_get_population(tidy_df = F)`.
#' The data is subset to include only Palestine and Sudan for convenience and size reduction purposes.
#'
#' Each data frame in the list represents a different country, and contains population data for that country.
#'
#' @format An object of class list with 3 elements:
#' \describe{
#'   \item{country}{A data frame with 18 rows and 29 variables:
#'     \describe{
#'       \item{analysis_id}{Numeric vector with analysis IDs.}
#'       \item{title}{Character vector with titles.}
#'       \item{country}{Character vector with country codes.}
#'       \item{condition}{Character vector with conditions.}
#'       \item{analysis_date}{Character vector with analysis dates.}
#'       \item{view_level}{Character vector with view levels.}
#'       \item{ipc_period}{Character vector with IPC periods.}
#'       \item{population}{Numeric vector with population counts.}
#'       \item{population_percentage}{Character vector with population percentages.}
#'       \item{period}{Character vector with periods.}
#'       \item{from}{Character vector with start dates.}
#'       \item{to}{Character vector with end dates.}
#'       \item{analysis_period_start}{Date vector with analysis period start dates.}
#'       \item{analysis_period_end}{Date vector with analysis period end dates.}
#'       \item{p3plus}{Numeric vector with p3plus values.}
#'       \item{p3plus_percentage}{Numeric vector with p3plus percentages.}
#'       \item{estimated_population}{Numeric vector with estimated population counts.}
#'       \item{phase1_population}{Numeric vector with phase1 population counts.}
#'       \item{phase1_percentage}{Numeric vector with phase1 percentages.}
#'       \item{phase2_population}{Numeric vector with phase2 population counts.}
#'       \item{phase2_percentage}{Numeric vector with phase2 percentages.}
#'       \item{phase3_population}{Numeric vector with phase3 population counts.}
#'       \item{phase3_percentage}{Numeric vector with phase3 percentages.}
#'       \item{phase4_population}{Numeric vector with phase4 population counts.}
#'       \item{phase4_percentage}{Numeric vector with phase4 percentages.}
#'       \item{phase5_population}{Numeric vector with phase5 population counts.}
#'       \item{phase5_percentage}{Numeric vector with phase5 percentages.}
#'       \item{phase0_population}{Numeric vector with phase0 population counts.}
#'       \item{phase0_percentage}{Numeric vector with phase0 percentages.}
#'     }
#'   }
#'   \item{groups}{A data frame with 251 rows and 56 variables:
#'     \describe{
#'       \item{analysis_id}{Numeric. The ID of the analysis.}
#'       \item{title}{Character. The title of the analysis.}
#'       \item{country}{Character. The country code.}
#'       \item{condition}{Character. The condition code.}
#'       \item{analysis_date}{Character. The date of the analysis.}
#'       \item{view_level}{Character. The view level.}
#'       \item{ipc_period}{Character. The IPC period.}
#'       \item{population}{Numeric. The population count.}
#'       \item{population_percentage}{Character. The population percentage.}
#'       \item{group_id}{Numeric. The ID of the group.}
#'       \item{group_name}{Character. The name of the group.}
#'       \item{estimated_population}{Numeric. The estimated population count.}
#'       \item{p3plus_percentage}{Numeric. The phase 3+ percentage.}
#'       \item{p3plus}{Numeric. The phase 3+ population count.}
#'       \item{phase1_population}{Numeric. The phase 1 population count.}
#'       \item{phase1_percentage}{Numeric. The phase 1 percentage.}
#'       \item{phase2_population}{Numeric. The phase 2 population count.}
#'       \item{phase2_percentage}{Numeric. The phase 2 percentage.}
#'       \item{phase3_population}{Numeric. The phase 3 population count.}
#'       \item{phase3_percentage}{Numeric. The phase 3 percentage.}
#'       \item{phase4_population}{Numeric. The phase 4 population count.}
#'       \item{phase4_percentage}{Numeric. The phase 4 percentage.}
#'       \item{phase5_population}{Numeric. The phase 5 population count.}
#'       \item{phase5_percentage}{Numeric. The phase 5 percentage.}
#'       \item{p3plus_projected}{Numeric. The projected phase 3+ population count.}
#'       \item{p3plus_percentage_projected}{Numeric. The projected phase 3+ percentage.}
#'       \item{estimated_population_projected}{Numeric. The projected estimated population count.}
#'       \item{phase1_population_projected}{Numeric. The projected phase 1 population count.}
#'       \item{phase1_percentage_projected}{Numeric. The projected phase 1 percentage.}
#'       \item{phase2_population_projected}{Numeric. The projected phase 2 population count.}
#'       \item{phase2_percentage_projected}{Numeric. The projected phase 2 percentage.}
#'       \item{phase3_population_projected}{Numeric. The projected phase 3 population count.}
#'       \item{phase3_percentage_projected}{Numeric. The projected phase 3 percentage.}
#'       \item{phase4_population_projected}{Numeric. The projected phase 4 population count.}
#'       \item{phase4_percentage_projected}{Numeric. The projected phase 4 percentage.}
#'       \item{phase5_population_projected}{Numeric. The projected phase 5 population count.}
#'       \item{phase5_percentage_projected}{Numeric. The projected phase 5 percentage.}
#'       \item{areas}{List. A list of areas with their IDs, names, and population counts.}
#'       \item{p3plus_second_projected}{Numeric. The second projected phase 3+ population count.}
#'       \item{p3plus_percentage_second_projected}{Numeric. The second projected phase 3+ percentage.}
#'       \item{estimated_population_second_projected}{Numeric. The second projected estimated population count.}
#'       \item{phase1_population_second_projected}{Numeric. The second projected phase 1 population count.}
#'       \item{phase1_percentage_second_projected}{Numeric. The second projected phase 1 percentage.}
#'       \item{phase2_population_second_projected}{Numeric. The second projected phase 2 population count.}
#'       \item{phase2_percentage_second_projected}{Numeric. The second projected phase 2 percentage.}
#'       \item{phase3_population_second_projected}{Numeric. The second projected phase 3 population count.}
#'       \item{phase3_percentage_second_projected}{Numeric. The second projected phase 3 percentage.}
#'       \item{phase4_population_second_projected}{Numeric. The second projected phase 4 population count.}
#'       \item{phase4_percentage_second_projected}{Numeric. The second projected phase 4 percentage.}
#'       \item{phase5_population_second_projected}{Numeric. The second projected phase 5 population count.}
#'       \item{phase5_percentage_second_projected}{Numeric. The second projected phase 5 percentage.}
#'       \item{period}{Character. The period of the analysis.}
#'       \item{from}{Character. The start date of the analysis period.}
#'       \item{to}{Character. The end date of the analysis period.}
#'       \item{analysis_period_start}{Date. The start date of the analysis period.}
#'       \item{analysis_period_end}{Date. The end date of the analysis period.}
#'   }
#'   \item{areas}{A data frame with 6347 rows and 34 variables:
#'     \describe{
#'       \item{analysis_id}{Numeric vector with analysis IDs.}
#'       \item{title}{Character vector with titles.}
#'       \item{country}{Character vector with country codes.}
#'       \item{condition}{Character vector with conditions.}
#'       \item{analysis_date}{Character vector with analysis dates.}
#'       \item{view_level}{Character vector with view levels.}
#'       \item{ipc_period}{Character vector with IPC periods.}
#'       \item{population_percentage}{Character vector with population percentages.}
#'       \item{area_id}{Numeric vector with area IDs.}
#'       \item{area_name}{Character vector with area names.}
#'       \item{population}{Numeric vector with population counts.}
#'       \item{overall_phase_projected}{Numeric vector with overall projected phases.}
#'       \item{overall_phase}{Numeric vector with overall phases.}
#'       \item{overall_phase_second_projected}{Numeric vector with second projected overall phases.}
#'       \item{from}{Character vector with start dates.}
#'       \item{to}{Character vector with end dates.}
#'       \item{analysis_period_start}{Date vector with analysis period start dates.}
#'       \item{analysis_period_end}{Date vector with analysis period end dates.}
#'       \item{period}{Character vector with periods.}
#'       \item{p3plus}{Numeric vector with p3plus values.}
#'       \item{p3plus_percentage}{Numeric vector with p3plus percentages.}
#'       \item{estimated_population}{Numeric vector with estimated population counts.}
#'       \item{phase1_population}{Numeric vector with phase1 population counts.}
#'       \item{phase1_percentage}{Numeric vector with phase1 percentages.}
#'       \item{phase2_population}{Numeric vector with phase2 population counts.}
#'       \item{phase2_percentage}{Numeric vector with phase2 percentages.}
#'       \item{phase3_population}{Numeric vector with phase3 population counts.}
#'       \item{phase3_percentage}{Numeric vector with phase3 percentages.}
#'       \item{phase4_population}{Numeric vector with phase4 population counts.}
#'       \item{phase4_percentage}{Numeric vector with phase4 percentages.}
#'       \item{phase5_population}{Numeric vector with phase5 population counts.}
#'       \item{phase5_percentage}{Numeric vector with phase5 percentages.}
#'       \item{group_id}{Numeric vector with group IDs.}
#'       \item{group_name}{Character vector with group names.}
#'     }
#'   }
#' }
#' @source This data was obtained from the ipc API using the `ipc_get_population(tidy_df=F)` function.
#' @references
#'   - IPC - Integrated Food Security Phase Classification. (n.d.). Retrieved from http://www.ipcinfo.org/
#' @note The dataset is used for examples and unit-testing within the package.
"ipc_population_raw"

# ipc_population_raw$country
