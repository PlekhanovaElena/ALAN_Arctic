# Calculating the overlap of human settlement and lit areas
library(terra)
library(rgdal)
library(tictoc)
library(reshape)

## Reading the stack of ALAN data ---------------------------------------------

ntl_all = rast("~/data/ntl/ntl_results/aurora_correction/corrected_ntl_stack.tif")

## Reading all the shapefiles for regions and subregions ----------------------

layer_shp_of_country = list("Russia" = "NAME_1",
                            "Sweden" = "NAME_1",
                            "Norway" = "NAME_1",
                            "Finland" = "NAME_2",
                            "Canada" = "NAME_1",
                            "USA" = "NAME_1",
                            "Faroe" = "NAME_0",
                            "Greenland" = "NAME_0",
                            "Iceland" = "COUNTRY")
shapefile_of_country = list("Russia" = "gadm36_RUS_1.shp",
                            "Sweden" = "gadm36_SWE_1.shp",
                            "Norway" = "gadm36_NOR_1.shp",
                            "Finland" = "gadm40_FIN_2.shp",
                            "Canada" = "gadm36_CAN_1.shp",
                            "USA" = "gadm36_USA_1.shp",
                            "Faroe" = "gadm36_FRO_0.shp",
                            "Greenland" = "gadm36_GRL_0.shp",
                            "Iceland" = "gadm40_ISL_0.shp")
regions_of_country = list(
  "Russia" = c("Arkhangel'sk", "Chukot", "Kamchatka", "Karelia", 
               "Khanty-Mansiy","Komi", "Krasnoyarsk", "Maga Buryatdan", 
               "Murmansk", "Nenets","Yamal-Nenets", "Sakha"), 
  "Sweden" = c("Västerbotten", "Norrbotten"), # need to copy-paste the name
  "Norway" = c("Troms", "Nordland", "Finnmark"),
  "Finland" = c("Northern Ostrobothnia", "Lapland", "Kainuu"),
  "Canada" = c("Yukon", "Northwest Territories", "Nunavut"),
  "USA" = c("Alaska"),
  "Faroe" = "Faroe Islands",
  "Greenland" = "Greenland",
  "Iceland" = "Iceland"
)


## Larger regions:
## Russia: all regs combined
country = "Russia"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_names = regions_of_country[[country]]
reg_shp_rus = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                            reg_names, 2]
# ----- North America
## North America - Canda: all regs + USA: Alasks

country = "Canada"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_names = regions_of_country[[country]]
reg_shp1 = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                         reg_names, 2]
country = "USA"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_names = regions_of_country[[country]]
reg_shp2 = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                         reg_names, 2]
reg_shp_na = rbind(reg_shp1, reg_shp2)

# ----- European Arctic
## Europe Faroe + Iceland + Finland: all regs + Norway: all regs + Sweden
country = "Faroe"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_shp1 = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                         regions_of_country[[country]], 2]
country = "Iceland"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_shp2 = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                         regions_of_country[[country]], 2]
country = "Finland"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_shp3 = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                         regions_of_country[[country]], 2]
country = "Norway"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_shp4 = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                         regions_of_country[[country]], 2]
country = "Sweden"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_shp5 = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                         regions_of_country[[country]], 2]

reg_shp_eu = rbind(vect(reg_shp1), vect(reg_shp2), vect(reg_shp3), 
                   vect(reg_shp4), vect(reg_shp5))

country = "Greenland"
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country[country]))
reg_shp_gr = country_shp[country_shp[[layer_shp_of_country[[country]]]] %in% 
                           regions_of_country[[country]], 2]

reg_shp_un_pa = rbind(vect(reg_shp_rus), reg_shp_eu, vect(reg_shp_na), vect(reg_shp_gr))


clip_to_shape = function(orig_raster, reg_shp, vectr = F) {
  
  cr = crop(orig_raster, ext(reg_shp))
  if (vectr) cl = mask(cr, reg_shp) else cl = mask(cr, vect(reg_shp))
  return(cl)
  
}

area_calc = function(rastr) {
  ar = cellSize(rastr, unit = "km")
  return(sum(values(ar), na.rm = T))
}

# Lit area

lit_area_calc = function(rastr) {
  cll = rastr
  cll[cll == 0] = NA
  arl = cellSize(cll, unit = "km")
  return(sum(values(arl), na.rm = T))
}

# Lit and pop area

lit_and_pop_area_calc = function(rastr, hp_rastr) {
  cll = rastr
  cll[cll == 0] = NA
  cll[hp_rastr == 0] = NA
  arl = cellSize(cll, unit = "km")
  return(sum(values(arl), na.rm = T))
}


## Calculating proportion of inhabited lit area for the larger region (Table 1) 

# EU excl. Greenland

print("EU excl. Greenland")
regn_shp = reg_shp_eu

eu_hum_lit = sapply(c(1995, 2000, 2005, 2010), function(year) {
  ntl = ntl_all[paste0("CCNL_DMSP_", year, "_V1")]
  
  hp = rast(paste0("~/data/ntl/human_settlement/ghsl_",year,".tif"))
  
  cl = clip_to_shape(ntl, regn_shp, vectr = T)
  clhp = clip_to_shape(hp, regn_shp, vectr = T)
  total_area = area_calc(cl)
  cat("total_area", round(total_area), "\n")
  lit_area = lit_area_calc(cl)
  lit_and_pop_area = lit_and_pop_area_calc(cl, clhp)
  lit_and_pop_area/lit_area
  return(round(100*lit_and_pop_area/lit_area, 2))
})

