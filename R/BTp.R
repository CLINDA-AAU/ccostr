#' @description Not ready for use... still experimental
#' @details Not ready for use... still experimental
#' 
#' @param x A dataframe with columns: id, cost, delta and surv. If Cost history is available it can be specified by: start and stop,
#' @param n number of observations
#' 
#' @return An score.
#' 
#' @examples
#' BTp(simCostData(100)$censoredCostHistory, n=100)
#' 
#' 
#' @importFrom Rdpack reprompt
#' @importFrom rlang .data
#' @import dplyr survival knitr tibble

BTp <- function(x) {
  # BTp
  xf  <- x %>% 
    group_by(.data$id) %>% 
    summarize(delta = first(.data$delta),
              surv  = first(.data$surv))
  scf <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1), times = c(1:10, xf$surv))
  scf <- data.frame(scf$time, scf$surv)
  
  BTp <- NULL
  for (i in 1:10) {
    sx         <- subset(x, x$start == i - 1)
    sx$delta   <- ifelse(sx$stop == i, 1, sx$delta)
    sx$surv    <- pmin(sx$stop, sx$surv)
    sx         <- left_join(sx, scf, by = c("surv" = "scf.time"))
    BTp[i]     <- sum((sx$cost * sx$delta) / sx$scf.surv)
  }
  
  estimate <- sum(BTp)/nrow(xf)
  estimate
}




