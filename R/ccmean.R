#' Calculates estimates of mean valus given censored cost data 
#'
#' This function calcutes the mean cost for right-censored cost data over a period of L time units (days, months, years,...)
#' 
#' 
#' - Naive "Available Sample"
#' - Naive "Complete Case"
#' 
#' - BT - Bang and Tsiatis's method 
#' - ZT - Zhao and Tian's method
#' 
#' @param ccmean Calculates the estimates of mean costs
#' @return Mean, Variance, SD, and 95% CI for the different estimates
#' @export
#' @examples
#' ccmean(df, id="id", tcost="tcost", delta="delta", surv="surv", L = NA)


ccmean <- function(x, id = "id", cost = "cost", start = "start", stop = "stop", delta = "delta", surv = "surv", L = NA, addInterPol = 0) {

# Set estimation period if undefined
if(is.na(L)) L <- max(x$surv)
	
# Subset to estimation period	
x$delta[x$surv > L] <- 1
x$surv <- pmin(x$surv, L)
x <- subset(x, start <= L)

# Adjust overlapping costs
x$cost <- ifelse(x$stop > x$surv, x$cost * ((x$surv-x$start + addInterPol)/(x$stop-x$start + addInterPol)), x$cost)
x$stop <- pmin(x$stop, L)

# Ordering the dataset
x <- x[order(x$surv, x$delta),]
row.names(x) <- 1:nrow(x)

# Some calculations don't use cost history and therefore collapse by ID
xf <- x %>% 
  group_by(id) %>% 
  summarize(cost  = sum(cost, na.rm=T),
            delta = last(delta),
            surv  = first(surv))


#################################################################
##                          section 1:                         ##
##                   Naive (Avaiable Sample)                   ##
#################################################################

# Costs are summed and a mean are found
AS <- mean(xf$cost)

AS_var <- var(xf$cost)

AS_full <- c(AS,
             AS_var,
             sqrt(AS_var),
             AS + 1.96 * sqrt(AS_var),
             AS - 1.96 * sqrt(AS_var))

#################################################################
##                          section 2:                         ##
##                    Naive (complete case)                    ##
#################################################################

# Costs are summed up and calculated mean
CC <- mean(xf$cost[xf$delta==1])

CC_var <- var(xf$cost[xf$delta==1])

CC_full <- c(CC,
             CC_var,
             sqrt(CC_var),
             CC + 1.96 * sqrt(CC_var),
             CC - 1.96 * sqrt(CC_var))


# #################################################################
# ##                          section 4:                         ##
# ##                     Lin's method (1997)                     ##
# #################################################################
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
sc <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1), 
              times = xf$surv)
sct <- data.frame(sc$time, sc$surv)
sct$sc.surv[sct$sc.surv == 0] <- min(sct$sc.surv[sct$sc.surv != 0])
sct <- unique(sct)

## Kaplan-Meier curve for survival
s <- summary(survfit(Surv(xf$surv, xf$delta) ~ 1), 
             times = xf$surv)
st <- data.frame(s$time, s$surv)
st <- unique(st)

# Merge probalities of censoring and survival to data
t <- merge(xf, sct, by.x = "surv", by.y = "sc.time", all.x = T)
t <- merge(t, st, by.x = "surv", by.y = "s.time", all.x = T)

# Calculate Bang and Tsiatis cost estimator
BT <- mean((t$cost*t$delta)/t$sc.surv)

# START VAR BT ------------------------------------------------------------

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


BT_full <- c(BT,
             BT_var,
             sqrt(BT_var),
             BT + 1.96 * sqrt(BT_var),
             BT - 1.96 * sqrt(BT_var))


# END VAR BT --------------------------------------------------------------



#################################################################
##                          section 6:                         ##
##                Zhao and Tian's method (2001)                ##
#################################################################

## For each censored individual i calculate cost 
## of longer surviving individuals up till time ti
runCostMatrix <- matrix(0, nrow = nrow(t), ncol = nrow(t))
t$mcostlsurv <- 0
t$mcostlsurvSq <- 0
for(i in 1:nrow(t)){
  if(t$delta[i] == 1){
    next
  } else{
    t_data2 <- subset(x, start <= t$surv[i])
    t_data2$cost <- ifelse(t_data2$stop > t$surv[i], 
                             (t_data2$cost/(t_data2$stop-t_data2$start + addInterPol))*
                               (t$surv[i]-t_data2$start +addInterPol),
                             t_data2$cost)
    # summarized  
    t_data_total_temp <- t_data2 %>% 
      group_by(id) %>% 
      summarize(cost = sum(cost, na.rm=T),
                surv= first(surv))
    
    # Store in runCostMatrix for kept ids
    idIndex <- t$id %in% t_data_total_temp$id
    ids     <- t$id[idIndex]
    runCost <- t_data_total_temp$cost
    names(runCost) <- t_data_total_temp$id
    runCostMatrix[idIndex,i] <- runCost[as.character(ids)]
      
    # Get mean runCost for longer surviving ids
    t$mcostlsurv[i]   <- mean(t_data_total_temp$cost[t_data_total_temp$surv >= t$surv[i]])
	t$mcostlsurvSq[i] <- mean(t_data_total_temp$cost[t_data_total_temp$surv >= t$surv[i]]^2)
  }
}

ZT <- mean((t$delta * (t$cost / t$sc.surv))) + mean(((1-t$delta) * ((t$cost-t$mcostlsurv) / t$sc.surv)), na.rm=T)

## Estimate variance
n <- nrow(t)
t$gm  <- rep(0,n)
t$gmm <- rep(0,n)
for(i in 1:n){
   if(t$delta[i] == 1) next
   t$gm[i]  <- (1/(n*t$s.surv[i])) * sum(as.numeric(t$surv >= t$surv[i]) * t$delta * runCostMatrix[,i] / t$sc.surv)
   t$gmm[i] <- (1/(n*t$s.surv[i])) * sum(as.numeric(t$surv >= t$surv[i]) * t$delta * t$cost * runCostMatrix[,i] / t$sc.surv)
}
  
ZT_var <- BT_var - (2/n^2) * sum(((1-t$delta) /  t$sc.surv^2) * (t$gmm - t$GB * t$gm)) + 
  (1/n^2) * sum(((1-t$delta) /  t$sc.surv^2) * (t$mcostlsurvSq - t$mcostlsurv^2))


ZT_full <- c(ZT,
             ZT_var,
             sqrt(ZT_var),
             ZT + 1.96 * sqrt(ZT_var),
             ZT - 1.96 * sqrt(ZT_var))

#################################################################
##                          section 7:                         ##
##                           Results                           ##
#################################################################

results <- list(Text  = c("CCOSTR - Estimation of censored costs"),
                Data  = data.frame(observations = nrow(x), 
                                   induviduals  = nrow(xf), 
                                   events       = sum(xf$delta==1), 
                                   row.names    = "n"),
                First = data.frame(AS, CC, BT, ZT),
                Estimates = round(data.frame("AvailableSample" = AS_full,
                                             "CompleteCase"    = CC_full,
                                             "BT"              = BT_full,
                                             "ZT"              = ZT_full, 
                                             row.names         = c("Estimate", "Variance", "SD", "95UCI", "95LCI")),2)
                )

results[c(1,2,4)]

}


ccmean(df_1)
ccmean(df_2)




