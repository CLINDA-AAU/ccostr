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

# a calculation of chance of survival for each interval (cummulative) (interval = censoring)
sv <- summary(survfit(Surv(xf$surv, xf$delta == 1) ~ 1))
sc <- summary(survfit(Surv(xf$surv, xf$delta == 0) ~ 1))   


# calculate average costs of patients deceased within each interval
a <- subset(xf, delta == 1) %>% 
  mutate(ints = cut(surv, breaks = c(sv$time))) %>% # Possibly change sv$time 
  group_by(ints) %>% 
  summarise(mean = mean(cost))


# calculate chance of death within each interval
dif <- c(diff(sv$surv, lag= 1), rep(NA,1))*-1


# Gathering the data in a new dataframe
d <- data.frame(sv$time, sv$surv, dif, a)
rm(dif)


# calculating Lin's T estimate of total costs 
LinT <- sum(d$dif*d$mean, na.rm=T) + (tail(d$sv.surv, n=1)*tail(d$mean, n=1))

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

for (i in 1:n) {
  t$sss[i] <- sum(t$delta[i:n]*t$cost[i:n]*t$sc.surv[i:n])
  }

for (i in 1:n) {
  t$ssss[i] <- sum(t$delta[i:n]*t$cost[i:n]^2*t$sc.surv[i:n])
}

t$GA <- t$sc.surv/(n - 1:n + t$delta) * t$ssss
t$GB <- t$sc.surv/(n - 1:n + t$delta) * t$sss

BT_var <- 1/n * (mean(t$delta*(t$cost-BT)^2/t$sc.surv) + mean((1-t$delta)/t$sc.surv^2 * (t$GA - t$GB^2)))
BT_sd <- sqrt(BT_var)
BT_uci <- BT + (1.96 * BT_sd)
BT_lci <- BT - (1.96 * BT_sd)

BT_full <- c(BT, BT_var, BT_sd, BT_uci, BT_lci)

# END VAR BT --------------------------------------------------------------



#################################################################
##                          section 6:                         ##
##                Zhao and Tian's method (2001)                ##
#################################################################

# Opposite Kaplain Meier - chance of censoring - for each period (cummulative)
sb <- summary(survfit(Surv(xf$surv, 
                           xf$delta == 0) ~ 1),
              times = (xf$surv))
#times = t_data$surv[t_data$delta %in% c(0,1)])


# new dataframe with values from the list and only unique so that we can merge them
sbt <- data.frame(sb$time, sb$surv)

# adjust for last proparbility = 0 (why we do this i'm not sure)
sbt$sb.surv[sbt$sb.surv == 0] <- min(sbt$sb.surv[sbt$sb.surv != 0])

# remove non unique to avoid errors when merging
sbt <- unique(sbt)


# Merge with the dataset by surv, as that tells which the chance of being censored in each death
e <- merge(x,sbt,by.x="surv", by.y="sb.time", all.x=T)


# Forward loop to calculate mean cost of patients with longer survival than patient i at patient i's surv
e$mcostlsurv <- NA

for(i in 1:nrow(e)){
  # temp set for longer survival than i
  t_data2 <- subset(x, start < e$surv[i])
  # Calculating the cost running costs of split periods
  t_data2$ncost <- ifelse(t_data2$stop> e$surv[i], (t_data2$cost/(t_data2$stop-t_data2$start))*(e$surv[i]-t_data2$start),0)
  # Don't double include split costs
  t_data2$cost <- ifelse(t_data2$stop > e$surv[i],0,t_data2$cost)
  # Now added to the other costs
  t_data2$cost <- t_data2$cost + t_data2$ncost
  
  # summarized  
  t_data_total_temp <- t_data2 %>% 
    group_by(id) %>% 
    summarize(cost = sum(cost, na.rm=T),
              surv= first(surv))
  
  # calculating the individual mean costs of everyone who lives longer 
  e$mcostlsurv[i] <- mean(t_data_total_temp$cost[t_data_total_temp$surv >= e$surv[i]])
  
}
rm(i)
# Summarizing the dataset
ee <- e %>% 
  group_by(id) %>% 
  summarize(cost = sum(cost, na.rm=T),
            delta = first(delta),
            sb.surv= first(sb.surv),
            surv= first(surv),
            mcostlsurv = mean(mcostlsurv, na.rm=T))


# The ZT estimator of mean costs
ZT <- mean((ee$delta * (ee$cost / ee$sb.surv)) + ((1-ee$delta) * ((ee$cost-ee$mcostlsurv) / ee$sb.surv)), na.rm=T)
ZT

ZT_full <- c(ZT, NA, NA, NA, NA)






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








