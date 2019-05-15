#' Adding to the generic print function 
#' 
#' @param print.ccobject Returns a nicely formatted output
#' @return 
#' @export
#' @examples
#' 

print.ccobject <- function(obj) {
  cat("Ccostr - censored cost estimation\n\n")
  print(obj$Data, row.names=TRUE)
  cat("\n")
  print(obj$Estimates)
  cat("\nMedian survival time:", round(as.numeric(obj$Survival$matrix[5]),2), "With SE:", round(as.numeric(obj$Survival$matrix[6]),2))
}





#' Adding to the generic plot function 
#' 
#' @param plot.ccobject Plots the results
#' @return 
#' @export
#' @examples
#' 


plot.ccobject <- function(obj) {
  temp <- obj$Estimates %>%  t() %>% as.data.frame() %>% rownames_to_column(var="Estimator")
  temp$Estimator <- factor(temp$Estimator, labels = )
  
  temp %>% 
    ggplot(aes(y = Estimate, x = fct_reorder(Estimator,Estimate), ymax = .$"95UCI", ymin = .$"95LCI")) + 
    geom_point(shape=15, size=5) +  
    geom_errorbar(width = 0.2, size = 1.1) + 
    coord_flip() +
    labs(title="Estimators", x = "")
}