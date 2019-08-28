
context("Data simulated with ccostr compared between ccostr and SAS macro")
library(ccostr)

load(system.file("extdata/SASDataTest.Rdata", package = "ccostr"))


# Comparison values are hardcoded from runs in Stata with the Hcost package
# It is run with 8 files that represent differert simulation settings of 
# heavy or light censoring and uniform og exponential survival and censoring
# distribution, this gives 2^3 = 8 combinations:


# Simulated files similarity ----------------------------------------------

test_that("simCostData matches stored data", {
  set.seed(28082019)
  expect_equal(uu, simCostData(n = 30, dist = "unif", censor = "light", cdist = "unif")$censoredCostHistory)
  expect_equal(ue, simCostData(n = 30, dist = "unif", censor = "light", cdist = "exp" )$censoredCostHistory)
  expect_equal(eu, simCostData(n = 30, dist = "exp",  censor = "light", cdist = "unif")$censoredCostHistory)
  expect_equal(ee, simCostData(n = 30, dist = "exp",  censor = "light", cdist = "exp" )$censoredCostHistory)
})



est.uu1 <- ccmean(uu, L = max(uu$surv), addInterPol = 1)
est.uu2 <- ccmean(uu, L = 6,            addInterPol = 1)

test_that("mean estimates sim uu1", {
  expect_equal(round(est.uu1$First[,3],2),     42066.47)
  expect_equal(round(est.uu1$First[,4],2),     40902.73)
})
#test_that("variance estimates sim uu1", {
#  expect_equal(round(est.uu1$Estimates$BT[3],2), 983.72)
#  expect_equal(round(est.uu1$Estimates$ZT[3],2), 1126.94)
#})
test_that("mean estimates sim uu2", {
  expect_equal(round(est.uu2$First[,3],2),     32788.89)
  expect_equal(round(est.uu2$First[,4],2),     32530.46)
})
#test_that("variance estimates sim uu2", {
#  expect_equal(round(est.uu2$Estimates$BT[3],2), 667.77)
#  expect_equal(round(est.uu2$Estimates$ZT[3],2), 672.36)
#})



est.ee1 <- ccmean(ee, L = max(ee$surv), addInterPol = 1)
est.ee2 <- ccmean(ee, L = 6,            addInterPol = 1)

test_that("mean estimates sim ee1", {
  expect_equal(round(est.ee1$First[,3],2),     53564.21)
  expect_equal(round(est.ee1$First[,4],2),     52200.17)
})
#test_that("variance estimates sim ee1", {
#  expect_equal(round(est.ee1$Estimates$BT[3],2), 1498.71)
#  expect_equal(round(est.ee1$Estimates$ZT[3],2), 1475.57)
#})
test_that("mean estimates sim ee2", {
  expect_equal(round(est.ee2$First[,3],2),     30143.84)
  expect_equal(round(est.ee2$First[,4],2),     29738.70)
})
#test_that("variance estimates sim ee2", {
#  expect_equal(round(est.ee2$Estimates$BT[3],2), 643.49)
#  expect_equal(round(est.ee2$Estimates$ZT[3],2), 628.31)
#})


