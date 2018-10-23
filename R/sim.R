#' Sim
#' 
#' @param annCost something
#' @return something
#' @export
#' @examples something

## function to summarize random annual cost
annCost <- function(T, tau, L){
  cost <- 0
  for(j in 1:min(L, ceiling(T))){
    cost <- cost + min(T-(j-1), 1) * tau[j]
  }
  return(cost)
}

#' Sim
#' 
#' @param totalCost something
#' @return something
#' @export
#' @examples something

## Function to calculate totalcost
totalCost <- function(T, M0, b, d, tau, L){
  n <- length(T)
  M <- c()
  for(i in 1:n){
    M[i] <-  M0[i] + b[i]*min(T[i],L) + d[i]*as.numeric(T[i] <= L)  + annCost(T[i], tau[,i], L)
  }
  return(M)
}


#' Simulates data for control of estimates of censored costs - LIN
#' 
#' @param simCostData Simulates censored data
#' @return Different simulations
#' @export
#' @examples
#' simCostData(n = 100, dist = "unif", censor = "light", L = 10)

## Function to simulate cost data
## n is number of individuals to simulate
## dist is survival distribution either "unif" = unif(0,10) o r "exp" = exp (1/6)
## censor is "light" or "heavy" for unif(0,20) or unif(0,12.5)
## L is number of years to summarize over

simCostData <- function(n = 100, dist = "unif", censor = "light", L = 10){
  
  ## Simulate survival times
  if(dist == "unif"){
    T <- runif(n = n, min = 0, max = 10)
  } else{
    if(dist == "exp"){
      T <- rexp(n = n, rate = 1/6)
    } else{
      stop('Dist must be "unif" or "exp"')
    }
  }
  
  
  ## Simulate censoring
  if(censor == "light"){
    C <- runif(n = n, min = 0, max = 20)  
  } else{
    if(censor == "heavy"){
      C <- runif(n = n, min = 0, max = 12.5)   
    } else{
      stop('censor must be "light" or "heavy"')
    }
  }
  
  ## Simulate cost parameters
  M0  <- runif(n = n, min = 5000,  max = 15000) # Initial Cost
  b   <- runif(n = n, min = 1000,  max = 2600)  # Deterministic annual cost
  d   <- runif(n = n, min = 10000, max = 30000) # Terminal cost
  tau <- matrix(data = runif(n = n*L, min = 0, max = 400), ncol = 100)   # Random annual cost
  
  ## Calculate total cost for individuals over L years
  M <- totalCost(T, M0, b, d, tau, L)
  
  ## Calculate follow-up and censoring indicator
  X <- pmin(T, C, L)
  delta <- as.integer(T < C & T < L)
  
  ## Columns for dataframe with censored cost history
  upperTime <- ceiling(X)
  id    = rep(1:n, times = upperTime) 
  start = (unlist(sapply(upperTime, function(x) 1:x)) - 1) 
  stop  = unlist(sapply(upperTime, function(x) 1:x))
  t     = rep(X, times = upperTime)
  delta = rep(delta, times = upperTime)
  stop  = pmin(stop, t)
  
  ## Calculate censored cost history in each interval / individual
  cost <- 0
  for(i in 1:length(id)){
    cost[i] <- as.integer(start[i] == 0) * M0[id[i]] +         ## Initial cost if first interval
      min(1, t[i] - start[i]) * b[id[i]] +                     ## Fixed annual cost
      min(1, t[i] - start[i]) * tau[ceiling(stop[i]), id[i]] + ## Random annual cost
      as.integer(t[i] <= stop[i]) * delta[i] * d[id[i]]        ## Terminal cost if last interval and not censored
  }
  
  ## Build output
  results <- data.frame(id, start, stop, cost,"surv" = t, delta)
  Mcens <- tapply(cost, id, sum)
  return(list("totalCost" = M, "censoredCostHistory" = results))
}






#' Simulates data for control of estimates of censored costs - MARKOW
#' 
#' Transition rate matrix for the illness-death model with recovery
#' State 1: No treatment; State 2: Treatment; State 3: Death; State 4: Censoring
#' 
#' 
#' @param sim.patients Simulates censored data
#' @return Different simulations
#' @export
#' @examples
#' sim.patients(n = 100, censor = 0.05, cost = 100)



sim.patients <- function(n, censor=0.05, cost){
  
  lam12 <-  0.2
  lam21 <-  0.5
  lam13 <-  0.1
  lam14 <- censor
  lam23 <-  0.1 
  lam24 <- censor
  
  qmatrix <- rbind(
    c(   -1,    lam12,   lam13,  lam14),
    c(lam21,       -1,   lam23,  lam24),
    c(    0,        0,      -1,      0),
    c(    0,        0,       0,     -1))
  
  # Simulate n patients with transition rate matrix qmatrix and exponential 
  # cost/time-unit distribtion
  xxx <- data.frame(id = character(), times = numeric(), state = numeric(), cost = numeric())
  for(i in 1:n){
    tmp <- sim.msm(qmatrix, maxtime = Inf)
    tmp <- data.frame(i, tmp$times, tmp$states, 0)
    names(tmp) <- c("id", "times", "state", "cost")
    for(j in 1:nrow(tmp))
      if(tmp$state[j] == 2) tmp$cost[j] <- rexp(1,rate = 1/cost)
    xxx <- rbind(xxx,tmp)
  }
  
  xxx$surv <- ifelse(xxx$state > 2, xxx$times, 0)
  xxx$delta <- ifelse(xxx$state == 3, 1, 0)
  
  xxx$start <- xxx$times
  
  xxx$stop <- NA
  xxx$stop[-nrow(xxx)] <- ifelse(xxx$id[-nrow(xxx)] == xxx$id[-1], xxx$times[-1],NA)
  
  sim <- xxx %>%
    group_by(id) %>%
    mutate(delta = max(delta),
           surv = max(surv)) %>%
    filter(state == 2) %>% 
    select(c("id", "start", "stop", "cost", "surv", "delta"))
  
  sim$cost <- (sim$stop - sim$start) * sim$cost
  simcost <- tapply(sim$cost, sim$id, sum)
  
  return(list("totalCost" = simcost, "censoredCostHistory" = sim))
  
}


exact.cost <- function(lam, mu, gamma, delta){
  # Function to calculate the exact cost in the illness-death model with recovery
  f <- function(x, lam, mu, gamma, delta){
    lam/(lam + mu)*(x + exp(-1*(lam+mu)*x)/(lam+mu) - 1/(lam+mu)) * (gamma*exp(-1*gamma*x)) * delta
    #lam/(lam + mu)*(1-exp(-1*(lam+mu)*x)) * (gamma*exp(-1*gamma*x)) * delta
  }
  integrate(f, 0, Inf, lam, mu, gamma, delta)
}