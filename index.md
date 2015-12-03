# Practical Machine Learning Course Project
Len Greski  
November 30, 2015  

This is a sample document, including some of the default Rmd content to illustrate display of the page on a `gh-pages` website until we post actual content related to the Practical Machine Learning course project in December 2015. 

Test run with formulas to validate how Mathjax works on a github.io website. 

## Why does $\sum_i^ne_iX_i = 0$?

Here is the derivation that illustrates why $\sum_i^ne_iX_i = 0$. 

\(\sum_i^n e_iX_i = \sum_i^ne_iX_i - \sum_i^ne_i\bar X_i\)  because \(\sum_i^n e_i = 0\)

$\sum_i^n e_iX_i = \sum_i^n e_i(X_i - \bar X)$

$\sum_i^n e_iX_i = \sum(Y_i - \bar Y)(X_i - \bar X) - \beta_1\sum_i^n(X_i - \bar X)^2$ since $\beta_0 = \bar Y - \beta_1\bar X$ 

$\sum_i^n e_iX_i = 0$ since $\beta_1 = \frac{\sum_i^n e_i(Y_i - \bar Y)(X_i - \bar X)}{\sum_i^n e_i(X_i - \bar X)^2}$


```r
summary(cars)
```

```
##      speed           dist       
##  Min.   : 4.0   Min.   :  2.00  
##  1st Qu.:12.0   1st Qu.: 26.00  
##  Median :15.0   Median : 36.00  
##  Mean   :15.4   Mean   : 42.98  
##  3rd Qu.:19.0   3rd Qu.: 56.00  
##  Max.   :25.0   Max.   :120.00
```

You can also embed plots, for example:

![](index_files/figure-html/unnamed-chunk-2-1.png) 

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
