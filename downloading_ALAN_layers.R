library(tictoc) # for measuring time

## downloading night time lights
dir.create("~/scratch/dmsp")
for (year in 1992:2013) {
  tic(year)
  url = paste0('https://zenodo.org/record/6644980/files/CCNL_DMSP_', year, '_V1.tif')
  destfile = paste0('~/scratch/dmsp/CCNL_DMSP_', year, '_V1.tif')
  download.file(url, destfile, method = "curl")
  toc()
}


