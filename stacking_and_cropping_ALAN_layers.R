# Stacking the DMSP and cropping them above 45 North latitude (using the new dataset) 

## load libraries
library(terra) # for handling spatial data efficiently


## get the data
# get all the names of DMSP files
filenames = list.files("~/scratch/dmsp/", full.names = T)
# read the stack of all the TIF files
NTLs = rast(filenames)

## crop the images to the above 45 lattitude
e <- c(-179.9996 , 180.0004, 45 , 78)
cropNTLs = crop(NTLs, e) # takes 17GB of RAM and 2 min
rm(NTLs) # removing large stack to free-up RAM
#gc() # freeing unused memory

## save the cropped stack to a file - takes 10 min and more than 32GB RAM
writeRaster(cropNTLs, "~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif", overwrite=TRUE)

#plot(cropNTLs[[1]])
