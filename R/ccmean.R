#' Calculates estimates of mean cost with censored data
#'
#' @description This function calcutes the mean cost for right-censored cost 
#' data over a period of L time units (days, months, years,...)
#'
#' @details The function returns 4 estimates, of which two are simple and biased 
#' downwards and should not be used, the estimates are:
#' 
#' - Naive "Available Sample"
#' 
#' - Naive "Complete Case"
#'
#' - "Weighted Complete Case" BT - Bang and Tsiatis's method 
#'
#' - "Weighted Available Sample" ZT - Zhao and Tian's method
#' 
#' @param x A dataframe
#' @param id The id seperating each individual
#' @param cost The total cost, or if start and stop provided the specific cost
#' @param start Start of cost
#' @param stop End of cost, if one time cost then start = stop
#' @param delta Event variable, 1 = event, 0 = no event
#' @param surv Survival
#' @param L Limit 
#' @param addInterPol Interpolation variable for ZT estimate
#' 
#' @return An object of class "ccobject".
#' 
#' @examples
#' hcost
#' ccmean(hcost, L = 1461, addInterPol = 1)
#' 
#' @references 
#' \insertRef{Bang2000}{ccostr}
#' 
#' \insertRef{Zhao2001}{ccostr}
#' 
#' @export
#' @importFrom Rdpack reprompt
#' @importFrom data.table as.data.table :=
#' @import ggplot2 dplyr survival msm knitr tibble


