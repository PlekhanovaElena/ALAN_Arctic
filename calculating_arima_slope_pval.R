## Running ARIMA model for the new harmonized DMSP data

## load libraries
library(raster) # for reading rasters and using parallel clusterR function
library(tictoc) # for measuring time

# Loading stack of 22 years of DMSP data cut to 45° latitude 
stack_ntl <- stack("~/data/ntl/ntl_results/aurora_correction/corrected_ntl_stack.tif")

print("Start calculations")

## Calculating arima slope

fun_slope <- function(vect, time = c(1:22)) { if (sum(is.na(vect)) >= 13){ NA } 
  else {if (all(vect == 0)) return(0) else
    ifworks = try(mod <- arima(vect, xreg=time, order = c(1, 0, 0)), silent = T)
  if (class(ifworks) == "try-error") {
    print(vect)
    ifworks2 = try(mod <- arima(vect, xreg=time, order = c(1, 0, 0), method="ML"))
    if (class(ifworks2) == "try-error") return(99)
  }
   return(mod$coef[3])}}


# takes approx. 2 hours on 32 cores, 32 GB RAM (16GB RAM may be enough)
tic("linear regression arima on 32 nodes")
beginCluster(n = 32)
arima_slopes = clusterR(stack_ntl, calc, 
                     args=list(fun=fun_slope)
                     )
endCluster()
toc()

writeRaster(arima_slopes,  "~/data/ntl/ntl_results/aurora_correction/arima_slopes.tif", overwrite=T)

## Calculating arima pvalue
fun_pval <- function(x, time = c(1:22)) { 
  if (((sum(is.na(x)) >= 13) | any(is.infinite(x)) | (all(x == 0)))){ 
    NA } else {
      ifworks = try(mod <- arima(x, xreg=time, order = c(1, 0, 0)), silent = T)
      if (class(ifworks) == "try-error") {
        ifworks2 = try(mod <- arima(x, xreg=time, order = c(1, 0, 0), method="ML"),
                       silent = T)
        if (class(ifworks2) == "try-error") return(99)
      }
      pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
      return(pvalues[3])
    }}

tic("linear regression pval on 32 nodes")
beginCluster(n = 32)
arima_pvals = clusterR(stack_ntl, calc, 
                     args=list(fun=fun_pval)
)
endCluster()
toc()

writeRaster(arima_pvals,  "~/data/ntl/ntl_results/aurora_correction/arima_pvals.tif", overwrite=T)


# saving significant slopes
slps = raster("~/data/ntl/ntl_results/aurora_correction/arima_slopes.tif")
pvals = raster("~/data/ntl/ntl_results/aurora_correction/arima_pvals.tif")
slps[pvals>0.05]=100 # non-significant slopes are set to 100
#plot(slps)
writeRaster(slps, "~/data/ntl/ntl_results/aurora_correction/arima_slopes_significant.tif", overwrite=T)
