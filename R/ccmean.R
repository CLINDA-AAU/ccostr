#' Calculates estimates of mean valus given censored cost data 
#'
#' This function converts scores from the EQ-5D-5L questionaire to Quality Adjusted Life Years. 
#' 
#' 
#' - Naive "Available Sample"
#' - Naive "Complete Case"
#' 
#' - LinT - Lin's method
#' - BT - Bang and Tsiatis's method 
#' - ZT - Zhao and Tian's method
#' 
#' @param ccmean Caldulates the estimates of mean costs
#' @return Different estimates
#' @export
#' @examples
#' ccmean(df, id="id", tcost="tcost", delta="delta", surv="surv")


ccmean <- function(x, id="id", cost="cost", start="start", stop="stop", delta="delta", surv="surv") {

# Ordering the dataset
x <- x[order(x$surv, x$delta),]
row.names(x) <- 1:nrow(x)


# Some calculations don't use cost history and therefore collapse by ID
  xf <- x %>% 
    group_by(id) %>% 
    summarize(cost = sum(cost, na.rm=T),
              delta = last(delta),
              surv = first(surv))


#################################################################
##                          section 1:                         ##
##                   Naive (Avaiable Sample)                   ##
#################################################################

# Costs are summed and a mean are found
available_sample <- mean(xf$cost)

available_sample_full <- c(available_sample, NA, NA, NA, NA)

#################################################################
##                          section 2:                         ##
##                    Naive (complete case)                    ##
#################################################################

# Costs are summed up and calculated mean
complete_case <- mean(xf$cost[xf$delta==1])

complete_case_full <- c(complete_case, NA, NA, NA, NA)


#################################################################
##                          section 4:                         ##
##                     Lin's method (1997)                     ##
#################################################################

# Kaplan-meier for censoring distribution get censoring times to define intervals
sc <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1))
censBreaks <- c(0, sc$time, Inf)
  
# calculate average costs of patients deceased within each interval
a <- subset(xf, delta == 1) %>% 
    mutate(ints = cut(surv, breaks = censBreaks)) %>%
    group_by(ints) %>% 
    summarise(mean = mean(cost))
  
# Get survival times for intervals
sd <- survfit(Surv(xf$surv, xf$delta == 1) ~ 1)
intLow <- as.numeric(gsub("\\(", "", sapply(strsplit(as.character(a$ints), ","), function(x) x[[1]])))
intHigh <- as.numeric(gsub("\\]", "", sapply(strsplit(as.character(a$ints), ","), function(x) x[[2]])))
svLow <- summary(sd, times = intLow)$surv
svHigh <- c(summary(sd, times = intHigh)$surv)
if(length(svHigh) < length(svLow)){ ## Add zero if last value of intHigh is Inf
	svHigh <- c(svHigh,0)
}
  
# Gathering the data in a new dataframe
d <- data.frame(a, "survDif" = svLow-svHigh)
    
# calculating Lin's T estimate of total costs 
LinT <- sum(d$survDif*d$mean, na.rm=T)
LinT_full <- c(LinT, NA, NA, NA, NA)

#################################################################
##                          section 5:                         ##
##               Bang and Tsiatis's method (2000)              ##
#################################################################

# Opposite Kaplain Meier - chance of censoring - for each period (cummulative)
sc <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1), 
              times = xf$surv)

# Save changes of censoring and time in seperate dataframe
sct <- data.frame(sc$time, sc$surv)

# adjust for last proparbility = 0 (why we do this i'm not sure)
sct$sc.surv[sct$sc.surv == 0] <- min(sct$sc.surv[sct$sc.surv != 0])

# remove non unique to avoid errors when merging
sct <- unique(sct)

# Merge with the dataset by surv, as that tells which the chance of being censored in each death
t <- merge(xf,sct,by.x="surv", by.y="sc.time", all.x=T)


