
## Creating Table 1

sts = read.csv("~/data/ntl//ntl_results/aurora_correction/table_of_areas.csv")
ext_gr = read.csv("~/data/ntl//ntl_results/aurora_correction/table_1_of_areas_per_year.csv")
hum = read.csv("~/data/ntl//ntl_results/aurora_correction/table_of_lit_by_humans.csv")
hum$min = apply(hum[,2:5], 1, function(x) round(min(x)))
hum$max = apply(hum[,2:5], 1, function(x) round(max(x)))
colnames(sts)
colnames(ext_gr)

dat = sts[,c("region", "total.area", "lit.area", "newly.lit.area")]
dat$lit.area = paste0(sts$lit.area, " (",sts$percent.of.lit.to.total,"%)")
dat$newly.lit.area = paste0(sts$newly.lit.area, " (",sts$percent.of.newly.lit.to.total,"%)")
dat$extent.growth = paste0(ext_gr$annual_growth_ext, "%", ifelse(ext_gr$p.value < 0.05, "*", ""))
dat$human.activity.growth = paste0(sts$annual.growth.intensity, "%")
dat$percent.lit.human = paste0(round(hum$mean), "% (",hum$min, "% - ", hum$max, "%)")
dat = dat[c(1,2,4,3),]

write.csv(dat, "~/data/ntl//ntl_results/aurora_correction/Table_1.csv", row.names = F)


## Creating Supplementary Table 1



sts = read.csv("~/data/ntl//ntl_results/aurora_correction/table_of_areas_regions.csv")
ext_gr = read.csv("~/data/ntl//ntl_results/aurora_correction/areas_of_subregions_per_year.csv")
hum = read.csv("~/data/ntl//ntl_results/aurora_correction/table_of_lit_by_humans_regions.csv")
hum$min = apply(hum[,2:5], 1, function(x) round(min(x)))
hum$max = apply(hum[,2:5], 1, function(x) round(max(x)))

dat = sts[,c("region", "total.area", "lit.area", "newly.lit.area")]
dat$lit.area = paste0(sts$lit.area, " (",sts$percent.of.lit.to.total,"%)")
dat$newly.lit.area = paste0(sts$newly.lit.area, " (",sts$percent.of.newly.lit.to.total,"%)")
dat$extent.growth = paste0(ext_gr$annual_growth_ext, "%", ifelse(ext_gr$p.value < 0.05, "*", ""))
dat$human.activity.growth = paste0(sts$annual.growth.intensity, "%")
dat$percent.lit.human = paste0(round(hum$mean), "% (",hum$min, "% - ", hum$max, "%)")
dat$signif.inc = paste0(sts$percent.increase, "%")
dat$signif.dec = paste0(sts$percent.decrease, "%")

write.csv(dat, "~/data/ntl//ntl_results/aurora_correction/Supplementary_Table_2.csv", row.names = F)



