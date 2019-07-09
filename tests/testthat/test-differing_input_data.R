
# data - history
df_1 <- data.frame(id    = c("A", "B" ,"C"),
                   cost  = c(2544,4245,590),
                   delta = c(0,0,1),
                   surv  = c(343,903,445))

test_that("Base est works", {
  expect_true(is.character(ccmean(df_1)$Text))
})

test_that("Base + history message works", {
  expect_message(ccmean(df_1))
})



# data + history
df_2 <- data.frame(id    = c("A", "A", "A", "B" ,"C", "C", "D"),
                   start = c(1, 30, 88, 18, 1, 67, 43),
                   stop  = c(1, 82, 88, 198, 5, 88, 44),
                   cost  = c(550, 1949, 45, 4245, 23, 567, 300),
                   delta = c(0, 0, 0, 0, 1, 1, 1),
                   surv  = c(343, 343, 343, 903, 445, 445, 652),
                   test  = c(0, 0, 0, 0, 1, 1, 1))

test_that("Base + history est works", {
  expect_true(is.character(ccmean(df_2)$Text))
})



# Wrong names
df_3 <- data.frame(dfi   = c("A", "A", "A", "B" ,"C", "C", "D"),
                   start = c(1, 30, 88, 18, 1, 67, 43),
                   stop  = c(1, 82, 88, 198, 5, 88, 44),
                   cost  = c(550, 1949, 45, 4245, 23, 567, 300),
                   dta   = c(0, 0, 0, 0, 1, 1, 1),
                   surv  = c(343, 343, 343, 903, 445, 445, 652),
                   test  = c(0, 0, 0, 0, 1, 1, 1))

test_that("Bad names should produce error", {
  expect_error(ccmean(df_3))
})



# No history but dublicate id's
df_4 <- data.frame(id    = c("A", "B" ,"C", "A"),
                   cost  = c(2544,4245,590, 23),
                   delta = c(0,0,1,0),
                   surv  = c(343,903,445,343))

test_that("No history and dublicate id's should produce error", {
  expect_error(ccmean(df_4))
})









