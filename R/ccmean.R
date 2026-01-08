#' Calculates estimates of the mean cost with censored data
#'
#' @description This function calculates the mean cost for right-censored cost 
#' data over a period of L time units (days, months, years,...)
#'
#' @details The function returns four estimates. The first two are simple and biased
#' downwards, and included for comparison. The estimates are:
#' 
#' - AS: "Available Sample estimator" - The simple sample mean
#' 
#' - CC: "Complete Case estimator" - The mean of fully observed cases
#'
#' - BT: "Weighted Complete Case estimator" - Bang and Tsiatis's estimator
#'
#' - ZT: "Weighted Available estimator" - Zhao and Tian's estimator
#' 
#' The function needs the following in a dataframe:
#' 
#' - id: The id separating each individual
#' 
#' - cost: The total cost, or if start and stop provided the specific cost
#' 
#' - start: Start of cost
#' 
#' - stop: End of cost, if one time cost then start = stop
#' 
#' - delta: Event variable, 1 = event, 0 = no event
#' 
#' - surv: Survival
#' 
#' @param x A dataframe with columns: id, cost, delta and surv. If Cost history is available it can be specified by: start and stop,
#' @param L Limit. Mean cost is calculated up till L, if not specified L = max(surv)
#' @param addInterPol This parameter affects the interpolation of cost between two observed times. Defaults to zero.
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
#' @importFrom rlang .data
#' @importFrom data.table as.data.table := setDTthreads
#' @import ggplot2 dplyr survival msm knitr tibble


