
<!-- README.md is generated from README.Rmd. Please edit that file -->
ccostr
======

**(warning estimates might be wrong)**

R package to calculate estimates of total costs with censored data

Overview
--------

The ccmean function returns 4 estimates, these are:

-   Naive "Available Sample"
-   Naive "Complete Case"
-   Lin's method: *Lin et al. (1997)*
-   Bang and Tsiatis's method: *Bang and Tsiatis (2000)*
-   Zhao and Tian's method:

Installation
------------

``` r
devtools::install_github("HaemAalborg/ccostr")
```

Data format
-----------

Cost data should look something like this

    #>  id tcost delta surv
    #>   A  2544     0  343
    #>   B  4245     0  903
    #>   C   590     1  445

It is possible to get better estimates of the true mean if cost history is available. This cost data can be both discreet or contenious if so the data should look something like this:

    #>  id start stop cost delta surv
    #>   A     1    1  550     0  343
    #>   A    30   82 1949     0  343
    #>   A    88   88   45     0  343
    #>   B    18  198 4245     0  903
    #>   C     1    5   23     1  445
    #>   C    67   88  567     1  445

Explanation of estimates
------------------------

The package calculates two conventional but wrong estimates of the mean cost. The first is the full sample which divides total costs of all observations with the number of observations. This is correct if there is no censoring present. If there is it is underestimating the real costs due to missing information.

<img src="img/fullsample.png"/>

The scecond is the complete cases, here all data but the complete is filtered out. This creates a bias towards short observations as they have a greater chance of not being removed.

<img src="img/completecase.png"/>

It is possible to come up with better estimates of the mean costs, there are two fundamental different approaches. The first takes into account only total costs over the whole period, but it is possible to improve this type of estimates if cost history is present. If that is the case this additional information is used in

### Estimates without cost history

<img src="img/LinT.png"/> <img src="img/LinTa.png"/>

LinT BT

<img src="img/BT.png"/>

### Estimates with cost history

LinA LinB ZT BTp

Usage
-----

``` r
library(ccostr)
library(survival)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

ccmean(df_1)
#> [[1]]
#> [1] "These results should be checked before ..."
#> 
#> [[2]]
#>   available_sample complete_case LinT  BT       ZT
#> 1         2459.667           590  295 295 337.1667
```

References
----------

1.  Lin, D. Y., E. J. Feuer, R. Etzioni, and Y. Wax. "Estimating Medical Costs from Incomplete Follow-Up Data." Biometrics 53, no. 2 (1997): 419-34.

2.  H Bang, AA Tsiatis; Estimating medical costs with censored data, Biometrika, Volume 87, Issue 2, 1 June 2000, Pages 329-343.

3.  Zhao, Hongwei, and Lili Tian. "On Estimating Medical Cost and Incremental Cost-Effectiveness Ratios with Censored Data." Biometrics 57, no. 4 (2001): 1002-008.
