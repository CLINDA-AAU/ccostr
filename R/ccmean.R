#' Calculates estimates of mean valus given censored cost data 
#'
#' This function converts scores from the EQ-5D-5L questionaire to Quality Adjusted Life Years. 
#' 
#' 
#' - Naive "full sample"
#' - Naive "complete case"
#' - Lin's method
#' - Bang and Tsiatis's method 
#' 
#' 
#' @param ccmean Converts the questionare scores
#' @return Different estimates
#' @export
#' @examples
#' ccmean(df, id="id", tcost="tcost", delta="delta", surv="surv")


ccmean <- function(x, id="id", tcost="tcost", delta="delta", surv="surv") {

#################################################################
##                          section 1:                         ##
##                     Naive (full sample)                     ##
#################################################################

# Costs are summed and a mean are found
full_sample <- x %>% 
  group_by(id) %>% 
  mutate(costs = sum(tcost, na.rm=T)) %>% 
  ungroup() %>% 
  summarize(m = mean(costs, na.rm=T)) %>%
  as.numeric()




#################################################################
##                          section 2:                         ##
##                    Naive (complete case)                    ##
#################################################################

# Restricted to only full cases where the patient dies before 1461
b <- subset(x, x$delta == 1)


# Costs are summed up and calculated mean
complete_case <- b %>% 
  group_by(id) %>% 
  mutate(costs = sum(tcost, na.rm=T)) %>% 
  ungroup() %>% 
  summarize(m = mean(costs, na.rm=T)) %>%
  as.numeric()




#################################################################
##                          section 4:                         ##
##                     Lin's method (1997)                     ##
#################################################################

# a calculation of chance of survival for each interval (cummulative) (interval = censoring)
sv <- summary(survfit(Surv(x$surv, x$delta == 1) ~ 1))


# calculate average costs of patients deceased within each interval
a <- subset(x, delta == 1) %>% 
  mutate(ints = cut(surv, breaks = c(sv$time))) %>% 
  group_by(ints) %>% 
  summarise(mean = mean(tcost))


# Function to calculate chance of death within each interval
mydiff <- function(data, diff){
  c(diff(data, lag = diff), rep(NA, diff))
}
dif <- mydiff(sv$surv, 1)*-1


# Gathering the data in a new dataframe
d <- data.frame(sv$time, sv$surv, dif, a)
rm(dif)


# calculating Lin's T estimate of total costs 
LinT <- sum(d$dif*d$mean, na.rm=T) + (tail(d$sv.surv, n=1)*tail(d$mean, n=1))




#################################################################
##                          section 5:                         ##
##               Bang and Tsiatis's method (2000)              ##
#################################################################

# Opposite Kaplain Meier - chance of censoring - for each period (cummulative)
sc <- summary(survfit(Surv(x$surv, x$delta == 0) ~ 1), 
              times = x$surv[x$delta == 1])

# Save changes of censoring and time in seperate dataframe
sct <- data.frame(sv$time, sv$surv)


# Merge with the dataset by surv, as that tells which the chance of being censored in each death
t <- merge(x,sct,by.x="surv", by.y="sv.time", all.x=T)


# Calculating Band and Tsiatis cost estimator
BT <- mean((t$tcost*t$delta)/t$sv.surv, na.rm=T)




#################################################################
##                          section 6:                         ##
##                                                             ##
#################################################################

results <- list("These results should be checked before ...",
                data.frame(full_sample, 
                           complete_case, 
                           LinT, 
                           BT))

return(results)


}
