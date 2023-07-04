library(terra)
library(rgdal)
library(tictoc)
library(reshape)

ntl = rast("~/data/ntl/ntl_results/cum_ntls.tif")


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

newly_lit_area_calc = function(rastr, rastr_base_year) {
  cln = rastr
  cln[cln == 0] = NA
  cln[rastr_base_year > 0] = NA
  arn = cellSize(cln, unit = "km")
  return(sum(values(arn), na.rm = T))
}

lit_area_inc_dec = function(rastr, total_area_loc) {
  cli = rastr
  cli[cli <= 0] = NA
  ari = cellSize(cli, unit = "km")
  increase_area = sum(values(ari), na.rm = T)
  
  cld = rastr
  cld[cld >= 0] = NA
  ard = cellSize(cld, unit = "km")
  decrease_area = sum(values(ard), na.rm = T)
  
  cat("increase_area", round(100*increase_area/total_area_loc,2), "%\n")
  cat("decrease_area", round(100*decrease_area/total_area_loc,2), "%\n")
  return(c(round(100*increase_area/total_area_loc,2),
           round(100*decrease_area/total_area_loc,2)))
}

final_year = rast("~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif")[[22]]
lm_slope = rast("~/data/ntl/ntl_results/arima_slopes_significant.tif")
lm_slope[lm_slope == 100] = NA

base_year = rast("~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif")[[1]]



cnt_uls = sapply(names(regions_of_country), function(country) {
  tic(country)
  if (country == "Norway") { # calculating newly lit areas based on 1993 for Norway
    base_year = rast("~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif")[[2]]
  }
  country_shp = readOGR(paste0("~/data/ntl/regions_shapefiles/", 
                               shapefile_of_country[country]))
  reg_names = regions_of_country[[country]]
  uls = sapply(reg_names, function(reg_name) {
    print(reg_name)
    regn_shp = country_shp[country_shp[[layer_shp_of_country[[country]]]] == 
                            reg_name, 2]
    cl = clip_to_shape(ntl, regn_shp)
    clb = clip_to_shape(base_year, regn_shp)
    crlm = clip_to_shape(lm_slope, regn_shp)
    clf = clip_to_shape(final_year, regn_shp)
    total_area = area_calc(cl)
    lit_area = lit_area_calc(cl)
    newly_lit_area = newly_lit_area_calc(cl, clb)
    annual_growth_intensity = 
      (sum(values(clf), na.rm = T) - 
         sum(values(clb), na.rm = T))/(sum(values(clb), na.rm = T)*22)
    inc_dec = lit_area_inc_dec(crlm, total_area)
    
    all_numbers = c(round(total_area),
                    round(lit_area),
                    round(100*lit_area/total_area, 2),
                    round(newly_lit_area),
                    round(100*newly_lit_area/total_area, 2),
                    round(100*annual_growth_intensity, 2),
                    inc_dec)
    
    return(c(country, reg_name, all_numbers))
  })
  toc()
  return(uls)
})

du =  data.frame(cnt_uls)
du = as.data.frame(t(du))
colnames(du) = c("country", "region","total area", "lit area", 
                 "percent of lit to total", "newly lit area",
                  "percent of newly lit to total", 
                  "annual growth intensity",
                  "percent increase", "percent decrease")
for (i in 3:10) {
  du[,i] = as.numeric(du[,i])
}

write.csv(du, paste0("~/data/ntl/ntl_results/table_of_areas_regions.csv"), row.names = F)






base_year = rast("~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif")[[2]]
print("EU excl. Greenland")
regn_shp = reg_shp_eu
cl = clip_to_shape(ntl, regn_shp, vectr = T)
clb = clip_to_shape(base_year, regn_shp, vectr = T)
crlm = clip_to_shape(lm_slope, regn_shp, vectr = T)
clf = clip_to_shape(final_year, regn_shp, vectr = T)
total_area = area_calc(cl)
lit_area = lit_area_calc(cl)
newly_lit_area = newly_lit_area_calc(cl, clb)
annual_growth_intensity = 
  (sum(values(clf), na.rm = T) - 
     sum(values(clb), na.rm = T))/(sum(values(clb), na.rm = T)*21)
