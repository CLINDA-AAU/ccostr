
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

# Or including a vignette that demonstrates the bias and coverage

devtools::install_github("HaemAalborg/ccostr", build_vignettes = TRUE)
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
cost. The first is the full sample which divides total costs of all
observations with the number of observations. This is correct if there
is no censoring present. With censored data it is underestimating the
real costs due to missing information.

<img src="img/AS.png" height="55"/>

The scecond is the complete cases, here all data but the complete is
filtered out. This creates a bias towards short observations as they
have a greater chance of not being removed, and this would normally also
give a downward bias.

<img src="img/CC.png" height="60"/>

It is possible to come up with better estimates of the mean costs. The
first is the BT estimator which weights the complete case with the …

<img src="img/BT.png" height="60"/>

But it is possible to improve this estimate if cost history is present.
This additional information is used in the ZT estimator

### Estimates with cost history

<img src="img/ZT.png" height="60"/>

## Usage

First the function is used on the previous df

``` r
library(ccostr)

df_1_res <- ccmean(df_1)

df_1_res
#> Ccostr - censored cost estimation
#> 
#>   Observations Induviduals Events Limits TotalTime MaxSurv
#> N            6           3      1    903      1691     903
#> 
#>          AvailableSample CompleteCase       BT        ZT
#> Estimate         2459.67          590   295.00    337.17
#> Variance      1115030.11           NA 36260.42 550262.97
#> SD               1055.95           NA   190.42    741.80
#> 95UCI            4529.33           NA   668.23   1791.09
#> 95LCI             390.00           NA   -78.23  -1116.76
#> 
#> Median survival time: 445 With SE: 161.93
```

## Data simulation function

Data is now simulated with the simCostData
function:

``` r
# With the uniform distribution the true mean is 40.000, see documentation for further details.
sim <- simCostData(n = 1000, dist = "unif", censor = "heavy", L = 10)

sim_res <- ccmean(sim$censoredCostHistory)

print(sim_res)
#> Ccostr - censored cost estimation
#> 
#>   Observations Induviduals Events   Limits TotalTime  MaxSurv
#> N         4179        1000    608 9.919895  3669.233 9.919895
#> 
#>          AvailableSample CompleteCase        BT        ZT
#> Estimate        29248.72     37373.85  39333.29  39311.65
#> Variance       160911.11    119958.38 146309.69 140268.67
#> SD                401.14       346.35    382.50    374.52
#> 95UCI           30034.95     38052.70  40083.00  40045.72
#> 95LCI           28462.49     36695.00  38583.59  38577.58
#> 
#> Median survival time: 4.87 With SE: 0.1
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
