
context("Data simulated with ccostr compared between ccostr and SAS macro")
library(ccostr)

load(system.file("extdata/SASDataTest.Rdata", package = "ccostr"))


# Comparison values are hardcoded from runs in Stata with the Hcost package
# It is run with 8 files that represent differert simulation settings of 
# heavy or light censoring and uniform og exponential survival and censoring
# distribution, this gives 2^3 = 8 combinations:

# Code to generate SAS files

#uu.surv <- select(uu, id, delta, surv) %>% group_by(id) %>% summarize(delta = first(delta), surv = first(surv))
#uu.cost <- select(uu, id, start, stop, cost) %>% rename(cid = id)
#
#ue.surv <- select(ue, id, delta, surv) %>% group_by(id) %>% summarize(delta = first(delta), surv = first(surv))
#ue.cost <- select(ue, id, start, stop, cost) %>% rename(cid = id)
#
#eu.surv <- select(eu, id, delta, surv) %>% group_by(id) %>% summarize(delta = first(delta), surv = first(surv))
#eu.cost <- select(eu, id, start, stop, cost) %>% rename(cid = id)
#
#ee.surv <- select(ee, id, delta, surv) %>% group_by(id) %>% summarize(delta = first(delta), surv = first(surv))
#ee.cost <- select(ee, id, start, stop, cost) %>% rename(cid = id)
#
#
## write out text datafile and
## an SAS program to read it
#library(foreign)
#write.foreign(uu.surv, "inst/extdata/SAS/uusurv.txt", "inst/extdata/SAS/uusurv.sas",   package = "SAS")
#write.foreign(uu.cost, "inst/extdata/SAS/uucost.txt", "inst/extdata/SAS/uucost.sas",   package = "SAS")
#
#write.foreign(ue.surv, "inst/extdata/SAS/uesurv.txt", "inst/extdata/SAS/uesurv.sas",   package = "SAS")
#write.foreign(ue.cost, "inst/extdata/SAS/uecost.txt", "inst/extdata/SAS/uecost.sas",   package = "SAS")
#
#write.foreign(eu.surv, "inst/extdata/SAS/eusurv.txt", "inst/extdata/SAS/eusurv.sas",   package = "SAS")
#write.foreign(eu.cost, "inst/extdata/SAS/eucost.txt", "inst/extdata/SAS/eucost.sas",   package = "SAS")
#
#write.foreign(ee.surv, "inst/extdata/SAS/eesurv.txt", "inst/extdata/SAS/eesurv.sas",   package = "SAS")
#write.foreign(ee.cost, "inst/extdata/SAS/eecost.txt", "inst/extdata/SAS/eecost.sas",   package = "SAS")

# Simulated files similarity ----------------------------------------------

test_that("simCostData matches stored data", {
  set.seed(28082019)
  expect_equal(uu, simCostData(n = 30, dist = "unif", censor = "light", cdist = "unif")$censoredCostHistory)
  expect_equal(ue, simCostData(n = 30, dist = "unif", censor = "light", cdist = "exp" )$censoredCostHistory)
  expect_equal(eu, simCostData(n = 30, dist = "exp",  censor = "light", cdist = "unif")$censoredCostHistory)
  expect_equal(ee, simCostData(n = 30, dist = "exp",  censor = "light", cdist = "exp" )$censoredCostHistory)
})



# Unif survival with unif censoring ---------------------------------------

est.uu1 <- ccmean(uu, L = max(uu$surv), addInterPol = 1)
est.uu2 <- ccmean(uu, L = 6,            addInterPol = 1)

test_that("mean estimates sim uu1", {
  expect_equal(round(est.uu1$First[,3],2),     38317.85)
  expect_equal(round(est.uu1$First[,4],2),     37294.01)
})
test_that("variance estimates sim uu1", {
  expect_equal(round(est.uu1$Estimates$BT[3],2), 2036.03)
  expect_equal(round(est.uu1$Estimates$ZT[3],2), 2314.78)
})
test_that("mean estimates sim uu2", {
  expect_equal(round(est.uu2$First[,3],2),     32793.79)
  expect_equal(round(est.uu2$First[,4],2),     32394.49)
})
test_that("variance estimates sim uu2", {
  expect_equal(round(est.uu2$Estimates$BT[3],2), 1438.65)
  expect_equal(round(est.uu2$Estimates$ZT[3],2), 1464.40)
})


# Exp survival with exp censoring -----------------------------------------

est.ee1 <- ccmean(ee, L = max(ee$surv), addInterPol = 1)
est.ee2 <- ccmean(ee, L = 6,            addInterPol = 1)

test_that("mean estimates sim ee1", {
  expect_equal(round(est.ee1$First[,3],2),     44623.56)
  expect_equal(round(est.ee1$First[,4],2),     43612.05)
})
test_that("variance estimates sim ee1", {
  expect_equal(round(est.ee1$Estimates$BT[3],2), 3443.89)
  expect_equal(round(est.ee1$Estimates$ZT[3],2), 3386.95)
})
test_that("mean estimates sim ee2", {
  expect_equal(round(est.ee2$First[,3],2),     31661.38)
  expect_equal(round(est.ee2$First[,4],2),     31277.18)
})
test_that("variance estimates sim ee2", {
  expect_equal(round(est.ee2$Estimates$BT[3],2), 1801.40)
  expect_equal(round(est.ee2$Estimates$ZT[3],2), 1747.04)
})



# Exp survival with unif censoring ----------------------------------------

est.eu1 <- ccmean(eu, L = max(eu$surv), addInterPol = 1)
est.eu2 <- ccmean(eu, L = 6,            addInterPol = 1)

test_that("mean estimates sim eu1", {
  expect_equal(round(est.eu1$First[,3],2),     36438.81)
  expect_equal(round(est.eu1$First[,4],2),     35521.02)
})
test_that("variance estimates sim eu1", {
  expect_equal(round(est.eu1$Estimates$BT[3],2), 1895.46)
  expect_equal(round(est.eu1$Estimates$ZT[3],2), 1955.29)
})
test_that("mean estimates sim eu2", {
  expect_equal(round(est.eu2$First[,3],2),     32129.22)
  expect_equal(round(est.eu2$First[,4],2),     31492.89)
})
test_that("variance estimates sim eu2", {
  expect_equal(round(est.eu2$Estimates$BT[3],2), 1808.54)
  expect_equal(round(est.eu2$Estimates$ZT[3],2), 1734.09)
})


# Unif survival with exp censoring ----------------------------------------

est.ue1 <- ccmean(ue, L = max(ue$surv), addInterPol = 1)
est.ue2 <- ccmean(ue, L = 6,            addInterPol = 1)

test_that("mean estimates sim ue1", {
  expect_equal(round(est.ue1$First[,3],2),     39911.42)
  expect_equal(round(est.ue1$First[,4],2),     39264.93)
})
test_that("variance estimates sim ue1", {
  expect_equal(round(est.ue1$Estimates$BT[3],2), 1619.20)
  expect_equal(round(est.ue1$Estimates$ZT[3],2), 1748.23)
})
test_that("mean estimates sim ue2", {
  expect_equal(round(est.ue2$First[,3],2),     31539.04)
  expect_equal(round(est.ue2$First[,4],2),     31199.79)
})
test_that("variance estimates sim ue2", {
  expect_equal(round(est.ue2$Estimates$BT[3],2), 1520.39)
  expect_equal(round(est.ue2$Estimates$ZT[3],2), 1511.76)
})