eu_hum_lit



# Russia

print("Russia")
regn_shp = reg_shp_rus

rus_hum_lit = sapply(c(1995, 2000, 2005, 2010), function(year) {
  tic(year)
  ntl = ntl_all[paste0("CCNL_DMSP_", year, "_V1")]
  hp = rast(paste0("~/data/ntl/human_settlement/ghsl_",year,".tif"))
  cl = clip_to_shape(ntl, regn_shp)
  clhp = clip_to_shape(hp, regn_shp)
  lit_area = lit_area_calc(cl)
  lit_and_pop_area = lit_and_pop_area_calc(cl, clhp)
  lit_and_pop_area/lit_area
  toc()
  return(round(100*lit_and_pop_area/lit_area, 2))
})


# North America

print("North America")
regn_shp = reg_shp_na

na_hum_lit = sapply(c(1995, 2000, 2005, 2010), function(year) {
  tic(year)
  ntl = ntl_all[paste0("CCNL_DMSP_", year, "_V1")]
  hp = rast(paste0("~/data/ntl/human_settlement/ghsl_",year,".tif"))
  cl = clip_to_shape(ntl, regn_shp)
  clhp = clip_to_shape(hp, regn_shp)
  lit_area = lit_area_calc(cl)
  lit_and_pop_area = lit_and_pop_area_calc(cl, clhp)
  lit_and_pop_area/lit_area
  toc()
  return(round(100*lit_and_pop_area/lit_area, 2))
})

# pan-Arctic

print("pan-Arctic")
regn_shp = reg_shp_un_pa

arctic_hum_lit = sapply(c(1995, 2000, 2005, 2010), function(year) {
  ntl = ntl_all[paste0("CCNL_DMSP_", year, "_V1")]
  
  hp = rast(paste0("~/data/ntl/human_settlement/ghsl_",year,".tif"))
  
  cl = clip_to_shape(ntl, regn_shp, vectr = T)
  clhp = clip_to_shape(hp, regn_shp, vectr = T)
  total_area = area_calc(cl)
  cat("total_area", round(total_area), "\n")
  lit_area = lit_area_calc(cl)
  lit_and_pop_area = lit_and_pop_area_calc(cl, clhp)
  lit_and_pop_area/lit_area
  return(round(100*lit_and_pop_area/lit_area, 2))
})


# Gathering the data for larger regions together in one table

dat = data.frame(rbind(arctic_hum_lit, rus_hum_lit, 
                       na_hum_lit, eu_hum_lit))
colnames(dat) = c("1995", "2000", 
                  "2005", "2010")
dat$region = c("pan-Arctic","Russia", "North America", "EU excl. Greenland")
df = dat
df = df[,c(5,1:4)]
df$mean = apply(df[,2:5], 1, function(x) round(mean(x), 2))
df$range = apply(df[,2:5], 1, function(x) paste(
  round(min(x), 2), "-", round(max(x), 2)))
df$mean_with_range = paste0(df$mean, " (", df$range, ")")

write.csv(df, "~/data/ntl/ntl_results/aurora_correction/table_of_lit_by_humans.csv", 
          row.names = F)


## Calculating for the subregions (Supplementary Table 1) --------------------

arctic_hum_lit_reg = sapply(c(1995, 2000, 2005, 2010), function(year) {
  ntl = ntl_all[paste0("CCNL_DMSP_", year, "_V1")]
  
  hp = rast(paste0("~/data/ntl/human_settlement/ghsl_",year,".tif"))
  
  cnt_uls = unlist(sapply(names(regions_of_country), function(country) {
    tic(country)
    country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                                 shapefile_of_country[country]))
    reg_names = regions_of_country[[country]]
    
    uls = sapply(reg_names, function(reg_name) {
      print(reg_name)
      regn_shp = country_shp[country_shp[[layer_shp_of_country[[country]]]] == 
                               reg_name, 2]
      cl = clip_to_shape(ntl, regn_shp)
      clhp = clip_to_shape(hp, regn_shp)
      total_area = area_calc(cl)
      cat("total_area", round(total_area), "\n")
      lit_area = lit_area_calc(cl)
      lit_and_pop_area = lit_and_pop_area_calc(cl, clhp)
      lit_and_pop_area/lit_area
      return(round(100*lit_and_pop_area/lit_area, 2))
    })}))
  return(cnt_uls)
    
  })


# Gathering the data for subregions together in one table

df =  data.frame(arctic_hum_lit_reg)
colnames(df) = c("1995", "2000", "2005", "2010")
df$country = rownames(df)
#df = read.csv("~/data/ntl/ntl_results/table_of_lit_by_humans.csv")
#df = df[,-1]
df = df[,c(5,1:4)]
df$mean = apply(df[,2:5], 1, function(x) round(mean(x), 2))
df$range = apply(df[,2:5], 1, function(x) paste(
  round(min(x), 2), "-", round(max(x), 2)))
df$mean_with_range = paste0(df$mean, " (", df$range, ")")

write.csv(df, "~/data/ntl/ntl_results/aurora_correction/table_of_lit_by_humans_regions.csv", 
          row.names = F)


