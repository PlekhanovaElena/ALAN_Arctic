# Artificial light at night in the Arctic

## Data

The consistent and corrected nighttime light (CCNL) dataset is based on DMSP and available as GeoTIFF format at 
https://zenodo.org/record/6644980

Global Human Settlement Layer (GHSL) Population grid for the years 1995, 2000, 2005, and 2010 is available as Mollweide projection with 1000 m resolution at 
https://ghsl.jrc.ec.europa.eu/download.php?ds=pop 

Database of Global Administrative Areas (GADM 4.1) is available at 
https://gadm.org/download_country.html

## Code

We calculate and save ARIMA slope and p-value for each pixel of CCNL data across 1992-2013. The code is parallelized to 32 cores for computational efficiency and takes about 2h to run on 32 cores, 32GB RAM. 

[calculating_arima_slope_pval.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_arima_slope_pval.R)


