#' Simulates censored cost data
#'
#' @description This function can be used to demonstrate the bias and coverage 
#' of the estimators in the ccmean function
#'
#' @details The function simulates survival times from either an uniform distribution 
#' or an exponential distribution, and there are two options of censoring, heavy or
#' light. The simulation is inspired by Lin (1997) 
#' 
#' @param n Number of individuals to simulate
#' @param dist Survival distribution either "unif" = unif(0,10) o r "exp" = exp (1/6)
#' @param censor Censoring "light" ~ 25\% or "heavy" ~ 40\%, changes a bit depending on cdist
#' @param cdist Distribution used to censor, "exp" exponential or "unif" uniform
#' @param L Number of years to summarize over
#' 
#' @return Simulation of censored cost
#' @references 
#' \insertRef{Lin1997}{ccostr}
#' @examples 
#' # The simulated data can be used to show how the estimators perform
#' 
#' simCostData(n = 100, dist = "unif", censor = "light", cdist = "exp", L = 10)
#' 
#' @export
#' 
#' @importFrom stats var runif rexp
#' @importFrom Rdpack reprompt

simCostData <- function(n = 100, dist = "unif", censor = "light", cdist = "exp", L = 10){
  
  annCost <- function(t, tau, L){
    cost <- 0
    
    for(j in 1:min(L, ceiling(t))){
      cost <- cost + min(t - (j - 1), 1) * tau[j]
    }
    return(cost)
  }
  
  totalCost <- function(t, M0, b, d, tau, L){
    M <- numeric(length = length(t))
    
    for(i in 1:length(t)){
      M[i] <-  M0[i] + b[i] * min(t[i],L) + d[i] * as.numeric(t[i] <= L)  + annCost(t[i], tau[,i], L)
    }
    return(M)
  }
  
  # Simulate survival times
  if (dist == "unif") {
    t <- runif(n = n, min = 0, max = 10)
    } else if (dist == "exp") {
    t <- rexp(n = n, rate = 1/6)
    } else {
    stop('Dist must be "unif" or "exp"')
    }
  
  # Simulate censoring
  if (censor == "light" & cdist == "exp") {
    C <- rexp(n = n, rate = 1/16)  
    } else if (censor == "heavy" & cdist == "exp") {
    C <- rexp(n = n, rate = 1/9)   
    } else if (censor == "light" & cdist == "unif") {
    C <- runif(n = n, min = 0, max = 20)  
    } else if (censor == "heavy" & cdist == "unif") {
    C <- runif(n = n, min = 0, max = 12.5)      
    } else {
    stop('censor must be "light" or "heavy"')
    }
  
  
  ## Simulate cost parameters
  M0        <- runif(n = n, min = 5000,  max = 15000) # Initial Cost
  b         <- runif(n = n, min = 1000,  max = 2600)  # Deterministic annual cost
  d         <- runif(n = n, min = 10000, max = 30000) # Terminal cost
  tau       <- matrix(data = runif(n = n*ceiling(max(t)), min = 0, max = 400), ncol = n)   # Random annual cost
  
  ## Calculate total cost for individuals over L years
  M         <- totalCost(t, M0, b, d, tau, L)
  
  ## Calculate follow-up and censoring indicator
  X         <- pmin(t, C)
  delta     <- as.integer(t < C)
  
  ## Columns for dataframe with censored cost history
  upperTime <- ceiling(X)
  id        <- rep(1:n, times = upperTime) 
  start     <- (unlist(sapply(upperTime, function(x) 1:x)) - 1) 
  stop      <- unlist(sapply(upperTime, function(x) 1:x))
  t         <- rep(X, times = upperTime)
  delta     <- rep(delta, times = upperTime)
  stop      <- pmin(stop, t)
  
  ## Calculate censored cost history in each interval / individual
  cost      <- numeric(length = length(id))
  
  for(i in 1:length(id)){
    cost[i] <- as.integer(start[i] == 0) * M0[id[i]] +      ## Initial cost if first interval
      (stop[i] - start[i]) * b[id[i]] +                     ## Fixed annual cost
      (stop[i] - start[i]) * tau[ceiling(stop[i]), id[i]] + ## Random annual cost
      as.integer(t[i] == stop[i]) * delta[i] * d[id[i]]     ## Terminal cost if last interval and not censored
  }
  
  ## Build output
  results <- data.frame(id, start, stop, cost,"surv" = t, delta)
  
  return(list("totalCost" = M, "censoredCostHistory" = results))
}

