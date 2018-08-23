
<!-- README.md is generated from README.Rmd. Please edit that file -->
CenCost
=======

An R package to calculate estimates of total costs with censored data

Overview
--------

Installation
------------

``` r
# The easiest way to install:
devtools::install_github("")
```

Data format
-----------

Cost data should look something like this

    #>  id tcost delta surv
    #>   A  2544     0  343
    #>   B  4245     0  903
    #>   C   590     1  445

It is possible to get better estimates of the true mean if cost history is available, if so the data should look something like this:

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

LinT BT

### Estimates with cost history

LinA LinB ZT BTp
