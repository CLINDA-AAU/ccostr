#' @description Not ready for use... still experimental
#' @details Not ready for use... still experimental
#' 
#' @param x A dataframe with columns: id, cost, delta and surv. If Cost history is available it can be specified by: start and stop,
#' @param L limit of time
#' 
#' @return An score.
#' 
#' @examples
#' BTp(simCostData(100)$censoredCostHistory, L = 10)
#' 
#' 
#' @importFrom data.table as.data.table := data.table first
#' @import survival tibble

BTp <- function(x, L = 10) {
  # BTp
  x  <- as.data.table(x)
  xf <- x[,.(delta = data.table::first(delta), 
             surv = data.table::first(surv)), 
          by = id]
  scf <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1), times = c(1:L, xf$surv))
  scf <- data.table(surv = scf$time, scf.surv = scf$surv)
  
  BTp <- NULL
  for (i in 1:L) {
    sx <- x[start == i - 1]
    sx[,                delta := ifelse(stop == i, 1, delta)]
    sx[,                 surv := pmin(stop, surv)]
    sx[scf, on = "surv", surv := i.scf.surv]
    
    BTp[i] <- sum((sx$cost * sx$delta) / sx$surv, na.rm = TRUE)
  }
  
  estimate <- sum(BTp) / nrow(xf)
  estimate
}




