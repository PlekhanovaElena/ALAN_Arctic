library(scales)
library(ggplot2)

## Reading the data

df = read.csv("~/data/ntl/ntl_results/aurora_correction/table_1_of_areas_per_year.csv")
ggdat = df[df$region == "pan-Arctic", 1:22]
ggdat = data.frame(t(ggdat))
colnames(ggdat) = "extent"
ggdat$year = 1992:2013

## Calculating ARIMA slope and prediction

x = ggdat$year
y = ggdat$extent
mod = arima(y, xreg=x, order = c(1, 0, 0))
cat("ARIMA slope:", round(mod$coef[3]), "km2\n")
arpred = predict(mod, newxreg=ggdat$year)
ggdat$arima_pred = as.vector(arpred$pred)
pvalues = (1-pnorm(abs(mod$coef)/sqrt(diag(mod$var.coef))))*2
pvalue = pvalues[3]
cat("ARIMA p-value:", pvalue)

## Plotting Fig 1

ggplot(ggdat, aes(x = year)) + 
  geom_point(aes(y = extent), alpha = 0.6, size = 1.8) + 
  geom_line(aes(y = extent), size = 0.2) +
  geom_line(aes(y = arima_pred), size = 0.8) +
  annotate(geom = "text", label = paste("slope ==", round(mod$coef[3]), 
                                        expression (~km^2)), parse=TRUE, 
           x = Inf, y = -Inf, 
           hjust = 1.1, vjust = -1) +
  
  labs(y = expression ("Lit area,"~km^2)) +
  scale_y_continuous(labels = label_comma()) +
  theme_classic()
