# ripc 0.3.0

* Restructured API calls so that `ipc_get()` is more robust by defaulting
to requesting a CSV return from the API rather than JSON, allowing for simpler
cleaning in all `ipc_get_...()` functions.
* Allow `return_format` to be specified as GeoJSON for `ipc_get_areas()`, directly
loading in an `sf` object.
* Improved the cleaning of `ipc_get_population()` nested JSONs to be more robust
to changes in the API.
* Set `R-CMD-check` GitHub Action to run weekly to check for changes to the API,
since all function examples are re-run during the check.

# ripc 0.2.1

* Improved `ipc_get_population()` to deal with missing areas data when it is
removed from the API.
* Fixed `assert_start_end()` so it correctly tests `start` and `end` parameters
without generating an error.
* Fixed `ipc_get()` to initially read all numeric vectors as character in as
some errors were created in nested data frames that only contained integers.
* Ensured that all `ipg_get_...()` functions returned properly parsed numeric
columns and fixed some unnesting data frames in `ipc_get_areas()`.

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
