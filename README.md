
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Ripc

<!-- badges: start -->

[![R-CMD-check](https://github.com/OCHA-DAP/Ripc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/OCHA-DAP/Ripc/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of Ripc is to provide access to [Integrated Food Security Phase
Classification](https://www.ipcinfo.org) (IPC) data.

## Installation

You can install the Ripc like so:

``` r
# install.packages("remotes")
remotes::install_github("OCHA-DAP/Ripc")
```

The package is not currently available on CRAN.

## Usage

Ripc provides functionality to access IPC data stored directly on the
[IPC API](https://docs.api.ipcinfo.org). There are a wide set of
functions detailed further below, but most users will get the
information they need from the `ipc_get_population()` function which
returns datasets of country-level, group-level, and area-level analyses
in a list.

``` r
library(Ripc)

df_list <- ipc_get_population()
#> Warning: There were 2 warnings in `dplyr::mutate()`.
#> The first warning was:
#> ℹ In argument: `analysis_period_start = lubridate::floor_date(...)`.
#> Caused by warning:
#> !  24 failed to parse.
#> ℹ Run `dplyr::last_dplyr_warnings()` to see the 1 remaining warning.
df_list$country
#> # A tibble: 663 × 24
#>    anl_id   title   country condition analysis_date view_level ipc_period period
#>    <chr>    <chr>   <chr>   <chr>     <date>        <chr>      <chr>      <chr> 
#>  1 12166797 Acute … AF      A         2017-05-01    area       A          curre…
#>  2 12166890 Acute … AF      A         2017-09-01    area       A          curre…
#>  3 12527589 Acute … AF      A         2018-01-01    area       A          curre…
#>  4 12856213 Acute … AF      A         2018-09-01    area       A          curre…
#>  5 12856213 Acute … AF      A         2018-09-01    area       A          proje…
#>  6 13928767 Acute … AF      A         2019-09-01    area       A          curre…
#>  7 13928767 Acute … AF      A         2019-09-01    area       A          proje…
#>  8 15731853 Acute … AF      A         2020-04-01    area       A          curre…
#>  9 15731853 Acute … AF      A         2020-04-01    area       A          proje…
#> 10 18978466 Acute … AF      A         2020-09-01    area       A          curre…
#> # ℹ 653 more rows
#> # ℹ 16 more variables: period_dates <chr>, analysis_period_start <date>,
#> #   analysis_period_end <date>, phase3pl_num <int>, phase3pl_pct <dbl>,
#> #   estimated_population <int>, phase1_num <int>, phase1_pct <dbl>,
#> #   phase2_num <int>, phase2_pct <dbl>, phase3_num <int>, phase3_pct <dbl>,
#> #   phase4_num <int>, phase4_pct <dbl>, phase5_num <int>, phase5_pct <dbl>
```

More details on the API are available below.

## IPC API

The Ripc functions provide access to API endpoints detailed in the [IPC
API](https://docs.api.ipcinfo.org) documentation. The documentation
should be referred to in order to better understand the API calls
themselves (under the public and developer documentation sections), and
the returned data. For ease of the user, a table to match up the public
and developer API endpoints with Ripc functions is below.

## API and Ripc functions

In general, the same functions can access both API endpoints, but the
public API endpoints are accessed with optional parameters, but the
specific developer endpoints for IDs and/or periods are accessed by
explicitly specifying those parameters.

### Public API

| Ripc                 | IPC API  |
|:---------------------|:---------|
| `ipc_get_analyses()` | analyses |
| `ipc_get_country()`  | country  |
| `ipc_get_areas()`    | areas    |
| `ipc_get_points()`   | points   |
| `ipc_get_icons()`    | icons    |

### Developer API

| Ripc                                   | IPC API              |
|:---------------------------------------|:---------------------|
| `ipc_get_analyses(id = ###)`           | analysis/{id}        |
| `ipc_get_areas(id = ###, period = X)`  | areas/{id}/{period}  |
| `ipc_get_population()`                 | population           |
| `ipc_get_population(id = ###)`         | population/{id}      |
| `ipc_get_points(id = ###, period = X)` | points/{id}/{period} |
| `ipc_get_icons(id = ###, period = X)`  | icons/{id}/{period}  |

## API access

Please refer to the [IPC API
documentation](https://docs.api.ipcinfo.org) to learn how to generate a
token for the API you can use to access the data. This API key should be
stored in your environment as `IPC_API_KEY`. You can easily add this to
your environment by adding the following line to your `.Renviron` file,
easily accessed using `usethis::edit_r_environ()`.

    IPC_API_KEY="API key here"

Make sure that your API key is granted access to the resources you need.

## Output data

Data coming from the IPC API isn’t immediately joinable, with varying
naming conventions for geographical name/ID columns. Outputs from the
Ripc functions are wrangled to ease the joining of datasets together by
standardizing some column names and keeping the data in a tidy format.

The tidy format means that a specific analysis for a period (current,
projection, or second projection) and geography (area/point, group, or
country) are stored in a single row, with columns containing the
relevant metadata, phase classification, and population figures. Data
from mixed levels of geography are not stored in the same dataset.

While full documentation of output data can be derived from the [IPC API
schema documentation](https://docs.api.ipcinfo.org), some of the key
changes made to the outputs are documented here.

- `anl_id` is used across all datasets to identify the ID for a specific
  analysis.
- `area_id` and `area_name` is used to identify area and point IDs
  across the datasets.
- `group_id` and `group_name` for groups in the same manner.
- `title` refers solely to the title of the analysis.
- `phase#_num` and `phase#_pct` refer to the number of population and
  percent of population in each phase, respectively.
- `analysis_period_start` and `analysis_period_end` are created to be
  easy to access and manipulate date columns (rather than strings) in
  the dataset, representing the start of an analysis period (1st day of
  the first month) and end of an analysis period (last day of the last
  month).

## Memoisation

`ipc_get()`, the function that makes requests to the IPC API, has cached
functionality based on `memoise::memoise()` so that all of the
`ipc_get_...()` family of functions are cached in your local memory in a
single session. This means that once you’ve made a call to retrieve data
from the API, running an identical request will use the cached data
rather than re-request the data from the IPC database.

If you need to ensure that the Ripc package is making new requests to
the API each time is called, then you will need to run
`memoise::forget(Ripc:::ipc_get)` to clear the cache prior to repeating
a call. See the documentation of the [memoise
package](https://github.com/r-lib/memoise) for more details.

## Help and issues

For any help, please file an issue on
[Github](https://github.com/OCHA-DAP/Ripc/issues). If the issue relates
to downloading the data from HDX, please refer to the [rhdx
package](https://github.com/dickoa/rhdx).
