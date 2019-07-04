

set.seed(03072019)

ule <- simCostData(n = 1000, dist = "unif", censor = "light", cdist = "exp")$censoredCostHistory
uhe <- simCostData(n = 1000, dist = "unif", censor = "heavy", cdist = "exp")$censoredCostHistory
ele <- simCostData(n = 1000, dist = "exp",  censor = "light", cdist = "exp")$censoredCostHistory
ehe <- simCostData(n = 1000, dist = "exp",  censor = "heavy", cdist = "exp")$censoredCostHistory
ulu <- simCostData(n = 1000, dist = "unif", censor = "light", cdist = "unif")$censoredCostHistory
uhu <- simCostData(n = 1000, dist = "unif", censor = "heavy", cdist = "unif")$censoredCostHistory
elu <- simCostData(n = 1000, dist = "exp",  censor = "light", cdist = "unif")$censoredCostHistory
ehu <- simCostData(n = 1000, dist = "exp",  censor = "heavy", cdist = "unif")$censoredCostHistory



library(foreign)

write.dta(ule, file = "ule.dta")
write.dta(uhe, file = "uhe.dta")
write.dta(ele, file = "ele.dta")
write.dta(ehe, file = "ehe.dta")
write.dta(ulu, file = "ulu.dta")
write.dta(uhu, file = "uhu.dta")
write.dta(elu, file = "elu.dta")
write.dta(ehu, file = "ehu.dta")

ccmean(ule, addInterPol = 1)
ccmean(uhe, addInterPol = 1)
ccmean(ele, addInterPol = 1)
ccmean(ehe, addInterPol = 1)
ccmean(ulu, addInterPol = 1)
ccmean(uhu, addInterPol = 1)
ccmean(elu, addInterPol = 1)
ccmean(ehu, addInterPol = 1)

save(ule, uhe, ele, ehe, ulu, uhu, elu, ehu, file="StataDataTest.Rdata")


max(ule$surv)
max(uhe$surv)
max(ele$surv)
max(ehe$surv)
max(ulu$surv)
max(uhu$surv)
max(elu$surv)
max(ehu$surv)