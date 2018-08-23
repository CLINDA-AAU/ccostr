
<!-- README.md is generated from README.Rmd. Please edit that file -->
CenCost
=======

A R package to calculate estimates of total costs with censored data

Overview
--------

Installation
------------

``` r
# The easiest way to install:
devtools::install_github("")
```

Usage
-----

Cost data should look something like this

    #>  id totalcost delta surv
    #>   A      2544     0  343
    #>   B      4245     0  903
    #>   C       590     1  445

It is possible to get better estimates of the true mean if cost history is available, if so the data should look something like this:

    #>  id start stop cost delta surv
    #>   A     1    1  550     0  343
    #>   A    30   82 1949     0  343
    #>   A    88   88   45     0  343
    #>   B    18  198 4245     0  903
    #>   C     1    5   23     1  445
    #>   C    67   88  567     1  445

$$Full Sample Mean = \\frac{\\sum\_{i=n}^nM\_i}{n}$$

$$Complete Case Mean = \\frac{\\sum\_{i=n}^n \\Delta\_iM\_i}{\\sum\_{i=n}^n \\Delta\_i}$$

![equation](http://www.sciweavers.org/tex2img.php?eq=%24%24Complete%20Case%20Mean%20%3D%20%5Cfrac%7B%5Csum_%7Bi%3Dn%7D%5En%20%5CDelta_iM_i%7D%7B%5Csum_%7Bi%3Dn%7D%5En%5CDelta_i%7D%24%24&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)
