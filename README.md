
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Ripc

<!-- badges: start -->

[![R-CMD-check](https://github.com/OCHA-DAP/Ripc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/OCHA-DAP/Ripc/actions/workflows/R-CMD-check.yaml)
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

IPC data is stored on the [Humanitarian Data
Exchange](https://data.humdata.org/dataset/ipc-country-data), and this
package provides a simple interface to pull this data directly. However,
the data is also stored in a format not readily usable for analysis or
visualization. Thus, this package also automatically wrangles the data
into a format prepared for analysis. This functionality is documented
within `ipc_download()` and `ipc_wrangle()` respectively.

For the user, all that is needed is a simple one liner.

``` r
library(Ripc)

ipc_download()
#> # A tibble: 15,597 × 26
#>    country level…¹ area  area_id analy…² date_…³ count…⁴ mutat…⁵ analy…⁶ popul…⁷
#>    <chr>   <chr>   <chr>   <dbl> <chr>   <chr>     <int> <lgl>   <chr>     <dbl>
#>  1 Afghan… <NA>    Bada…  2.51e7 Acute … Mar 20…       1 TRUE    current 1401209
#>  2 Afghan… <NA>    Bada…  2.51e7 Acute … Mar 20…       1 TRUE    first_… 1401209
#>  3 Afghan… <NA>    Badg…  2.51e7 Acute … Mar 20…       1 TRUE    current  730566
#>  4 Afghan… <NA>    Badg…  2.51e7 Acute … Mar 20…       1 TRUE    first_…  730566
#>  5 Afghan… <NA>    Bagh…  2.51e7 Acute … Mar 20…       1 TRUE    current 1077131
#>  6 Afghan… <NA>    Bagh…  2.51e7 Acute … Mar 20…       1 TRUE    first_… 1077131
#>  7 Afghan… <NA>    Bagh…  2.51e7 Acute … Mar 20…       1 TRUE    current  271631
#>  8 Afghan… <NA>    Bagh…  2.51e7 Acute … Mar 20…       1 TRUE    first_…  271631
#>  9 Afghan… <NA>    Balkh  2.51e7 Acute … Mar 20…       1 TRUE    current 1356012
#> 10 Afghan… <NA>    Balkh  2.51e7 Acute … Mar 20…       1 TRUE    first_… 1356012
#> # … with 15,587 more rows, 16 more variables: phase <dbl>,
#> #   analysis_period <chr>, analysis_period_start <date>,
#> #   analysis_period_end <date>, phase_1_num <dbl>, phase_1_pct <dbl>,
#> #   phase_2_num <dbl>, phase_2_pct <dbl>, phase_3_num <dbl>, phase_3_pct <dbl>,
#> #   phase_4_num <dbl>, phase_4_pct <dbl>, phase_5_num <dbl>, phase_5_pct <dbl>,
#> #   `phase_p3+_num` <dbl>, `phase_p3+_pct` <dbl>, and abbreviated variable
#> #   names ¹​level_1_name, ²​analysis_name, ³​date_of_analysis, ⁴​country_group, …
```

## Help and issues

For any help, please file an issue on
[Github](https://github.com/OCHA-DAP/Ripc/issues). If the issue relates
to downloading the data from HDX, please refer to the [rhdx
package](https://github.com/dickoa/rhdx).
