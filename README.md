# Artificial light at night in the Arctic

## Data

The consistent and corrected nighttime light (CCNL) dataset is based on DMSP and available as GeoTIFF format at 
https://zenodo.org/record/6644980

Global Human Settlement Layer (GHSL) Population grid for the years 1995, 2000, 2005, and 2010 is available as Mollweide projection with 1000 m resolution at 
https://ghsl.jrc.ec.europa.eu/download.php?ds=pop 

Database of Global Administrative Areas (GADM 4.1) is available at 
https://gadm.org/download_country.html

## Code

Required packages: terra, raster, rgdal tictoc, reshape

### Data preparation

**ALAN**. We downloaded CCNL rasters for each year from Zenodo repository, stacked and cropped them above 45°N via following scripts

[downloading_ALAN_layers.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/downloading_ALAN_layers.R)

[stacking_and_cropping_ALAN_layers.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/stacking_and_cropping_ALAN_layers.R)

**Human settlement**. We downladed Global Human Settlement Layer (GHSL) via the following script. We then reprojected it to the standard WGS 84 coordinate system using QGIS 3.28.0.

[downloading_human_set_data.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/downloading_human_set_data.R)

### Stats for ALAN area and development during 1992-2013 (Fig.1, Table 1, Supplementary Table 1)

We calculate total lit area for each region and subregion for each year. We then calculate ARIMA slope and p-value and the annual growth in ALAN extent.

[calculating_lit_area_per_year_and_growth.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_lit_area_per_year_and_growth.R)

We calculate total area, newly lit area and ALAN intensity-based annual growth rate in human activity for regions and subregions via the following script.

[calculating_areas_stats.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_areas_stats.R)

### Creating ALAN trend maps

We calculate and save ARIMA slope and p-value for each pixel of CCNL data across 1992-2013. The code is parallelized to 32 cores for computational efficiency and takes about 2h to run on 32 cores, 32GB RAM. 

[calculating_arima_slope_pval.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_arima_slope_pval.R)