ccmean <- function(x, id = "id", cost = "cost", start = "start", stop = "stop", delta = "delta", surv = "surv", L = NA, addInterPol = 0) {
  
  #################################################################
  ##                          section 1:                         ##
  ##                      Basic adjustments                      ##
  #################################################################
  
  # Set estimation period if undefined
  if(is.na(L)) L <- max(x$surv)
  L2             <- max(x$surv)
  
  # Subset to estimation period	
  x$delta[x$surv > L] <- 1
  x$surv              <- pmin(x$surv, L)
  x                   <- subset(x, start < L)
  
  # Adjust overlapping costs and arranging data
  x <- x %>% 
    mutate(cost = ifelse(stop > surv, 
                         cost * ((surv-start + addInterPol)/(stop-start + addInterPol)), 
                         cost),
           stop = pmin(stop, L)) %>% 
    arrange(surv, delta)
  
  # Some calculations don't use cost history so is collapse by ID
  xf <- x %>% 
    group_by(id) %>% 
    summarize(cost  = sum(cost, na.rm=T),
              delta = last(delta),
              surv  = first(surv))
  
  
  #################################################################
  ##                          section 2:                         ##
  ##                   Naive (Avaiable Sample)                   ##
  #################################################################
  
  # Basic naive estimate from mean of the complete sample
  AS      <- mean(xf$cost)
  AS_var  <- var(xf$cost) / nrow(xf)
  
  # Results of AS
  AS_full <- c(AS,
               AS_var,
               sqrt(AS_var),
               AS + 1.96 * sqrt(AS_var),
               AS - 1.96 * sqrt(AS_var))
  
  
  #################################################################
  ##                          section 3:                         ##
  ##                    Naive (complete case)                    ##
  #################################################################
  
  # Basic naive estimate from mean of the complete observed cases
  CC      <- mean(xf$cost[xf$delta == 1])
  CC_var  <-  var(xf$cost[xf$delta == 1]) / sum(xf$delta)
  
  # Results of CC
  CC_full <- c(CC,
               CC_var,
               sqrt(CC_var),
               CC + 1.96 * sqrt(CC_var),
               CC - 1.96 * sqrt(CC_var))
  
  
  #################################################################
  ##                          section 4:                         ##
  ##                     Lin's method (1997)                     ##
  #################################################################
   
  # WORKING ESTIMATOR, BUT DUE TO SIMILARITY WITH BT IT IS NOT ACTIVE
  #
  # # Kaplan-meier for censoring distribution get censoring times to define intervals
  # sc <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1))
  # censBreaks <- c(0, sc$time, Inf)
  #   
  # # calculate average costs of patients deceased within each interval
  # a <- subset(xf, delta == 1) %>% 
  #     mutate(ints = cut(surv, breaks = censBreaks, dig.lab = 5)) %>%
  #     group_by(ints) %>% 
  #     summarise(mean = mean(cost))
  #   
  # # Get survival times for intervals
  # sd <- survfit(Surv(xf$surv, xf$delta == 1) ~ 1)
  # intLow <- as.numeric(gsub("\\(", "", sapply(strsplit(as.character(a$ints), ","), function(x) x[[1]])))
  # intHigh <- as.numeric(gsub("\\]", "", sapply(strsplit(as.character(a$ints), ","), function(x) x[[2]])))
  # svLow <- summary(sd, times = intLow)$surv
  # svHigh <- c(summary(sd, times = intHigh)$surv)
  # if(length(svHigh) < length(svLow)){ ## Add zero if last value of intHigh is Inf
  # 	svHigh <- c(svHigh,0)
  # }
  #   
  # # Gathering the data in a new dataframe
  # d <- data.frame(a, "survDif" = svLow-svHigh)
  #     
  # # calculating Lin's T estimate of total costs 
  # LinT <- sum(d$survDif*d$mean, na.rm=T)
  
  
  #################################################################
  ##                          section 5:                         ##
  ##               Bang and Tsiatis's method (2000)              ##
  #################################################################
  
  # Kaplan-Meier curve for censoring
  sc <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1), times = xf$surv)
  sct <- data.frame(sc$time, sc$surv)
  sct$sc.surv[sct$sc.surv == 0] <- min(sct$sc.surv[sct$sc.surv != 0])
  sct <- unique(sct)
  
  # Kaplan-Meier curve for survival
  s <- summary(survfit(Surv(xf$surv, xf$delta) ~ 1), times = xf$surv)
  st <- data.frame(s$time, s$surv)
  st <- unique(st)
  
  # Merge probalities of censoring and survival to data
  t <- merge(xf, sct, by.x = "surv", by.y = "sc.time", all.x = T)
  t <- merge(t,  st,  by.x = "surv", by.y = "s.time",  all.x = T)
  
  # Calculation of BT estimator
  BT <- mean((t$cost * t$delta) / t$sc.surv)
  
  # Variance of BT
  n <- length(t$cost)
  t$GA <- rep(0, n)
  t$GB <- rep(0, n)
  
  for(i in 1:n){
    if(t$delta[i] == 1) next
    t2 <- subset(t, surv >= t$surv[i])
    t$GA[i] <- (1 / (n*t$s.surv[i])) * sum(t2$delta * t2$cost^2 / t2$sc.surv)
    t$GB[i] <- (1 / (n*t$s.surv[i])) * sum(t2$delta * t2$cost / t2$sc.surv)
  }
  
  BT_var <- 1 / n * (mean(t$delta * (t$cost-BT)^2 / t$sc.surv) + 
                       mean(((1 - t$delta) / t$sc.surv^2 ) * (t$GA - t$GB^2)))
  
  # Results of BT
  BT_full <- c(BT,
               BT_var,
               sqrt(BT_var),
               BT + 1.96 * sqrt(BT_var),
               BT - 1.96 * sqrt(BT_var))
  
  
  #################################################################
  ##                          section 6:                         ##
  ##                Zhao and Tian's method (2001)                ##
  #################################################################
  
  # Matrice and vectors to be filled with for loop
  runCostMatrix  <- matrix(0, nrow = nrow(t), ncol = nrow(t))
  t$mcostlsurv   <- 0
  t$mcostlsurvSq <- 0
  
  # For each censored individual the cost is calculate for longer 
  # surviving individuals up till time ti
  for(i in 1:nrow(t)){
    if(t$delta[i] == 1){
      next
    } else {
      # Use of DT for improved speed
      DT <- data.table::as.data.table(x)[start <= t$surv[i]]
      DT <- DT[,cost := ifelse(stop > t$surv[i], (cost/(stop - start + addInterPol)) * (t$surv[i] - start + addInterPol), cost)]
      t_data2 <- DT[, list(cost = sum(cost), surv = first(surv)), by = list(id)]
      
      # Store in runCostMatrix for kept ids
      idIndex                   <- t$id %in% t_data2$id
      ids                       <- t$id[idIndex]
      runCost                   <- t_data2$cost
      names(runCost)            <- t_data2$id
      runCostMatrix[idIndex, i] <- runCost[as.character(ids)]
      
      # Get mean runCost for longer surviving ids
      t$mcostlsurv[i]   <- mean(t_data2$cost[t_data2$surv >= t$surv[i]])
      t$mcostlsurvSq[i] <- mean(t_data2$cost[t_data2$surv >= t$surv[i]]^2)
    }
  }
  
  # Calculation of ZT estimator
  ZT <- BT + mean(((1 - t$delta) * ((t$cost - t$mcostlsurv) / t$sc.surv)), na.rm = TRUE)
  
  # Variance of ZT
  n     <- nrow(t)
  t$gm  <- rep(0,n)
  t$gmm <- rep(0,n)
  
  for(i in 1:n){
    if(t$delta[i] == 1) next
    t$gm[i]  <- (1 / (n * t$s.surv[i])) * sum(as.numeric(t$surv >= t$surv[i]) * t$delta * runCostMatrix[,i]          / t$sc.surv)
    t$gmm[i] <- (1 / (n * t$s.surv[i])) * sum(as.numeric(t$surv >= t$surv[i]) * t$delta * t$cost * runCostMatrix[,i] / t$sc.surv)
  }
  
  ZT_var <- BT_var - (2 / n^2) * sum(((1 - t$delta) / t$sc.surv^2) * (t$gmm - t$GB * t$gm)) + 
    (1 / n^2) * sum(((1 - t$delta) / t$sc.surv^2) * (t$mcostlsurvSq - t$mcostlsurv^2))
  
  # Results of ZT
  ZT_full <- c(ZT,
               ZT_var,
               sqrt(ZT_var),
               ZT + 1.96 * sqrt(ZT_var),
               ZT - 1.96 * sqrt(ZT_var))
  
  
  #################################################################
  ##                          section 7:                         ##
  ##                           Results                           ##
  #################################################################
  
  # Calculation of median survival
  svl1 <- survival::survfit(Surv(xf$surv, xf$delta == 1) ~ 1)
  svl2 <- summary(svl1)[["table"]]
  
  # Results of all estimators
  results <- list(Text  = c("ccostr - Estimates of mean cost with censored data"),
                  Data  = data.frame(Observations = nrow(x), 
                                     Induviduals  = nrow(xf), 
                                     Events       = sum(xf$delta == 1),
                                     Limits       = L,
                                     TotalTime    = sum(xf$surv),
                                     MaxSurv      = L2,
                                     row.names    = "N"),
                  First = data.frame(AS, CC, BT, ZT),
                  Estimates = round(data.frame("AvailableSample" = AS_full,
                                               "CompleteCase"    = CC_full,
                                               "BT"              = BT_full,
                                               "ZT"              = ZT_full, 
                                               row.names         = c("Estimate", "Variance", "SD", "95UCI", "95LCI")),2),
                  Survival = svl2
  )
  
  # The output is given an S3 class
  class(results) <- "ccobject"
  
  results
}