inc_dec = lit_area_inc_dec(crlm, total_area)

all_numbers = c(round(total_area),
                round(lit_area),
                round(100*lit_area/total_area, 2),
                round(newly_lit_area),
                round(100*newly_lit_area/total_area, 2),
                round(100*annual_growth_intensity, 2),
                inc_dec)

all_numbers_eu = all_numbers

base_year = rast("~/data/ntl/ntl_results/Z_DMSPstacked_45latitude.tif")[[1]]
print("North America")
regn_shp = reg_shp_na
cl = clip_to_shape(ntl, regn_shp)
clb = clip_to_shape(base_year, regn_shp)
crlm = clip_to_shape(lm_slope, regn_shp)
clf = clip_to_shape(final_year, regn_shp)
total_area = area_calc(cl)
lit_area = lit_area_calc(cl)
newly_lit_area = newly_lit_area_calc(cl, clb)
annual_growth_intensity = 
  (sum(values(clf), na.rm = T) - 
     sum(values(clb), na.rm = T))/(sum(values(clb), na.rm = T)*22)
inc_dec = lit_area_inc_dec(crlm, total_area)

all_numbers = c(round(total_area),
                round(lit_area),
                round(100*lit_area/total_area, 2),
                round(newly_lit_area),
                round(100*newly_lit_area/total_area, 2),
                round(100*annual_growth_intensity, 2),
                inc_dec)

all_numbers_na = all_numbers

print("Russia")
regn_shp = reg_shp_rus
cl = clip_to_shape(ntl, regn_shp)
clb = clip_to_shape(base_year, regn_shp)
crlm = clip_to_shape(lm_slope, regn_shp)
clf = clip_to_shape(final_year, regn_shp)
total_area = area_calc(cl)
lit_area = lit_area_calc(cl)
newly_lit_area = newly_lit_area_calc(cl, clb)
annual_growth_intensity = 
  (sum(values(clf), na.rm = T) - 
     sum(values(clb), na.rm = T))/(sum(values(clb), na.rm = T)*22)
inc_dec = lit_area_inc_dec(crlm, total_area)

all_numbers = c(round(total_area),
                round(lit_area),
                round(100*lit_area/total_area, 2),
                round(newly_lit_area),
                round(100*newly_lit_area/total_area, 2),
                round(100*annual_growth_intensity, 2),
                inc_dec)

all_numbers_rus = all_numbers



print("pan-Arctic")
regn_shp = reg_shp_un_pa
cl = clip_to_shape(ntl, regn_shp, vectr = T)
clb = clip_to_shape(base_year, regn_shp, vectr = T)
crlm = clip_to_shape(lm_slope, regn_shp, vectr = T)
clf = clip_to_shape(final_year, regn_shp, vectr = T)
total_area = area_calc(cl)
lit_area = lit_area_calc(cl)
newly_lit_area = newly_lit_area_calc(cl, clb)
annual_growth_intensity = 
  (sum(values(clf), na.rm = T) - 
     sum(values(clb), na.rm = T))/(sum(values(clb), na.rm = T)*22)
inc_dec = lit_area_inc_dec(crlm, total_area)

all_numbers = c(round(total_area),
                round(lit_area),
                round(100*lit_area/total_area, 2),
                round(newly_lit_area),
                round(100*newly_lit_area/total_area, 2),
                round(100*annual_growth_intensity, 2),
                inc_dec)

all_numbers_arctic = all_numbers


dat = data.frame(rbind(all_numbers_arctic, all_numbers_rus, 
                       all_numbers_na, all_numbers_eu))
colnames(dat) = c("total area", "lit area", 
                  "percent of lit to total", "newly lit area",
                  "percent of newly lit to total", 
                  "annual growth intensity",
                  "percent increase", "percent decrease")
dat$region = c("pan-Arctic","Russia", "North America", "EU excl. Greenland")

write.csv(dat, "~/data/ntl/ntl_results/table_of_areas.csv")


