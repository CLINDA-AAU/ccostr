
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ccostr

Standard statistical methods for survival data should NOT be used for
medical cost data, ccostr is an R package to calculate estimates of
total costs with censored data based two commonly accepted estimators.

## Overview

The ccmean function implements 4 estimators, these are:

  - Naive “Available Sample”
  - Naive “Complete Case”
  - Bang and Tsiatis’s method: *Bang and Tsiatis (2000)*
  - Zhao and Tian’s method: *Zhao and Tian (2001)*

## Installation

``` r
devtools::install_github("HaemAalborg/ccostr")

# Or including a vignette that demonstrates the bias and coverage of the estimators
devtools::install_github("HaemAalborg/ccostr", build = TRUE, build_opts = c("--no-resave-data", "--no-manual"))
```

## Data format

Cost data should look something like this:

| id | cost | delta | surv |
| :- | ---: | ----: | ---: |
| A  | 2544 |     0 |  343 |
| B  | 4245 |     0 |  903 |
| C  |  590 |     1 |  445 |

It is possible to get better estimates of the true mean if cost history
is available. This cost data can be both discrete or continuous. If so
the data should look something like this:

| id | start | stop | cost | delta | surv |
| :- | ----: | ---: | ---: | ----: | ---: |
| A  |     1 |    1 |  550 |     0 |  343 |
| A  |    30 |   82 | 1949 |     0 |  343 |
| A  |    88 |   88 |   45 |     0 |  343 |
| B  |    18 |  198 | 4245 |     0 |  903 |
| C  |     1 |    5 |   23 |     1 |  445 |
| C  |    67 |   88 |  567 |     1 |  445 |

## Explanation of estimates

The package calculates two conventional but wrong estimates of the mean
cost. The first is the available sample (AS) which divides total costs
of all observations with the number of observations. This is correct if
there is no censoring present. With censored data it is underestimating
the real costs due to missing information. The second is the complete
cases (CC), here all incomplete cases is filtered out. This creates a
bias towards short cases as they have a greater chance of not being
removed, and this would normally also give a downward bias.

<p align="center">

<img src="img/f1.png" height="55"/>

</p>

It is possible to come up with better estimates of the mean costs. The
first is the estimator proposed by Bang and Tsiatis (BT) where complete
cases are weighted with the probability of being censored at thier
eventtime.

<p align="center">

<img src="img/f2.png" height="60"/>

</p>

The BT estimator doesn’t take account of cost history. This additional
information is used in the estimator proposed by Zhao and Tian (ZT)

<p align="center">

<img src="img/f3.png" height="65"/>

</p>

## Usage

First the function is used on the previous df

``` r
library(ccostr)

df_1_res <- ccmean(df_1)

df_1_res
#> ccostr - Estimates of mean cost with censored data
#> 
#>   Observations Induviduals Events Limits TotalTime MaxSurv
#> N            6           3      1    903      1691     903
#> 
#>                 Estimate   Variance      SD   95UCI    95LCI
#> AvailableSample  2459.67 1115030.11 1055.95 4529.33   390.00
#> CompleteCase      590.00         NA      NA      NA       NA
#> BT                295.00   36260.42  190.42  668.23   -78.23
#> ZT                337.17  550262.97  741.80 1791.09 -1116.76
#> 
#> Mean survival time: 674 With SE: 161.93
```

## Data simulation function

Data is now simulated with the simCostData function:

``` r
# With the uniform distribution the true mean is 40.000, see documentation for further details.
sim <- simCostData(n = 1000, dist = "unif", censor = "heavy", L = 10)

sim_res <- ccmean(sim$censoredCostHistory)

print(sim_res)
#> ccostr - Estimates of mean cost with censored data
#> 
#>   Observations Induviduals Events   Limits TotalTime  MaxSurv
#> N         3998        1000    582 9.975437  3482.195 9.975437
#> 
#>                 Estimate Variance     SD    95UCI    95LCI
#> AvailableSample 28625.74 181210.9 425.69 29460.09 27791.39
#> CompleteCase    37775.93 150948.7 388.52 38537.43 37014.43
#> BT              40044.41 164040.4 405.02 40838.25 39250.57
#> ZT              40032.55 162171.9 402.71 40821.85 39243.24
#> 
#> Mean survival time: 5.01 With SE: 0.11
```

## References

1.  Lin, D. Y., E. J. Feuer, R. Etzioni, and Y. Wax. “Estimating Medical
    Costs from Incomplete Follow-Up Data.” Biometrics 53, no. 2 (1997):
    419-34.

2.  H Bang, AA Tsiatis; Estimating medical costs with censored data,
    Biometrika, Volume 87, Issue 2, 1 June 2000, Pages 329-343.

3.  Zhao, Hongwei, and Lili Tian. “On Estimating Medical Cost and
    Incremental Cost-Effectiveness Ratios with Censored Data.”
    Biometrics 57, no. 4 (2001): 1002-008.
