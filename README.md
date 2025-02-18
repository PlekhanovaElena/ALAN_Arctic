# Artificial light at night in the Arctic

This repository contains the code for the [article](https://doi.org/10.1073/pnas.2322269121) 

**Artificial light at night reveals hotspots and rapid development of industrial activity in the Arctic**, _PNAS_ (2024) by Cengiz Akandil, Elena Plekhanova, Nils Rietze, Jacqueline Oehri, Miguel O. Roman, Zhuosen Wang, Volker C Radeloff, and Gabriela Schaepman-Strub.

The data for the article can be found here:

Akandil, C. et all (2024). Arctic ALAN Intensity Change Maps (1992-2013) [Data set]. Zenodo. [https://zenodo.org/records/14755082](https://zenodo.org/records/14755082)

Check out an interactive map of Arctic ALAN trends [here](https://uzh.maps.arcgis.com/apps/instant/basic/index.html?appid=4af8de4e880443f18c5d1a550684bf97)
![image](https://github.com/user-attachments/assets/a4fd883c-9662-4a01-a415-6f13049bb92b)


## Data

The consistent and corrected nighttime light (CCNL) dataset is based on DMSP and available as GeoTIFF format at 
https://zenodo.org/record/6644980

Global Human Settlement Layer (GHSL) Population grid for the years 1995, 2000, 2005, and 2010 is available as Mollweide projection with 1000 m resolution at 
https://ghsl.jrc.ec.europa.eu/download.php?ds=pop 

Database of Global Administrative Areas (GADM 4.1) is available at 
https://gadm.org/download_country.html

---

## Code

Required packages: terra, raster, rgdal, tictoc, reshape, ggplot2

### Data preparation

**ALAN**. We downloaded CCNL rasters for each year from Zenodo repository, stacked and cropped them above 45°N and filtered out the auroras via following scripts

[downloading_ALAN_layers.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/downloading_ALAN_layers.R)

[stacking_and_cropping_ALAN_layers.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/stacking_and_cropping_ALAN_layers.R)

[filtering_of_auroras.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/filtering_of_auroras.R)


**Human settlement**. We downladed Global Human Settlement Layer (GHSL) via the following script. We then reprojected it to the standard WGS 84 coordinate system using QGIS 3.28.0.

[downloading_human_set_data.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/downloading_human_set_data.R)

### Stats for ALAN area and development during 1992-2013 (Figure 1, Table 1, Suppl. Table 2)

We calculated total lit area for each region and subregion for each year. We then calculated ARIMA slope and p-value and the annual growth in ALAN extent.

[calculating_lit_area_per_year_and_growth.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_lit_area_per_year_and_growth.R)

We plotted Figure 1 with [plotting_Fig1.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/plotting_Fig1.R)

We calculated total area, newly lit area and ALAN intensity-based annual growth rate in human activity for regions and subregions. Additionally, we calculate the percent of significantly increasing/decreasing area to total area based on the ALAN intensity trend map (see the next section).

[calculating_areas_stats.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_areas_stats.R)

We calculated proportion of lit areas containing human settlement to the total lit area for each region and subregion.

[calculating_proportion_of_inhabited_lit_areas.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_proportion_of_inhabited_lit_areas.R)

We then created Table 1 and Supplementary table 2 with [creating_tables.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/creating_tables.R)



### Creating ALAN trend maps (Figure 2,3)

We calculated and saved ARIMA slope and p-value for each pixel of CCNL data across 1992-2013. The code is parallelized to 32 cores for computational efficiency and takes about 5h to run on 32 cores, 32GB RAM. 

[calculating_arima_slope_pval.R](https://github.com/PlekhanovaElena/ALAN_Arctic/blob/main/calculating_arima_slope_pval.R)

---

In case you encounter any problems, feel free to open GitHub issue.

### Citation

C. Akandil, E. Plekhanova, N. Rietze, J. Oehri, M.O. Román, Z. Wang, V.C. Radeloff, G. Schaepman-Strub, Artificial light at night reveals hotspots and rapid development of industrial activity in the Arctic, Proc. Natl. Acad. Sci. U.S.A.
121 (44) e2322269121, 
https://doi.org/10.1073/pnas.2322269121 (2024).
