
context("Data from hcost copmared between ccostr and hcost")
library(ccostr)

# Comparison values are hardcoded from runs in Stata with the Hcost package
# using their build-in dataset called example

# Example dataset L = 1461 ------------------------------------------------
est1 <- ccmean(hcost, L = 1461, addInterPol = 1)

test_that("mean estimates hcost", {
  expect_equal(round(est1$First[,3],2),      86175.16)
  expect_equal(round(est1$First[,4],2),      80134.84)
})
test_that("variance estimates hcost", {
  expect_equal(round(est1$Estimates$BT[3],2), 7182.89)
  expect_equal(round(est1$Estimates$ZT[3],2), 4870.97)
})


# Example dataset L = 2000 ------------------------------------------------
est2 <- ccmean(hcost, L = 2000, addInterPol = 1)

test_that("mean estimates hcost", {
  expect_equal(round(est2$First[,3],2),       83953.99)
  expect_equal(round(est2$First[,4],2),       92439.34)
})
test_that("variance estimates hcost", {
  expect_equal(round(est2$Estimates$BT[3],2), 15734.94)
  expect_equal(round(est2$Estimates$ZT[3],2), 16073.06)
})


# Example dataset L = 2082 ------------------------------------------------
est3 <- ccmean(hcost, L = 2082, addInterPol = 1)

test_that("mean estimates hcost", {
  expect_equal(round(est3$First[,3],2),       83953.99)
  expect_equal(round(est3$First[,4],2),       92439.34)
})
test_that("variance estimates hcost", {
  expect_equal(round(est3$Estimates$BT[3],2), 15734.94)
  expect_equal(round(est3$Estimates$ZT[3],2), 16073.06)
})

# Example dataset L = 1000 ------------------------------------------------
est4 <- ccmean(hcost, L = 1000, addInterPol = 1)

test_that("mean estimates hcost", {
  expect_equal(round(est4$First[,3],2),      68236.23)
  expect_equal(round(est4$First[,4],2),      66683.45)
})
test_that("variance estimates hcost", {
  expect_equal(round(est4$Estimates$BT[3],2), 4410.38)
  expect_equal(round(est4$Estimates$ZT[3],2), 3728.87)
})