# Calculating Band and Tsiatis cost estimator
BT <- mean((t$cost*t$delta)/t$sc.surv)



# START VAR BT ------------------------------------------------------------
n <- length(t$cost)

t$sss  <- rev(cumsum(rev(t$delta * t$cost * t$sc.surv)))
t$ssss <- rev(cumsum(rev(t$delta * t$cost^2 * t$sc.surv)))
t$GA <- t$sc.surv/(n - 1:n + t$delta) * t$ssss
t$GB <- t$sc.surv/(n - 1:n + t$delta) * t$sss
t$GA[is.na(t$GA)] <- 0
t$GB[is.na(t$GB)] <- 0

BT_var <- 1/n * (mean(t$delta*(t$cost-BT)^2/t$sc.surv) + mean(((1-t$delta)/t$sc.surv^2 )* (t$GA - t$GB^2)))
BT_sd <- sqrt(BT_var)
BT_uci <- BT + (1.96 * BT_sd)
BT_lci <- BT - (1.96 * BT_sd)

BT_full <- c(BT, BT_var, BT_sd, BT_uci, BT_lci)

# END VAR BT --------------------------------------------------------------



#################################################################
##                          section 6:                         ##
##                Zhao and Tian's method (2001)                ##
#################################################################

## For each censored individual i calculate cost 
## of longer surviving individuals up till time ti
runCostMatrix <- matrix(0, nrow = nrow(t), ncol = nrow(t))
t$mcostlsurv <- 0
for(i in 1:nrow(t)){
  if(t$delta[i] == 1){
    next
  } else{
    t_data2 <- subset(x, start < t$surv[i])
    t_data2$cost <- ifelse(t_data2$stop > t$surv[i], 
                           (t_data2$cost/(t_data2$stop-t_data2$start))*(t$surv[i]-t_data2$start),
                           t_data2$cost)
    # summarized  
    t_data_total_temp <- t_data2 %>% 
      group_by(id) %>% 
      summarize(cost = sum(cost, na.rm=T),
                surv= first(surv))
    
    runCostMatrix[,i] <- t_data_total_temp$cost[order(t_data_total_temp$surv)]
    t$mcostlsurv[i]   <- mean(t_data_total_temp$cost[t_data_total_temp$surv >= t$surv[i]])
  }
}

ZT <- mean((t$delta * (t$cost / t$sc.surv)) + ((1-t$delta) * ((t$cost-t$mcostlsurv) / t$sc.surv)), na.rm=T)

## Estimate variance
tempSum1 <- 0
tempSum2 <- 0
n <- nrow(t)
for(i in 1:n){
  tempSum1[i] <- sum((t$delta[i:n] / t$sc.surv[i:n]) * 
                       (t$cost[i:n] - t$GB[i:n]) * (runCostMatrix[i:n,i] - t$mcostlsurv[i]))
  tempSum2[i] <- sum((runCostMatrix[i:n,i] - t$mcostlsurv[i])^2)
}

ztVAR <- BT_var - (2/n^2) * sum(((1-t$delta) / ((n + 1 - 1:n) * t$sc.surv)) * tempSum1)
+ (1/n^2) * sum(((1-t$delta) / ((n + 1 - 1:n) * t$sc.surv^2)) * tempSum2)


ZT_full <- c(ZT,
             ztVAR,
             sqrt(ztVAR),
             ZT + 1.96 * sqrt(ztVAR),
             ZT - 1.96 * sqrt(ztVAR))

#################################################################
##                          section 7:                         ##
##                           Results                           ##
#################################################################

results <- list("These results should be checked before ...",
                data.frame(available_sample, 
                           complete_case, 
                           LinT, 
                           BT,
                           ZT),
                data.frame(available_sample_full,
                           complete_case_full,
                           LinT_full,
                           BT_full,
                           ZT_full, 
                           row.names = c("Estimate", "Variance", "SD", "95UCI", "95LCI"))
                )

return(results)


}








