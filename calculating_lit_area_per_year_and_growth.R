library(terra)
library(rgdal)
library(tictoc)
library(reshape)

## Reading the stack of ALAN data ---------------------------------------------

ntl = rast("~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif")

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


## Calculating lit area for the larger region (Table 1) -----------------------

print("EU excl. Greenland")
vectr = T
regn_shp = reg_shp_eu
cr = crop(ntl, ext(regn_shp))
if (vectr) cl = mask(cr, regn_shp) else cl = mask(cr, vect(regn_shp))
cl[cl == 0] = NA
arl = cellSize(cl, unit = "km")
lit_areas_years = sapply(1:22, function(i) sum(values(arl[[i]]), na.rm = T))
lit_areas_years[lit_areas_years == 0] = NA
mod = arima(lit_areas_years, xreg=1:22, order = c(1, 0, 0))
slp = round(mod$coef[3])
cat("ARIMA slope:", slp, "km2\n")
arpred = predict(mod, newxreg=1:22)
pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
pvalue = pvalues[3]
cat("ARIMA p-value:", pvalue)
all_numbers_eu = c(lit_areas_years, slp, pvalue)


print("North America")
vectr = F
regn_shp = reg_shp_na

lit_areas_years = sapply(1:22, function(i) {
  tic(i)
  cr = crop(ntl[[i]], ext(regn_shp))
  if (vectr) cl = mask(cr, regn_shp) else cl = mask(cr, vect(regn_shp))
  cl[cl == 0] = NA
  arl = cellSize(cl, unit = "km")
  toc()
  return(sum(values(arl), na.rm = T))
})

lit_areas_years[lit_areas_years == 0] = NA
mod = arima(lit_areas_years, xreg=1:22, order = c(1, 0, 0))

slp = round(mod$coef[3])
cat("ARIMA slope:", slp, "km2\n")
arpred = predict(mod, newxreg=1:22)
pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
pvalue = pvalues[3]
cat("ARIMA p-value:", pvalue)
all_numbers_na = c(lit_areas_years, slp, pvalue)


print("Russia")
vectr = F
regn_shp = reg_shp_rus

lit_areas_years = sapply(1:22, function(i) {
  tic(i)
  cr = crop(ntl[[i]], ext(regn_shp))
  if (vectr) cl = mask(cr, regn_shp) else cl = mask(cr, vect(regn_shp))
  cl[cl == 0] = NA
  arl = cellSize(cl, unit = "km")
  toc()
  return(sum(values(arl), na.rm = T))
})

lit_areas_years[lit_areas_years == 0] = NA
mod = arima(lit_areas_years, xreg=1:22, order = c(1, 0, 0))
slp = round(mod$coef[3])
cat("ARIMA slope:", slp, "km2\n")
arpred = predict(mod, newxreg=1:22)
pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
pvalue = pvalues[3]
cat("ARIMA p-value:", pvalue)
all_numbers_rus = c(lit_areas_years, slp, pvalue)


print("pan-Arctic")
regn_shp = reg_shp_un_pa
vectr = T

lit_areas_years = sapply(1:22, function(i) {
  tic(i)
  cr = crop(ntl[[i]], ext(regn_shp))
  if (vectr) cl = mask(cr, regn_shp) else cl = mask(cr, vect(regn_shp))
  cl[cl == 0] = NA
  arl = cellSize(cl, unit = "km")
  toc()
  return(sum(values(arl), na.rm = T))
})

lit_areas_years[lit_areas_years == 0] = NA
mod = arima(lit_areas_years, xreg=1:22, order = c(1, 0, 0))
slp = round(mod$coef[3])
cat("ARIMA slope:", slp, "km2\n")
arpred = predict(mod, newxreg=1:22)
pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
pvalue = pvalues[3]
cat("ARIMA p-value:", pvalue)
all_numbers_pa = c(lit_areas_years, slp, pvalue)



# Gathering all data in one data table

df = data.frame(rbind(all_numbers_pa, all_numbers_rus, 
                       all_numbers_na, all_numbers_eu))

colnames(df) = c(paste0("Lit_km_", c(1992:2013)), "arima_slope", "p-value")
df$region = c("pan-Arctic","Russia", "North America", "EU excl. Greenland")

# calculating annual growth extent
df$annual_growth_ext = round(100*df$arima_slope/df$Lit_km_1992,2) # base year 1992
df$annual_growth_ext[4] = round(100*df$arima_slope[4]/df$Lit_km_1993,2) # base year 1993
write.csv(df, "~/data/ntl/ntl_results/table_1_of_areas_per_year.csv", row.names = F)





## Calculating lit area for the subregions (Supplementary Table 1) ------------


