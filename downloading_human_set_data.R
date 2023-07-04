library(tictoc) # for measuring time

## download and unzip human settlement data
dir.create("~/scratch/human_stl/zip/", showWarnings = F, recursive = T)
for (year in c(1995, 2000, 2005, 2010))
{
  tic(year)
  url = paste0("https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2022A/GHS_POP_E",
               year, "_GLOBE_R2022A_54009_1000/V1-0/GHS_POP_E",
               year, "_GLOBE_R2022A_54009_1000_V1_0.zip")
  destfile = paste0('~/scratch/human_stl/zip/zip_hs_', year, '.zip')
  download.file(url, destfile, method = "curl")
  #unzip
  unzip(destfile,exdir="~/scratch/human_stl/")
  toc()
}

