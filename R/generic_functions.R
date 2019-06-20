#' Adding to the generic print function 
#' 
#' @param x The ccobject
#' @param ... passthrough
#' @return a plot
#' @export
#' 

print.ccobject <- function(x, ...) {
  cat("Ccostr - censored cost estimation\n\n")
  print(x$Data, row.names=TRUE)
  cat("\n")
  print(x$Estimates)
  cat("\nMedian survival time:", round(as.numeric(x$Survival[[5]]),2), "With SE:", round(as.numeric(x$Survival[[6]]),2))
}





#' Adding to the generic plot function 
#' 
#' @param x The ccobject
#' @param ... passthrough
#' @return a plot
#' @import ggplot2 tibble forcats
#' @export
#' 

plot.ccobject <- function(x, ...) {
  temp <- x$Estimates %>%  t() %>% as.data.frame() %>% tibble::rownames_to_column(var="Estimator")
  temp$Estimator <- factor(temp$Estimator, labels = )
  
  temp %>% 
    ggplot(aes(y = temp$Estimate, x = fct_reorder(temp$Estimator,temp$Estimate), ymax = temp$"95UCI", ymin = temp$"95LCI")) + 
    geom_point(shape=15, size=5) +  
    geom_errorbar(width = 0.2, size = 1.1) + 
    coord_flip() +
    labs(title="Estimators", x = "")
}
