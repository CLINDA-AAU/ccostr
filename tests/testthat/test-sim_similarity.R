
context("Data simulated with ccostr copmared between ccostr and hcost")
library(ccostr)

load(system.file("extdata/StataDataTest.Rdata", package="ccostr"))


# Comparison values are hardcoded from runs in Stata with the Hcost package
# It is run with 8 files that represent differert simulation settings of 
# heavy or light censoring and uniform og exponential survival and censoring
# distribution, this gives 2^3 = 8 combinations:


# Simulated files similarity ----------------------------------------------
test_that("simCostData matches stored data", {
  set.seed(03072019)
  expect_equal(ule, simCostData(n = 1000, dist = "unif", censor = "light", cdist = "exp")$censoredCostHistory)
  expect_equal(uhe, simCostData(n = 1000, dist = "unif", censor = "heavy", cdist = "exp")$censoredCostHistory)
  expect_equal(ele, simCostData(n = 1000, dist = "exp",  censor = "light", cdist = "exp")$censoredCostHistory)
  expect_equal(ehe, simCostData(n = 1000, dist = "exp",  censor = "heavy", cdist = "exp")$censoredCostHistory)
  expect_equal(ulu, simCostData(n = 1000, dist = "unif", censor = "light", cdist = "unif")$censoredCostHistory)
  expect_equal(uhu, simCostData(n = 1000, dist = "unif", censor = "heavy", cdist = "unif")$censoredCostHistory)
  expect_equal(elu, simCostData(n = 1000, dist = "exp",  censor = "light", cdist = "unif")$censoredCostHistory)
  expect_equal(ehu, simCostData(n = 1000, dist = "exp",  censor = "heavy", cdist = "unif")$censoredCostHistory)
})

# ULE ---------------------------------------------------------------------
est.ule1 <- ccmean(ule, L = 9.969014, addInterPol = 1)
est.ule2 <- ccmean(ule, L = 6,        addInterPol = 1)

test_that("mean estimates sim ule1", {
  expect_equal(round(est.ule1$First[,3],2),     40636.63)
  expect_equal(round(est.ule1$First[,4],2),     40273.73)
})
test_that("variance estimates sim ule1", {
  expect_equal(round(est.ule1$Estimates$BT[3],2), 339.53)
  expect_equal(round(est.ule1$Estimates$ZT[3],2), 347.72)
})
test_that("mean estimates sim ule2", {
  expect_equal(round(est.ule2$First[,3],2),     32352.96)
  expect_equal(round(est.ule2$First[,4],2),     32104.05)
})
test_that("variance estimates sim ule2", {
  expect_equal(round(est.ule2$Estimates$BT[3],2), 328.16)
  expect_equal(round(est.ule2$Estimates$ZT[3],2), 323.97)
})



# UHE ---------------------------------------------------------------------
est.uhe1 <- ccmean(uhe, L = 9.994942, addInterPol = 1)
est.uhe2 <- ccmean(uhe, L = 6,        addInterPol = 1)

test_that("mean estimates sim uhe1", {
  expect_equal(round(est.uhe1$First[,3],2),     40324.72)
  expect_equal(round(est.uhe1$First[,4],2),     39677.79)
})
test_that("variance estimates sim uhe1", {
  expect_equal(round(est.uhe1$Estimates$BT[3],2), 372.16)
  expect_equal(round(est.uhe1$Estimates$ZT[3],2), 385.25)
})
test_that("mean estimates sim uhe2", {
  expect_equal(round(est.uhe2$First[,3],2),     32321.45)
  expect_equal(round(est.uhe2$First[,4],2),     31908.71)
})
test_that("variance estimates sim uhe2", {
  expect_equal(round(est.uhe2$Estimates$BT[3],2), 386.86)
  expect_equal(round(est.uhe2$Estimates$ZT[3],2), 374.06)
})


# ELE ---------------------------------------------------------------------
est.ele1 <- ccmean(ele, L = 24.53706, addInterPol = 1)
est.ele2 <- ccmean(ele, L = 6,        addInterPol = 1)

test_that("mean estimates sim ele1", {
  expect_equal(round(est.ele1$First[,3],2),     42634.47)
  expect_equal(round(est.ele1$First[,4],2),     41804.40)
})
test_that("variance estimates sim ele1", {
  expect_equal(round(est.ele1$Estimates$BT[3],2), 539.11)
  expect_equal(round(est.ele1$Estimates$ZT[3],2), 562.56)
})
test_that("mean estimates sim ele2", {
  expect_equal(round(est.ele2$First[,3],2),     31701.84)
  expect_equal(round(est.ele2$First[,4],2),     31328.33)
})
test_that("variance estimates sim ele2", {
  expect_equal(round(est.ele2$Estimates$BT[3],2), 322.32)
  expect_equal(round(est.ele2$Estimates$ZT[3],2), 317.63)
})

# EHE ---------------------------------------------------------------------
est.ehe1 <- ccmean(ehe, L = 31.93078, addInterPol = 1)
est.ehe2 <- ccmean(ehe, L = 6,        addInterPol = 1)

