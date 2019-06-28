
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ccostr

ccostr is an R package to calculate estimates of mean total cost in
censored cost data, ie. in situations where data is not fully observed
within the study period.

## Installation

ccostr may be installed using the following command

``` r
devtools::install_github("HaemAalborg/ccostr")

# Or including a vignette that demonstrates the bias and coverage
devtools::install_github("HaemAalborg/ccostr", build = TRUE, build_opts = c("--no-resave-data", "--no-manual"))
```

# Overview

The main function of ccostr is ccmean(), which implements 4 estimators,
these are:

  - “Available Sample”
  - “Complete Case”
  - Bang and Tsiatis’s method: *Bang and Tsiatis (2000)*
  - Zhao and Tian’s method: *Zhao and Tian (2001)*

## Explanation of estimates

The package calculates two naïve but biased estimates of the mean cost.
The first is the full sample which divides total costs of all
observations with the number of observations. This is correct if there
is no censoring present. With censored data it underestimates the true
mean costs due to missing information.

<img src="img/AS.png" height="55"/>

The second is the complete case estimator, where only the fully observed
cases are used. This creates a bias towards observations with shorter
survival as they have a greater chance of not being censored, and this
would normally also give a downward bias.

<img src="img/CC.png" height="60"/>

The BT estimator *Bang and Tsiatis (2000)*, weights the cost for the
complete case with the probability of censoring at the event time.

<img src="img/BT.png" height="60"/>

If cost history is present, the above estimate may be improved by using
the ZT estimator *Zhao and Tian (2001)*.

<img src="img/ZT.png" height="60"/>

For all formulas above \(n\) is number of individuals, \(M_i\) and
\(\Delta_i\) are the total cost and event indicator for individual
\(i\), with \(\Delta_i = 1\) or \(\Delta_i = 0\) for respectively fully
observed and censored cases. \(\hat{K}(T_i)\) is the Kaplan-Meier
estimator of the probability of censoring at time \(T_i\), i.e. the time
of event for individual \(i\). \(\overline{M(C_i)}\) is the average of
cost until time \(C_i\) among individuals with event time later than
\(C_i\), and \(\hat{K}(C_i)\) is the Kaplan-Meier estimator of the
censoring probability at the time \(T_i\).

## Data format

The accepted data format for ccmean is a dataframe as shown below with
observations in rows. Columns detail the id for the observation, start
and stop time for a time interval, the cost for the interval, the
overall survival for the individual and a censoring indicator (1 = fully
observed, 0 = censored). The dataset may contain multiple rows for the
same individual detailing a cost history. If cost history is available,
including it may lead to better estimates.

| id | start | stop | cost | delta | surv |
| :- | ----: | ---: | ---: | ----: | ---: |
| A  |     1 |    1 |  550 |     0 |  343 |
| A  |    30 |   82 | 1949 |     0 |  343 |
| A  |    88 |   88 |   45 |     0 |  343 |
| B  |    18 |  198 | 4245 |     0 |  903 |
| C  |     1 |    5 |   23 |     1 |  445 |
| C  |    67 |   88 |  567 |     1 |  445 |

## Estimating the mean cost

The estimated average cost for the dataset shown above, is now
calculated using ccmean.

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

## Simulation of data

ccostr also includes a function for simulating data in the correct
format based on the method from Lin et
al. (1997).

``` r
# With the uniform distribution the true mean is 40.000, see documentation for further details.
sim <- simCostData(n = 1000, dist = "unif", censor = "heavy", L = 10)
sim_res <- ccmean(sim$censoredCostHistory)
sim_res
#> ccostr - Estimates of mean cost with censored data
#> 
#>   Observations Induviduals Events   Limits TotalTime  MaxSurv
#> N         4047        1000    585 9.961518  3532.989 9.961518
#> 
#>                 Estimate Variance     SD    95UCI    95LCI
#> AvailableSample 28798.26 161493.6 401.86 29585.91 28010.61
#> CompleteCase    37456.57 123561.4 351.51 38145.54 36767.60
#> BT              39539.80 150312.0 387.70 40299.69 38779.90
#> ZT              39134.36 150395.7 387.81 39894.46 38374.25
#> 
#> Mean survival time: 4.91 With SE: 0.11
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
