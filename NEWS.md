# Development

# ripc 0.2.0

* Changed `anl_id` column to always be `analysis_id`.
* Implemented optional `tidy_df` parameter so user can choose to receive data as
returned direct from the API, and fully document cleaning in each function.
* Updated function documentation and vignettes to match the new simplified and advanced API endpoints.
* Improved date wrangling to avoid generating warnings for rows without explicit
dates.
* Added examples and explicit return values for all functions.
* Added links to the IPC-CH API and GitHub repository to DESCRIPTION.
* Memoisation functionality dropped to meet CRAN requirements.
* Initial CRAN release.

# ripc 0.1.7

* Adjusted `create_date_columns()` to avoid warnings when parsing missing
values in the `period_dates` column.

# ripc 0.1.6

* Removed HDX download functionality, and no longer depend on the rhdx package

# ripc 0.1.5

* Added `areas` output back to `ipc_get_populations()` as it was added back
to the IPC API

# ripc 0.1.4

* Fixed `ipc_get_populations()` by removing calculations for the `areas` data
frame which was removed from the API

# ripc 0.1.3

* `ipc_get_icons()` and `ipc_get_populations()` changed so all date columns
converted from character to date explicitly.

# ripc 0.1.2

* `ipc_get_analyses()` and `ipc_get_country()` changed to use `anl_id`.
* `ipc_get()` memoised to avoid repeated calls to the API. Now all 
`ipc_get_...()` functions are cached in a session.

# ripc 0.1.1

* `ipc_get_population()` was fixed so renaming worked correctly
* Update GitHub README and documentation.

# ripc 0.1.0

* IPC API functionality implemented.
* HDX download functionality deprecated.

# ripc 0.0.1

* Initial release.