# First 5 countries
vectr = F
cnt_uls = sapply(names(regions_of_country)[1:5], function(country) {
  tic(country)
  country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                               shapefile_of_country[country]))
  cr = crop(ntl, ext(country_shp))
  reg_names = regions_of_country[[country]]
  uls = sapply(reg_names, function(reg_name) {
    regn_shp = country_shp[country_shp[[layer_shp_of_country[[country]]]] == 
                             reg_name, 2]
    tic(reg_name)
    cr = crop(cr, ext(regn_shp))
    if (vectr) cl = mask(cr, regn_shp) else cl = mask(cr, vect(regn_shp))
    cl[cl == 0] = NA
    
    arl = cellSize(cl, unit = "km")
    lit_areas_years = sapply(1:22, function(i) sum(values(arl[[i]]), na.rm = T))
    lit_areas_years[lit_areas_years == 0] = NA
    
    mod = arima(lit_areas_years, xreg=1:22, order = c(1, 0, 0))
    slp = round(mod$coef[3])
    
    arpred = predict(mod, newxreg=1:22)
    pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
    pvalue = pvalues[3]
    
    toc()
    return(c(lit_areas_years, slp, pvalue))
  })
  toc()
  return(uls)
})


# Last 3 countries
vectr = F
cnt_uls2 = sapply(names(regions_of_country)[7:9], function(country) {
  tic(country)
  country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                               shapefile_of_country[country]))
  cr = crop(ntl, ext(country_shp))
  reg_names = regions_of_country[[country]]
  uls = sapply(reg_names, function(reg_name) {
    regn_shp = country_shp[country_shp[[layer_shp_of_country[[country]]]] == 
                             reg_name, 2]
    tic(reg_name)
    cr = crop(cr, ext(regn_shp))
    if (vectr) cl = mask(cr, regn_shp) else cl = mask(cr, vect(regn_shp))
    cl[cl == 0] = NA
    
    arl = cellSize(cl, unit = "km")
    lit_areas_years = sapply(1:22, function(i) sum(values(arl[[i]]), na.rm = T))
    lit_areas_years[lit_areas_years == 0] = NA
    
    mod = arima(lit_areas_years, xreg=1:22, order = c(1, 0, 0))
    slp = round(mod$coef[3])
    
    arpred = predict(mod, newxreg=1:22)
    pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
    pvalue = pvalues[3]
    
    toc()
    return(c(lit_areas_years, slp, pvalue))
  })
  toc()
  return(uls)
})

print("USA") # we process Alaska separately each year, because shapefile is very big
vectr = F
regn_shp = reg_shp_rus
country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                             shapefile_of_country["USA"]))

reg_names = regions_of_country[["USA"]]
regn_shp = country_shp[country_shp[[layer_shp_of_country[["USA"]]]] == 
                         reg_names[1], 2]

lit_areas_years = sapply(1:22, function(i) {
  tic(i)
  cr = crop(ntl[[i]], ext(regn_shp))
  if (vectr) cl = mask(cr, regn_shp) else cl = mask(cr, vect(regn_shp))
  cl[cl == 0] = NA
  arl = cellSize(cl, unit = "km")
  toc()
  return(sum(values(arl), na.rm = T))
})

lit_areas_years[lit_areas_years == 0] = NA
mod = arima(lit_areas_years, xreg=1:22, order = c(1, 0, 0))
slp = round(mod$coef[3])
cat("ARIMA slope:", slp, "km2\n")
arpred = predict(mod, newxreg=1:22)
pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
pvalue = pvalues[3]
cat("ARIMA p-value:", pvalue)
all_numbers_us = c(lit_areas_years, slp, pvalue)
names(all_numbers_us) = c(paste0("Lit_km_", c(1992:2013)), "arima_slope", "p-value")

du =  data.frame(cnt_uls)
du = as.data.frame(t(du))
colnames(du) = c(paste0("Lit_km_", c(1992:2013)), "arima_slope", "p-value")

du2 = data.frame(cnt_uls2)
du2 = as.data.frame(t(du2))
colnames(du2) = c(paste0("Lit_km_", c(1992:2013)), "arima_slope", "p-value")

# Gathering all data in one data table

df = rbind(du, all_numbers_us, du2)


# Calculating growth extent
df$region = rownames(df)
df$region[24] = "USA.Alaska"
df$annual_growth_ext = round(100*df$arima_slope/df$Lit_km_1992,2)
inds_regs_1993 = df$region %in%  c("Norway.Finnmark", "Norway.Nordland", "Norway.Troms")
df$annual_growth_ext[inds_regs_1993] =
  round(100*df$arima_slope[inds_regs_1993]/df$Lit_km_1993[inds_regs_1993],2)

write.csv(df, 
          paste0("~/data/ntl/ntl_results/areas_of_subregions_per_year.csv"), 
          row.names = F)