ccmean <- function(x, L = max(x$surv), addInterPol = 0) {
  
  if( !("id" %in% names(x)) | !("cost" %in% names(x)) | !("delta" %in% names(x)) | !("surv" %in% names(x)) ) 
    stop('Rename colums to: "id", "cost", "delta" and "surv"')
  
  
  #################################################################
  ##                          section 1:                         ##
  ##                      Basic adjustments                      ##
  #################################################################
  maxsurv <- max(x$surv) # if L is not set this is equal to limit
  
  ## Adjust cost and survival times for data with/without cost history
  if( ("start" %in% names(x)) & ("stop" %in% names(x)) ) { #With Cost history
    # Subset to estimation period	
    x$delta[x$surv >= L] <- 1
    x$surv               <- pmin(x$surv, L)
    x                    <- subset(x, x$start <= L)
    
    # Adjust overlapping costs and arranging data
    x <- x %>% 
      mutate(cost = ifelse(.data$stop > .data$surv, 
                           .data$cost * ((.data$surv - .data$start + addInterPol)/(.data$stop - .data$start + addInterPol)), 
                           .data$cost),
             stop = pmin(.data$stop, L)) %>% 
      arrange(.data$surv, .data$delta)
    
    # Some calculations do not use cost history, so collapsed by ID
    xf <- x %>% 
      group_by(.data$id) %>% 
      summarize(cost  = sum(.data$cost, na.rm = TRUE),
                delta = last(.data$delta),
                surv  = first(.data$surv))
    
  } else if (length(x$id) > length(unique(x$id))) {
    stop('No cost history but non-unique id tags')
  } else { # Without cost history
    message('No cost history found, can be set by: "start" and "stop"')
    xf <- x %>% 
      mutate(cost = ifelse(.data$surv > L, 
                           .data$cost * ((L + addInterPol)/(.data$surv + addInterPol)), 
                           .data$cost),
             delta = as.numeric(.data$surv >= L | .data$delta == 1),
             surv  = pmin(.data$surv, L)) %>% 
      arrange(.data$surv, .data$delta)
  }
  
  
  #################################################################
  ##                          section 2:                         ##
  ##                   Naive (Avaiable Sample estimator)         ##
  #################################################################
  
  # Basic naive estimate from mean of the complete samples
  AS      <- mean(xf$cost)
  AS_var  <- var(xf$cost) / nrow(xf)
  
  # Results of AS
  AS_full <- c(AS,
               AS_var,
               sqrt(AS_var),
               AS - 1.96 * sqrt(AS_var),
               AS + 1.96 * sqrt(AS_var))
  
  
  #################################################################
  ##                          section 3:                         ##
  ##                    Naive (Complete Case estimator)          ##
  #################################################################
  
  # Basic naive estimate from mean of the complete cases
  CC      <- mean(xf$cost[xf$delta == 1])
  CC_var  <-  var(xf$cost[xf$delta == 1]) / sum(xf$delta)
  
  # Results of CC
  CC_full <- c(CC,
               CC_var,
               sqrt(CC_var),
               CC - 1.96 * sqrt(CC_var),
               CC + 1.96 * sqrt(CC_var))
  
  
  #################################################################
  ##                          section 4:                         ##
  ##                     Lin's estimator (1997)                  ##
  #################################################################
   
  # WORKING ESTIMATOR, BUT DUE TO SIMILARITY WITH BT IT IS NOT ACTIVE
  #
  # # Kaplan-meier estimate for censoring distribution get censoring times to define intervals
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
  # # calculating Lin's T estimator of total costs 
  # LinT <- sum(d$survDif*d$mean, na.rm=T)
  
  
  #################################################################
  ##                          section 5:                         ##
  ##               Bang and Tsiatis's estimator (2000)           ##
  #################################################################
  
  # Kaplan-Meier estimate for the censoring distribution
  sc <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1), times = xf$surv)
  sct <- data.frame(sc$time, sc$surv)
  sct$sc.surv[sct$sc.surv == 0] <- min(sct$sc.surv[sct$sc.surv != 0])
  sct <- unique(sct)
  
  # Kaplan-Meier estimate for the survival distribution
  s <- summary(survfit(Surv(xf$surv, xf$delta) ~ 1), times = xf$surv)
  st <- data.frame(s$time, s$surv)
  st <- unique(st)
  
  # Merge probabilities of censoring and survival to date
  t <- merge(xf, sct, by.x = "surv", by.y = "sc.time", all.x = T)
  t <- merge(t,  st,  by.x = "surv", by.y = "s.time",  all.x = T)
  
  # Calculation of the BT estimator
  BT <- mean((t$cost * t$delta) / t$sc.surv)
  
  # Variance of the BT estimator
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
  
  # Results of the BT estimator
  BT_full <- c(BT,
               BT_var,
               sqrt(BT_var),
               BT - 1.96 * sqrt(BT_var),
               BT + 1.96 * sqrt(BT_var))
  
  
  #################################################################
  ##                          section 6:                         ##
  ##                Zhao and Tian's estimator (2001)             ##
  #################################################################
  
  if( ("start" %in% names(x)) & ("stop" %in% names(x)) ) {
  
  # Matrice and vectors to be filled with the for loop
  runCostMatrix  <- matrix(0, nrow = nrow(t), ncol = nrow(t))
  t$mcostlsurv   <- 0
  t$mcostlsurvSq <- 0
  setDTthreads(1)
  
  surv <- NULL
  start <- NULL # Hack to avoid NSE error in data.table
  cost <- NULL
  id <- NULL
  
  # For each censored individual the cost is calculated for longer 
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
  
  # Calculation of the ZT estimator
  ZT <- BT + mean(((1 - t$delta) * ((t$cost - t$mcostlsurv) / t$sc.surv)), na.rm = TRUE)
  
  # Variance of the ZT estimator
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
  
  # Results of the ZT estimator
  ZT_full <- c(ZT,
               ZT_var,
               sqrt(ZT_var),
               ZT - 1.96 * sqrt(ZT_var),
               ZT + 1.96 * sqrt(ZT_var))
  
  } else {
    ZT <- NA
    ZT_full <- rep(NA,5)
  }
  #################################################################
  ##                          section 7:                         ##
  ##                           Results                           ##
  #################################################################
  
  # Calculation of median survival time
  svl1 <- survival::survfit(Surv(xf$surv, xf$delta == 1) ~ 1)
  svl2 <- summary(svl1)[["table"]]
  
  # Results of all estimators are compiled
  results <- list(Text      = c("ccostr - Estimates of mean cost with censored data"),
                  Data      = data.frame("Observations"   = nrow(x), 
                                         "Individuals"    = nrow(xf), 
                                         "FullyObserved"  = sum(xf$delta == 1),
                                         "Limits"         = L,
                                         "TotalTime"      = sum(xf$surv),
                                         "MaxSurvival"    = maxsurv,
                                         row.names        = "N"),
                  First     = data.frame(AS, CC, BT, ZT),
                  Estimates = data.frame("AS"      = AS_full,
                                         "CC"      = CC_full,
                                         "BT"      = BT_full,
                                         "ZT"      = ZT_full, 
                                         row.names = c("Estimate", "Variance", "SE", "0.95LCL", "0.95UCL")),
                  Survival  = svl2
  )
  
  # The output is given as an S3 class
  class(results) <- "ccobject"
  
  results
}