test_that("mean estimates sim ehe1", {
  expect_equal(round(est.ehe1$First[,3],2),     43080.53)
  expect_equal(round(est.ehe1$First[,4],2),     42108.11)
})
test_that("variance estimates sim ehe1", {
  expect_equal(round(est.ehe1$Estimates$BT[3],2), 909.52)
  expect_equal(round(est.ehe1$Estimates$ZT[3],2), 933.75)
})
test_that("mean estimates sim ehe2", {
  expect_equal(round(est.ehe2$First[,3],2),     31349.38)
  expect_equal(round(est.ehe2$First[,4],2),     30948.75)
})
test_that("variance estimates sim ehe2", {
  expect_equal(round(est.ehe2$Estimates$BT[3],2), 346.65)
  expect_equal(round(est.ehe2$Estimates$ZT[3],2), 336.83)
})


# ULU ---------------------------------------------------------------------
est.ulu1 <- ccmean(ulu, L = 9.964636, addInterPol = 1)
est.ulu2 <- ccmean(ulu, L = 6,        addInterPol = 1)

test_that("mean estimates sim ulu1", {
  expect_equal(round(est.ulu1$First[,3],2),     40095.93)
  expect_equal(round(est.ulu1$First[,4],2),     39659.38)
})
test_that("variance estimates sim ulu1", {
  expect_equal(round(est.ulu1$Estimates$BT[3],2), 313.90)
  expect_equal(round(est.ulu1$Estimates$ZT[3],2), 325.33)
})
test_that("mean estimates sim ulu2", {
  expect_equal(round(est.ulu2$First[,3],2),     32254.42)
  expect_equal(round(est.ulu2$First[,4],2),     32063.21)
})
test_that("variance estimates sim ulu2", {
  expect_equal(round(est.ulu2$Estimates$BT[3],2), 337.56)
  expect_equal(round(est.ulu2$Estimates$ZT[3],2), 330.21)
})

# UHU ---------------------------------------------------------------------
est.uhu1 <- ccmean(uhu, L = 9.992897, addInterPol = 1)
est.uhu2 <- ccmean(uhu, L = 6,        addInterPol = 1)

test_that("mean estimates sim uhu1", {
  expect_equal(round(est.uhu1$First[,3],2),     40002.08)
  expect_equal(round(est.uhu1$First[,4],2),     38586.12)
})
test_that("variance estimates sim uhu1", {
  expect_equal(round(est.uhu1$Estimates$BT[3],2), 352.49)
  expect_equal(round(est.uhu1$Estimates$ZT[3],2), 374.04)
})
test_that("mean estimates sim uhu2", {
  expect_equal(round(est.uhu2$First[,3],2),     32214.18)
  expect_equal(round(est.uhu2$First[,4],2),     31550.51)
})
test_that("variance estimates sim uhu2", {
  expect_equal(round(est.uhu2$Estimates$BT[3],2), 367.12)
  expect_equal(round(est.uhu2$Estimates$ZT[3],2), 351.24)
})

# ELU ---------------------------------------------------------------------
est.elu1 <- ccmean(elu, L = 19.9812,  addInterPol = 1)
est.elu2 <- ccmean(elu, L = 6,        addInterPol = 1)

test_that("mean estimates sim elu1", {
  expect_equal(round(est.elu1$First[,3],2),     39205.09)
  expect_equal(round(est.elu1$First[,4],2),     39160.99)
})
test_that("variance estimates sim elu1", {
  expect_equal(round(est.elu1$Estimates$BT[3],2), 482.39)
  expect_equal(round(est.elu1$Estimates$ZT[3],2), 550.58)
})
test_that("mean estimates sim elu2", {
  expect_equal(round(est.elu2$First[,3],2),     30805.29)
  expect_equal(round(est.elu2$First[,4],2),     30582.67)
})
test_that("variance estimates sim elu2", {
  expect_equal(round(est.elu2$Estimates$BT[3],2), 314.30)
  expect_equal(round(est.elu2$Estimates$ZT[3],2), 308.58)
})

# EHU ---------------------------------------------------------------------
est.ehu1 <- ccmean(ehu, L = 12.48327, addInterPol = 1)
est.ehu2 <- ccmean(ehu, L = 6,        addInterPol = 1)

test_that("mean estimates sim ehu1", {
  expect_equal(round(est.ehu1$First[,3],2),     38797.84)
  expect_equal(round(est.ehu1$First[,4],2),     36847.97)
})
test_that("variance estimates sim ehu1", {
  expect_equal(round(est.ehu1$Estimates$BT[3],2), 360.05)
  expect_equal(round(est.ehu1$Estimates$ZT[3],2), 771.78)
})
test_that("mean estimates sim ehu2", {
  expect_equal(round(est.ehu2$First[,3],2),     31458.79)
  expect_equal(round(est.ehu2$First[,4],2),     31120.00)
})
test_that("variance estimates sim ehu2", {
  expect_equal(round(est.ehu2$Estimates$BT[3],2), 354.33)
  expect_equal(round(est.ehu2$Estimates$ZT[3],2), 342.57)
})
