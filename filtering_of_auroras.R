library(terra)
library(tictoc)


## Creating the layers of the areas lit only once and at least twice across years

only_once_lit <- function(timeseries) {
  if (sum(timeseries == 0) == 21) return(1) else return(0)
}

twice_lit <- function(timeseries) {
  if (sum(timeseries == 0) < 21) return(1) else return(0)
}

ntl = rast("~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif")

ol <- terra::app(ntl, fun=only_once_lit)
tl <- terra::app(ntl, fun=twice_lit)

writeRaster(ol, "~/data/ntl/ntl_results/aurora_correction/only_once_unlit.tif")
writeRaster(tl, "~/data/ntl/ntl_results/aurora_correction/twice_lit.tif")


## Preparing raster res with values that equal 2 for only lit pixels that are 
## more than 5km away from tl (at least twice lit area)

ol = rast("~/data/ntl/ntl_results/aurora_correction/only_once_lit.tif")
tl =  rast("~/data/ntl/ntl_results/aurora_correction/twice_lit.tif")

tic()
dl = gridDist(tl, target = 1, scale = 1000, filename = "~/data/ntl/ntl_results/aurora_correction/distance_to_twice_lit.tif") 
toc() # this takes around 40 min

dl[ol == 0] = NA # selecting only distances for only once lit pixels
res = dl
threshold = 5 # distance in km
res[dl < threshold] = 1
res[dl >= threshold] = 2
#plot(res, col = c("red", "blue"))

writeRaster(res, "~/data/ntl/ntl_results/aurora_correction/remote_from_lit_2.tif")

## Filtering the lit pixels that are more than 5km away from at least twice lit area

ntl[res == 2] = 0

writeRaster(ntl, "~/data/ntl/ntl_results/aurora_correction/corrected_ntl_stack.tif")

