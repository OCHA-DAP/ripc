
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
df_list$country
#> # A tibble: 411 × 23
#>    anl_id   title      country condi…¹ analy…² view_…³ period perio…⁴ analysis…⁵
#>    <chr>    <chr>      <chr>   <chr>   <chr>   <chr>   <chr>  <chr>   <date>    
#>  1 12166797 Acute Foo… AF      A       May 20… area    curre… May 20… 2017-05-01
#>  2 12166890 Acute Foo… AF      A       Sep 20… area    curre… Aug 20… 2017-08-01
#>  3 12527589 Acute Foo… AF      A       Jan 20… area    curre… Nov 20… 2017-11-01
#>  4 12856213 Acute Foo… AF      A       Sep 20… area    curre… Aug 20… 2018-08-01
#>  5 12856213 Acute Foo… AF      A       Sep 20… area    proje… Nov 20… 2018-11-01
#>  6 13928767 Acute Foo… AF      A       Sep 20… area    curre… Aug 20… 2019-08-01
#>  7 13928767 Acute Foo… AF      A       Sep 20… area    proje… Nov 20… 2019-11-01
#>  8 15731853 Acute Foo… AF      A       Apr 20… area    curre… Apr 20… 2020-04-01
#>  9 15731853 Acute Foo… AF      A       Apr 20… area    proje… Jun 20… 2020-06-01
#> 10 18978466 Acute Foo… AF      A       Sep 20… area    curre… Aug 20… 2020-08-01
#> # … with 401 more rows, 14 more variables: analysis_period_end <date>,
#> #   phase3pl_num <int>, phase3pl_pct <dbl>, estimated_population <int>,
#> #   phase1_num <int>, phase1_pct <dbl>, phase2_num <int>, phase2_pct <dbl>,
#> #   phase3_num <int>, phase3_pct <dbl>, phase4_num <int>, phase4_pct <dbl>,
#> #   phase5_num <int>, phase5_pct <dbl>, and abbreviated variable names
#> #   ¹​condition, ²​analysis_date, ³​view_level, ⁴​period_dates,
#> #   ⁵​analysis_period_start
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

## Humanitarian Data Exchange data

[![Lifecycle:
deprecated](https://img.shields.io/badge/lifecycle-deprecated-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#deprecated)

Usage of functions to access data from the Humanitarian Data Exchange
are deprecated. These will be removed in future versions once the API
access is stable.

IPC data is stored on the [Humanitarian Data
Exchange](https://data.humdata.org/dataset/ipc-country-data), and this
package provides a simple interface to pull this data directly. However,
the data is also stored in a format not readily usable for analysis or
visualization. Thus, this package also automatically wrangles the data
into a format prepared for analysis. This functionality is documented
within `ipc_download()` and `ipc_wrangle()` respectively.

For the user, all that is needed is a simple one liner.

``` r
ipc_download()
#> Warning: `ipc_download()` has been deprecated as the recommended functions for
#> downloading IPC data directly pull from the IPC API. `ipc_get_population()`
#> most directly replicates the functionality of the deprecated `ipc_download()`
#> function.
#> # A tibble: 15,597 × 25
#>    country     level_…¹ area  area_id analy…² date_of_…³ count…⁴ analy…⁵ popul…⁶
#>    <chr>       <chr>    <chr>   <dbl> <chr>   <date>       <int> <chr>     <dbl>
#>  1 Afghanistan <NA>     Bada…  2.51e7 Acute … 2022-03-01       1 current 1401209
#>  2 Afghanistan <NA>     Bada…  2.51e7 Acute … 2022-03-01       1 first_… 1401209
#>  3 Afghanistan <NA>     Badg…  2.51e7 Acute … 2022-03-01       1 current  730566
#>  4 Afghanistan <NA>     Badg…  2.51e7 Acute … 2022-03-01       1 first_…  730566
#>  5 Afghanistan <NA>     Bagh…  2.51e7 Acute … 2022-03-01       1 current 1077131
#>  6 Afghanistan <NA>     Bagh…  2.51e7 Acute … 2022-03-01       1 first_… 1077131
#>  7 Afghanistan <NA>     Bagh…  2.51e7 Acute … 2022-03-01       1 current  271631
#>  8 Afghanistan <NA>     Bagh…  2.51e7 Acute … 2022-03-01       1 first_…  271631
#>  9 Afghanistan <NA>     Balkh  2.51e7 Acute … 2022-03-01       1 current 1356012
#> 10 Afghanistan <NA>     Balkh  2.51e7 Acute … 2022-03-01       1 first_… 1356012
#> # … with 15,587 more rows, 16 more variables: phase <dbl>,
#> #   analysis_period <chr>, analysis_period_start <date>,
#> #   analysis_period_end <date>, phase_1_num <dbl>, phase_1_pct <dbl>,
#> #   phase_2_num <dbl>, phase_2_pct <dbl>, phase_3_num <dbl>, phase_3_pct <dbl>,
#> #   phase_4_num <dbl>, phase_4_pct <dbl>, phase_5_num <dbl>, phase_5_pct <dbl>,
#> #   phase_3pl_num <dbl>, phase_3pl_pct <dbl>, and abbreviated variable names
#> #   ¹​level_1_name, ²​analysis_name, ³​date_of_analysis, ⁴​country_group, …
```

## Help and issues

For any help, please file an issue on
[Github](https://github.com/OCHA-DAP/Ripc/issues). If the issue relates
to downloading the data from HDX, please refer to the [rhdx
package](https://github.com/dickoa/rhdx).
