#' Simulated data from the stata hcost package
#'
#' @docType data
#'
#' @usage data(hcost)
#'
#' @format A data frame with 9882 rows and 7 variables:
#' \describe{
#'   \item{id}{id seperating individuals}
#'   \item{start}{start of specified cost}
#'   \item{stop}{end of specified cost}
#'   \item{cost}{cost in given period}
#'   \item{trt}{treatment variable}
#'   \item{delta}{event variable, 0 = censored}
#'   \item{surv}{survival period}
#' }
#'
#' @keywords datasets
#'
#' @references 
#' \insertRef{Chen2015}{ccostr}
#'
#' @source \href{http://shuaichen.weebly.com/developed-package.html}{Blog}
#'
#' @examples
#' data(hcost)
#'
#' 
#' @importFrom Rdpack reprompt
"hcost"