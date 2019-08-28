
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
  expect_equal(round(est.uu1$First[,3],2),     40636.63)
  expect_equal(round(est.uu1$First[,4],2),     40273.73)
})
test_that("variance estimates sim uu1", {
  expect_equal(round(est.uu1$Estimates$BT[3],2), 339.53)
  expect_equal(round(est.uu1$Estimates$ZT[3],2), 347.72)
})
test_that("mean estimates sim uu2", {
  expect_equal(round(est.uu2$First[,3],2),     32352.96)
  expect_equal(round(est.uu2$First[,4],2),     32104.05)
})
test_that("variance estimates sim uu2", {
  expect_equal(round(est.uu2$Estimates$BT[3],2), 328.16)
  expect_equal(round(est.uu2$Estimates$ZT[3],2), 323.97)
})