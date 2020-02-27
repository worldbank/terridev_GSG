library(tidyverse)
library(data.table)
library(ggplot2)
library(grid)
library(dplyr)

#####################
## DATASET CREATION #
#####################

# Variables for income groups and regions used in the loop
# High income
country_estimates <- read.csv("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv")
country_estimates <- country_estimates %>% filter(income=='High income')
hinc <- unique(country_estimates$iso3)
hinc <- as.character(hinc)

# Low income
country_estimates <- read.csv("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv")
country_estimates <- country_estimates %>% filter(income=='Low income')
linc <- unique(country_estimates$iso3)
linc <- as.character(linc)

# Upper MICS
country_estimates <- read.csv("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv")
country_estimates <- country_estimates %>% filter(income=='Upper middle income')
umics <- unique(country_estimates$iso3)
umics <- as.character(umics)

# Lower MICS
country_estimates <- read.csv("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv")
country_estimates <- country_estimates %>% filter(income=='Lower middle income')
lmics <- unique(country_estimates$iso3)
lmics <- as.character(lmics)

# MENA
country_estimates <- read.csv("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv")
country_estimates <- country_estimates %>% filter(region=='Middle East & North Africa')
MENA <- unique(country_estimates$iso3)
MENA <- as.character(MENA)

country <- umics ### HERE CHOOSE GROUP WE WANT TO COMPARE TO FROM ABOVE VARIABES ###
group <- 'umics' ### HERE CHOOSE GROUP WE WANT TO COMPARE TO FROM ABOVE VARIABES ###

comparison_ranking <- paste0('DB_SD_',group,'_rk')
comparison_score <- paste0('DB_SD_',group,'_score')

### Language indicator
esp <- 1 #choose 0 for english, 1 for spanish

for(i in country){

### COUNTRY ESTIMATES DATASET ###
country_estimates <- read.csv("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv")
country_estimates <- subset(country_estimates, iso3 == i)
country_estimates <- as.data.frame(t(as.matrix(country_estimates)))
country_estimates <- country_estimates %>% rownames_to_column("indicator")

country_estimates$indicator[country_estimates$indicator=="SP.POP.TOTL"] <- "Population"
country_estimates$indicator[country_estimates$indicator=="biodiv"] <- "Biodiversity"
country_estimates$indicator[country_estimates$indicator=="wind"] <- "Wind resources"
country_estimates$indicator[country_estimates$indicator=="solar"] <- "Solar resources"
country_estimates$indicator[country_estimates$indicator=="forest_loss"] <- "Forest loss"
country_estimates$indicator[country_estimates$indicator=="AG.LND.FRST.ZS"] <- "Forest cover"
country_estimates$indicator[country_estimates$indicator=="forest_cover_pc"] <- "Forest cover per capita"
country_estimates$indicator[country_estimates$indicator=="coastline"] <- "Coastline"
country_estimates$indicator[country_estimates$indicator=="trust_poli"] <- "Trust in politicians"
country_estimates$indicator[country_estimates$indicator=="social_capital"] <- "Social capital"
country_estimates$indicator[country_estimates$indicator=="AG.SRF.TOTL.K2"] <- "Surface area"
country_estimates$indicator[country_estimates$indicator=="SP.URB.TOTL"] <- "Urban population"
country_estimates$indicator[country_estimates$indicator=="SP.URB.TOTL.IN.ZS"] <- "Urban share"
country_estimates$indicator[country_estimates$indicator=="SP.URB.GROW"] <- "Urban growth"
country_estimates$indicator[country_estimates$indicator=="NY.ADJ.SVNG.GN.ZS"] <- "Net adjusted savings"
country_estimates$indicator[country_estimates$indicator=="EN.ATM.PM25.MC.M3"] <- "Air pollution (PM2.5)"
country_estimates$indicator[country_estimates$indicator=="agriland_pc"] <- "Agricultural land per capita"
country_estimates$indicator[country_estimates$indicator=="AG.YLD.CREL.KG"] <- "Cereal yield"
country_estimates$indicator[country_estimates$indicator=="VC.IDP.NWDS"] <- "Displacement due to disasters"
country_estimates$indicator[country_estimates$indicator=="EG.ELC.ACCS.ZS"] <- "Access to electricity"
country_estimates$indicator[country_estimates$indicator=="DT.DOD.DECT.GN.ZS"] <- "External debt stock"
country_estimates$indicator[country_estimates$indicator=="NE.EXP.GNFS.ZS"] <- "Exports"
country_estimates$indicator[country_estimates$indicator=="SL.AGR.EMPL.ZS"] <- "Employment in agriculture"
country_estimates$indicator[country_estimates$indicator=="AG.LND.AGRI.K2"] <- "Agricultural land (extent)"
country_estimates$indicator[country_estimates$indicator=="AG.LND.AGRI.ZS"] <- "Agricultural land (share)"
country_estimates$indicator[country_estimates$indicator=="NY.GDP.FRST.RT.ZS"] <- "Forest rents"
country_estimates$indicator[country_estimates$indicator=="NV.AGR.TOTL.ZS"] <- "Agri. forest fishery"
country_estimates$indicator[country_estimates$indicator=="NW.NCA.PC"] <- "Natural capital per capita"
country_estimates$indicator[country_estimates$indicator=="SH.STA.AIRP.P5"] <- "Air pollution (mort.)"
country_estimates$indicator[country_estimates$indicator=="SH.STA.WASH.P5"] <- "WASH pollution (mort.)"
country_estimates$indicator[country_estimates$indicator=="SH.STA.BASS.ZS"] <- "Access to sanitation"
country_estimates$indicator[country_estimates$indicator=="VC.IHR.PSRC.P5"] <- "Homicides rate"
country_estimates$indicator[country_estimates$indicator=="ER.H2O.INTR.PC"] <- "Water availability"
country_estimates$indicator[country_estimates$indicator=="ER.H2O.FWST.ZS"] <- "Water stress"
country_estimates$indicator[country_estimates$indicator=="SH.H2O.BASW.ZS"] <- "Access to water"
country_estimates$indicator[country_estimates$indicator=="mark_acc"] <- "Market access"


country_estimates$category <- ifelse(country_estimates$indicator == "Population" | country_estimates$indicator == "Coastline" |
                                   country_estimates$indicator =="Surface area" | country_estimates$indicator == "Urban population" | 
                                   country_estimates$indicator == "Urban share" | country_estimates$indicator == "Urban growth", '1.General',
                                 ifelse(country_estimates$indicator == "Net adjusted savings" | country_estimates$indicator == "External debt stock" |
                                          country_estimates$indicator == "Cereal yield" |country_estimates$indicator == "Exports" |
                                          country_estimates$indicator == "Employment in agriculture" |country_estimates$indicator == "Agri. forest fishery" |
                                          country_estimates$indicator == "Forest rents" | country_estimates$indicator == "Market access", '4.Economy',
                                        ifelse(country_estimates$indicator == "Forest loss" | country_estimates$indicator == "Water stress" |
                                                 country_estimates$indicator == "Biodiversity" |country_estimates$indicator == "Natural capital per capita" |
                                                 country_estimates$indicator == "Solar resources" |country_estimates$indicator == "Agricultural land (share)" |
                                                 country_estimates$indicator == "Agricultural land per capita" | country_estimates$indicator == "Agricultural land (extent)" |
                                                 country_estimates$indicator == "Water availability" | country_estimates$indicator == "Wind resources" |
                                                 country_estimates$indicator == "Forest cover" | country_estimates$indicator == "Forest cover per capita", '2.Natural capital',
                                               ifelse(country_estimates$indicator == "Access to water" | country_estimates$indicator == "Access to electricity" |
                                                        country_estimates$indicator == "Access to sanitation",'7.Services',
                                                      ifelse(country_estimates$indicator == "Air pollution (mort.)" | country_estimates$indicator == "Air pollution (PM2.5)" | country_estimates$indicator == "WASH pollution (mort.)",'5.Pollution',
                                                             ifelse(country_estimates$indicator == "Displacement due to disasters","3.DRM",
                                                                    ifelse( country_estimates$indicator == "Homicides rate" | country_estimates$indicator == "Social capital" | country_estimates$indicator == "Trust in politicians", '6.Social', 'else')))))))

country_estimates <- tail(country_estimates,-3)
country_estimates <- country_estimates %>% filter(indicator!='forest_1990' | indicator!='forest_2017')

if (esp == 1){
  country_estimates$indicator[country_estimates$indicator=="Population"] <- "Poblacion" #
  country_estimates$indicator[country_estimates$indicator=="Biodiversity"] <- "Biodiversidad" #
  country_estimates$indicator[country_estimates$indicator=="Wind resources"] <- "Recursos eolicos" #
  country_estimates$indicator[country_estimates$indicator=="Solar resources"] <- "Recursos solares" #
  country_estimates$indicator[country_estimates$indicator=="Forest loss"] <- "Deforestacion" #
  country_estimates$indicator[country_estimates$indicator=="Forest cover (km2)"] <- "Superficie forestal" #
  country_estimates$indicator[country_estimates$indicator=="Forest cover"] <- "Superficie forestal (%)" #
  country_estimates$indicator[country_estimates$indicator=="Forest cover per capita"] <- "Superficie forestal per capita"
  country_estimates$indicator[country_estimates$indicator=="Coastline"] <- "Litoral" #
  country_estimates$indicator[country_estimates$indicator=="Trust in politicians"] <- "Confianza en politicos"
  country_estimates$indicator[country_estimates$indicator=="Social capital"] <- "Capital social"
  country_estimates$indicator[country_estimates$indicator=="Surface area"] <- "Superficie" #
  country_estimates$indicator[country_estimates$indicator=="Urban population"] <- "Poblacion urbana" #
  country_estimates$indicator[country_estimates$indicator=="Urban share"] <- "Proporcion pobl. urbana" #
  country_estimates$indicator[country_estimates$indicator=="Urban growth"] <- "Crecimiento urbano" #
  country_estimates$indicator[country_estimates$indicator=="Net adjusted savings"] <- "Ahorros neto ajustado" #
  country_estimates$indicator[country_estimates$indicator=="Air pollution (PM2.5)"] <- "Contaminacion del aire (PM2.5)" #
  country_estimates$indicator[country_estimates$indicator=="Agricultural land per capita"] <- "Tierras agricolas per capita" #
  country_estimates$indicator[country_estimates$indicator=="Cereal yield"] <- "Rendimiento de cereales" #
  country_estimates$indicator[country_estimates$indicator=="Displacement due to disasters"] <- "Desplazamiento (desastres)"
  country_estimates$indicator[country_estimates$indicator=="Access to electricity"] <- "Accesso a la electricidad" #
  country_estimates$indicator[country_estimates$indicator=="External debt stock"] <- "Deuda externa" #
  country_estimates$indicator[country_estimates$indicator=="Exports"] <- "Exportaciones" #
  country_estimates$indicator[country_estimates$indicator=="Employment in agricultur"] <- "Empleo en agricultura" #
  country_estimates$indicator[country_estimates$indicator=="Agricultural land (extent)"] <- "Tierras agricolas (superficie))" #
  country_estimates$indicator[country_estimates$indicator=="Agricultural land (share)"] <- "Tierras agricolas (proporcion)" #
  country_estimates$indicator[country_estimates$indicator=="Forest rents"] <- "Rentas forestales" #
  country_estimates$indicator[country_estimates$indicator=="Agri. forest fishery"] <- "Agricultura, valor agregado" #
  country_estimates$indicator[country_estimates$indicator=="Natural capital per capita"] <- "Capital natural per capita" #
  country_estimates$indicator[country_estimates$indicator=="Air pollution (mort.)"] <- "Contaminacion del aire (mort.)" #
  country_estimates$indicator[country_estimates$indicator=="WASH pollution (mort.)"] <- "Conntaminacion WASH (mort.)" #
  country_estimates$indicator[country_estimates$indicator=="Access to sanitation"] <- "Accesso a saneamiento" #
  country_estimates$indicator[country_estimates$indicator=="Homicides rate"] <- "Tasa de homicidios" #
  country_estimates$indicator[country_estimates$indicator=="Water availability"] <- "Recursos hidricos per capita" #
  country_estimates$indicator[country_estimates$indicator=="Water stress"] <- "Estres hidrico" #
  country_estimates$indicator[country_estimates$indicator=="Access to water"] <- "Accesso al agua" #
  country_estimates$indicator[country_estimates$indicator=="Market access"] <- "Accesibilidad" #
  write.csv(country_estimates,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,".csv"), row.names = FALSE)
} else {
  write.csv(country_estimates,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,".csv"), row.names = FALSE)
}

### COUNTRY RANKED DATASET ###

country_ranked <- read.csv(paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",comparison_ranking,".csv"))
country_ranked <- country_ranked[country_ranked$iso3 == i, ]
country_ranked <- as.data.frame(t(as.matrix(country_ranked)))
country_ranked <- country_ranked %>% rownames_to_column("indicator")

country_ranked$indicator[country_ranked$indicator=="SP.POP.TOTL"] <- "Population"
country_ranked$indicator[country_ranked$indicator=="biodiv"] <- "Biodiversity"
country_ranked$indicator[country_ranked$indicator=="wind"] <- "Wind resources"
country_ranked$indicator[country_ranked$indicator=="solar"] <- "Solar resources"
country_ranked$indicator[country_ranked$indicator=="forest_loss"] <- "Forest loss"
country_ranked$indicator[country_ranked$indicator=="AG.LND.FRST.ZS"] <- "Forest cover"
country_ranked$indicator[country_ranked$indicator=="forest_cover_pc"] <- "Forest cover per capita"
country_ranked$indicator[country_ranked$indicator=="coastline"] <- "Coastline"
country_ranked$indicator[country_ranked$indicator=="trust_poli"] <- "Trust in politicians"
country_ranked$indicator[country_ranked$indicator=="social_capital"] <- "Social capital"
country_ranked$indicator[country_ranked$indicator=="AG.SRF.TOTL.K2"] <- "Surface area"
country_ranked$indicator[country_ranked$indicator=="SP.URB.TOTL"] <- "Urban population"
country_ranked$indicator[country_ranked$indicator=="SP.URB.TOTL.IN.ZS"] <- "Urban share"
country_ranked$indicator[country_ranked$indicator=="SP.URB.GROW"] <- "Urban growth"
country_ranked$indicator[country_ranked$indicator=="NY.ADJ.SVNG.GN.ZS"] <- "Net adjusted savings"
country_ranked$indicator[country_ranked$indicator=="EN.ATM.PM25.MC.M3"] <- "Air pollution (PM2.5)"
country_ranked$indicator[country_ranked$indicator=="agriland_pc"] <- "Agricultural land per capita"
country_ranked$indicator[country_ranked$indicator=="AG.YLD.CREL.KG"] <- "Cereal yield"
country_ranked$indicator[country_ranked$indicator=="VC.IDP.NWDS"] <- "Displacement due to disasters"
country_ranked$indicator[country_ranked$indicator=="EG.ELC.ACCS.ZS"] <- "Access to electricity"
country_ranked$indicator[country_ranked$indicator=="DT.DOD.DECT.GN.ZS"] <- "External debt stock"
country_ranked$indicator[country_ranked$indicator=="NE.EXP.GNFS.ZS"] <- "Exports"
country_ranked$indicator[country_ranked$indicator=="SL.AGR.EMPL.ZS"] <- "Employment in agriculture"
country_ranked$indicator[country_ranked$indicator=="AG.LND.AGRI.K2"] <- "Agricultural land (extent)"
country_ranked$indicator[country_ranked$indicator=="AG.LND.AGRI.ZS"] <- "Agricultural land (share)"
country_ranked$indicator[country_ranked$indicator=="NY.GDP.FRST.RT.ZS"] <- "Forest rents"
country_ranked$indicator[country_ranked$indicator=="NV.AGR.TOTL.ZS"] <- "Agri. forest fishery"
country_ranked$indicator[country_ranked$indicator=="NW.NCA.PC"] <- "Natural capital per capita"
country_ranked$indicator[country_ranked$indicator=="SH.STA.AIRP.P5"] <- "Air pollution (mort.)"
country_ranked$indicator[country_ranked$indicator=="SH.STA.WASH.P5"] <- "WASH pollution (mort.)"
country_ranked$indicator[country_ranked$indicator=="SH.STA.BASS.ZS"] <- "Access to sanitation"
country_ranked$indicator[country_ranked$indicator=="VC.IHR.PSRC.P5"] <- "Homicides rate"
country_ranked$indicator[country_ranked$indicator=="ER.H2O.INTR.PC"] <- "Water availability"
country_ranked$indicator[country_ranked$indicator=="ER.H2O.FWST.ZS"] <- "Water stress"
country_ranked$indicator[country_ranked$indicator=="SH.H2O.BASW.ZS"] <- "Access to water"
country_ranked$indicator[country_ranked$indicator=="mark_acc"] <- "Market access"

country_ranked$category <- ifelse(country_ranked$indicator == "Population" | country_ranked$indicator == "Coastline" |
                                   country_ranked$indicator =="Surface area" | country_ranked$indicator == "Urban population" | 
                                   country_ranked$indicator == "Urban share" | country_ranked$indicator == "Urban growth", '1.General',
                                 ifelse(country_ranked$indicator == "Net adjusted savings" | country_ranked$indicator == "External debt stock" |
                                          country_ranked$indicator == "Cereal yield" |country_ranked$indicator == "Exports" |
                                          country_ranked$indicator == "Employment in agriculture" |country_ranked$indicator == "Agri. forest fishery" |
                                          country_ranked$indicator == "Forest rents" | country_ranked$indicator == "Market access", '4.Economy',
                                        ifelse(country_ranked$indicator == "Forest loss" | country_ranked$indicator == "Water stress" |
                                                 country_ranked$indicator == "Biodiversity" | country_ranked$indicator == "Natural capital per capita" |
                                                 country_ranked$indicator == "Solar resources" |country_ranked$indicator == "Agricultural land (share)" |
                                                 country_ranked$indicator == "Agricultural land per capita" | country_ranked$indicator == "Agricultural land (extent)" |
                                                 country_ranked$indicator == "Water availability" | country_ranked$indicator == "Wind resources" |
                                                 country_ranked$indicator == "Forest cover" | country_ranked$indicator == "Forest cover per capita", '2.Natural capital',
                                               ifelse(country_ranked$indicator == "Access to water" | country_ranked$indicator == "Access to electricity" |
                                                        country_ranked$indicator == "Access to sanitation",'7.Services',
                                                      ifelse(country_ranked$indicator == "Air pollution (mort.)" | country_ranked$indicator == "Air pollution (PM2.5)" | country_ranked$indicator == "WASH pollution (mort.)",'5.Pollution',
                                                             ifelse(country_ranked$indicator == "Displacement due to disasters","3.DRM",
                                                                    ifelse( country_ranked$indicator == "Homicides rate" | country_ranked$indicator == "Social capital" | country_ranked$indicator == "Trust in politicians", '6.Social', 'else')))))))

country_ranked <- tail(country_ranked,-3)
country_ranked <- country_ranked %>% filter(indicator!='forest_1990' | indicator!='forest_2017')

if (esp == 1){
  country_ranked$indicator[country_ranked$indicator=="Population"] <- "Poblacion" #
  country_ranked$indicator[country_ranked$indicator=="Biodiversity"] <- "Biodiversidad" #
  country_ranked$indicator[country_ranked$indicator=="Wind resources"] <- "Recursos eolicos" #
  country_ranked$indicator[country_ranked$indicator=="Solar resources"] <- "Recursos solares" #
  country_ranked$indicator[country_ranked$indicator=="Forest loss"] <- "Deforestacion" #
  country_ranked$indicator[country_ranked$indicator=="Forest cover (km2)"] <- "Superficie forestal" #
  country_ranked$indicator[country_ranked$indicator=="Forest cover"] <- "Superficie forestal (%)" #
  country_ranked$indicator[country_ranked$indicator=="Forest cover per capita"] <- "Superficie forestal per capita"
  country_ranked$indicator[country_ranked$indicator=="Coastline"] <- "Litoral" #
  country_ranked$indicator[country_ranked$indicator=="Trust in politicians"] <- "Confianza en politicos"
  country_ranked$indicator[country_ranked$indicator=="Social capital"] <- "Capital social"
  country_ranked$indicator[country_ranked$indicator=="Surface area"] <- "Superficie" #
  country_ranked$indicator[country_ranked$indicator=="Urban population"] <- "Poblacion urbana" #
  country_ranked$indicator[country_ranked$indicator=="Urban share"] <- "Proporcion pobl. urbana" #
  country_ranked$indicator[country_ranked$indicator=="Urban growth"] <- "Crecimiento urbano" #
  country_ranked$indicator[country_ranked$indicator=="Net adjusted savings"] <- "Ahorros neto ajustado" #
  country_ranked$indicator[country_ranked$indicator=="Air pollution (PM2.5)"] <- "Contaminacion del aire (PM2.5)" #
  country_ranked$indicator[country_ranked$indicator=="Agricultural land per capita"] <- "Tierras agricolas per capita" #
  country_ranked$indicator[country_ranked$indicator=="Cereal yield"] <- "Rendimiento de cereales" #
  country_ranked$indicator[country_ranked$indicator=="Displacement due to disasters"] <- "Desplazamiento (desastres)"
  country_ranked$indicator[country_ranked$indicator=="Access to electricity"] <- "Accesso a la electricidad" #
  country_ranked$indicator[country_ranked$indicator=="External debt stock"] <- "Deuda externa" #
  country_ranked$indicator[country_ranked$indicator=="Exports"] <- "Exportaciones" #
  country_ranked$indicator[country_ranked$indicator=="Employment in agricultur"] <- "Empleo en agricultura" #
  country_ranked$indicator[country_ranked$indicator=="Agricultural land (extent)"] <- "Tierras agricolas (superficie))" #
  country_ranked$indicator[country_ranked$indicator=="Agricultural land (share)"] <- "Tierras agricolas (proporcion)" #
  country_ranked$indicator[country_ranked$indicator=="Forest rents"] <- "Rentas forestales" #
  country_ranked$indicator[country_ranked$indicator=="Agri. forest fishery"] <- "Agricultura, valor agregado" #
  country_ranked$indicator[country_ranked$indicator=="Natural capital per capita"] <- "Capital natural per capita" #
  country_ranked$indicator[country_ranked$indicator=="Air pollution (mort.)"] <- "Contaminacion del aire (mort.)" #
  country_ranked$indicator[country_ranked$indicator=="WASH pollution (mort.)"] <- "Conntaminacion WASH (mort.)" #
  country_ranked$indicator[country_ranked$indicator=="Access to sanitation"] <- "Accesso a saneamiento" #
  country_ranked$indicator[country_ranked$indicator=="Homicides rate"] <- "Tasa de homicidios" #
  country_ranked$indicator[country_ranked$indicator=="Water availability"] <- "Recursos hidricos per capita" #
  country_ranked$indicator[country_ranked$indicator=="Water stress"] <- "Estres hidrico" #
  country_ranked$indicator[country_ranked$indicator=="Access to water"] <- "Accesso al agua" #
  country_ranked$indicator[country_ranked$indicator=="Market access"] <- "Accesibilidad" #
  write.csv(country_ranked,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_rk.csv"), row.names = FALSE)
} else {
write.csv(country_ranked,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_rk.csv"), row.names = FALSE)
}

### COUNTRY SCORE DATASET ###

country_score <- read.csv(paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",comparison_score,".csv"))
country_score <- country_score[country_score$iso3 == i, ]
country_score <- as.data.frame(t(as.matrix(country_score)))
country_score <- country_score %>% rownames_to_column("indicator")

country_score$indicator[country_score$indicator=="SP.POP.TOTL"] <- "Population"
country_score$indicator[country_score$indicator=="biodiv"] <- "Biodiversity"
country_score$indicator[country_score$indicator=="wind"] <- "Wind resources"
country_score$indicator[country_score$indicator=="solar"] <- "Solar resources"
country_score$indicator[country_score$indicator=="forest_loss"] <- "Forest loss"
country_score$indicator[country_score$indicator=="AG.LND.FRST.ZS"] <- "Forest cover"
country_score$indicator[country_score$indicator=="forest_cover_pc"] <- "Forest cover per capita"
country_score$indicator[country_score$indicator=="coastline"] <- "Coastline"
country_score$indicator[country_score$indicator=="trust_poli"] <- "Trust in politicians"
country_score$indicator[country_score$indicator=="social_capital"] <- "Social capital"
country_score$indicator[country_score$indicator=="AG.SRF.TOTL.K2"] <- "Surface area"
country_score$indicator[country_score$indicator=="SP.URB.TOTL"] <- "Urban population"
country_score$indicator[country_score$indicator=="SP.URB.TOTL.IN.ZS"] <- "Urban share"
country_score$indicator[country_score$indicator=="SP.URB.GROW"] <- "Urban growth"
country_score$indicator[country_score$indicator=="NY.ADJ.SVNG.GN.ZS"] <- "Net adjusted savings"
country_score$indicator[country_score$indicator=="EN.ATM.PM25.MC.M3"] <- "Air pollution (PM2.5)"
country_score$indicator[country_score$indicator=="agriland_pc"] <- "Agricultural land per capita"
country_score$indicator[country_score$indicator=="AG.YLD.CREL.KG"] <- "Cereal yield"
country_score$indicator[country_score$indicator=="VC.IDP.NWDS"] <- "Displacement due to disasters"
country_score$indicator[country_score$indicator=="EG.ELC.ACCS.ZS"] <- "Access to electricity"
country_score$indicator[country_score$indicator=="DT.DOD.DECT.GN.ZS"] <- "External debt stock"
country_score$indicator[country_score$indicator=="NE.EXP.GNFS.ZS"] <- "Exports"
country_score$indicator[country_score$indicator=="SL.AGR.EMPL.ZS"] <- "Employment in agriculture"
country_score$indicator[country_score$indicator=="AG.LND.AGRI.K2"] <- "Agricultural land (extent)"
country_score$indicator[country_score$indicator=="AG.LND.AGRI.ZS"] <- "Agricultural land (share)"
country_score$indicator[country_score$indicator=="NY.GDP.FRST.RT.ZS"] <- "Forest rents"
country_score$indicator[country_score$indicator=="NV.AGR.TOTL.ZS"] <- "Agri. forest fishery"
country_score$indicator[country_score$indicator=="NW.NCA.PC"] <- "Natural capital per capita"
country_score$indicator[country_score$indicator=="SH.STA.AIRP.P5"] <- "Air pollution (mort.)"
country_score$indicator[country_score$indicator=="SH.STA.WASH.P5"] <- "WASH pollution (mort.)"
country_score$indicator[country_score$indicator=="SH.STA.BASS.ZS"] <- "Access to sanitation"
country_score$indicator[country_score$indicator=="VC.IHR.PSRC.P5"] <- "Homicides rate"
country_score$indicator[country_score$indicator=="ER.H2O.INTR.PC"] <- "Water availability"
country_score$indicator[country_score$indicator=="ER.H2O.FWST.ZS"] <- "Water stress"
country_score$indicator[country_score$indicator=="SH.H2O.BASW.ZS"] <- "Access to water"
country_score$indicator[country_score$indicator=="mark_acc"] <- "Market access"

country_score$category <- ifelse(country_score$indicator == "Population" | country_score$indicator == "Coastline" |
                                    country_score$indicator =="Surface area" | country_score$indicator == "Urban population" | 
                                    country_score$indicator == "Urban share" | country_score$indicator == "Urban growth", '1.General',
                                  ifelse(country_score$indicator == "Net adjusted savings" | country_score$indicator == "External debt stock" |
                                           country_score$indicator == "Cereal yield" |country_score$indicator == "Exports" |
                                           country_score$indicator == "Employment in agriculture" |country_score$indicator == "Agri. forest fishery" |
                                           country_score$indicator == "Forest rents" | country_score$indicator == "Market access", '4.Economy',
                                         ifelse(country_score$indicator == "Forest loss" | country_score$indicator == "Water stress" |
                                                  country_score$indicator == "Biodiversity" |country_score$indicator == "Natural capital per capita" |
                                                  country_score$indicator == "Solar resources" |country_score$indicator == "Agricultural land (share)" |
                                                  country_score$indicator == "Agricultural land per capita" | country_score$indicator == "Agricultural land (extent)" |
                                                  country_score$indicator == "Water availability" | country_score$indicator == "Wind resources" |
                                                  country_score$indicator == "Forest cover" | country_score$indicator == "Forest cover per capita", '2.Natural capital',
                                                ifelse(country_score$indicator == "Access to water" | country_score$indicator == "Access to electricity" |
                                                         country_score$indicator == "Access to sanitation",'7.Services',
                                                       ifelse(country_score$indicator == "Air pollution (mort.)" | country_score$indicator == "Air pollution (PM2.5)" | country_score$indicator == "WASH pollution (mort.)",'5.Pollution',
                                                       ifelse(country_score$indicator == "Displacement due to disasters","3.DRM",
                                                              ifelse(country_score$indicator == "Homicides rate" | country_score$indicator == "Social capital" | country_score$indicator == "Trust in politicians", '6.Social', 'else')))))))


country_score$cat_class <- ifelse(country_score$category == "General",1,
                                 ifelse(country_score$category == "Economy",4,
                                        ifelse(country_score$category == "Natural capital",2,
                                               ifelse(country_score$category == "Living standards",5,
                                                      ifelse(country_score$category == "DRM",3,
                                                             ifelse(country_score$category == "Social",6, 'else'))))))

country_score <- tail(country_score,-3)
country_score <- country_score %>% filter(indicator!='forest_1990' | indicator!='forest_2017')

if (esp == 1){
  country_score$indicator[country_score$indicator=="Population"] <- "Poblacion" #
  country_score$indicator[country_score$indicator=="Biodiversity"] <- "Biodiversidad" #
  country_score$indicator[country_score$indicator=="Wind resources"] <- "Recursos eolicos" #
  country_score$indicator[country_score$indicator=="Solar resources"] <- "Recursos solares" #
  country_score$indicator[country_score$indicator=="Forest loss"] <- "Deforestacion" #
  country_score$indicator[country_score$indicator=="Forest cover (km2)"] <- "Superficie forestal" #
  country_score$indicator[country_score$indicator=="Forest cover"] <- "Superficie forestal (%)" #
  country_score$indicator[country_score$indicator=="Forest cover per capita"] <- "Superficie forestal per capita"
  country_score$indicator[country_score$indicator=="Coastline"] <- "Litoral" #
  country_score$indicator[country_score$indicator=="Trust in politicians"] <- "Confianza en politicos"
  country_score$indicator[country_score$indicator=="Social capital"] <- "Capital social"
  country_score$indicator[country_score$indicator=="Surface area"] <- "Superficie" #
  country_score$indicator[country_score$indicator=="Urban population"] <- "Poblacion urbana" #
  country_score$indicator[country_score$indicator=="Urban share"] <- "Proporcion pobl. urbana" #
  country_score$indicator[country_score$indicator=="Urban growth"] <- "Crecimiento urbano" #
  country_score$indicator[country_score$indicator=="Net adjusted savings"] <- "Ahorros neto ajustado" #
  country_score$indicator[country_score$indicator=="Air pollution (PM2.5)"] <- "Contaminacion del aire (PM2.5)" #
  country_score$indicator[country_score$indicator=="Agricultural land per capita"] <- "Tierras agricolas per capita" #
  country_score$indicator[country_score$indicator=="Cereal yield"] <- "Rendimiento de cereales" #
  country_score$indicator[country_score$indicator=="Displacement due to disasters"] <- "Desplazamiento (desastres)"
  country_score$indicator[country_score$indicator=="Access to electricity"] <- "Accesso a la electricidad" #
  country_score$indicator[country_score$indicator=="External debt stock"] <- "Deuda externa" #
  country_score$indicator[country_score$indicator=="Exports"] <- "Exportaciones" #
  country_score$indicator[country_score$indicator=="Employment in agricultur"] <- "Empleo en agricultura" #
  country_score$indicator[country_score$indicator=="Agricultural land (extent)"] <- "Tierras agricolas (superficie))" #
  country_score$indicator[country_score$indicator=="Agricultural land (share)"] <- "Tierras agricolas (proporcion)" #
  country_score$indicator[country_score$indicator=="Forest rents"] <- "Rentas forestales" #
  country_score$indicator[country_score$indicator=="Agri. forest fishery"] <- "Agricultura, valor agregado" #
  country_score$indicator[country_score$indicator=="Natural capital per capita"] <- "Capital natural per capita" #
  country_score$indicator[country_score$indicator=="Air pollution (mort.)"] <- "Contaminacion del aire (mort.)" #
  country_score$indicator[country_score$indicator=="WASH pollution (mort.)"] <- "Conntaminacion WASH (mort.)" #
  country_score$indicator[country_score$indicator=="Access to sanitation"] <- "Accesso a saneamiento" #
  country_score$indicator[country_score$indicator=="Homicides rate"] <- "Tasa de homicidios" #
  country_score$indicator[country_score$indicator=="Water availability"] <- "Recursos hidricos per capita" #
  country_score$indicator[country_score$indicator=="Water stress"] <- "Estres hidrico" #
  country_score$indicator[country_score$indicator=="Access to water"] <- "Accesso al agua" #
  country_score$indicator[country_score$indicator=="Market access"] <- "Accesibilidad" #
  write.csv(country_score,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_score.csv"), row.names = FALSE)
} else {
  write.csv(country_score,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_score.csv"), row.names = FALSE)
}

# Format score data for graphs
country_score <- country_score[,c(3,1,2,4)]
country_score[,3] <- as.numeric(as.character(country_score[,3]))
country_score <- country_score[order(country_score[,1]),]

names(country_score)[3] <- "values"
country_score$cat_class <- NULL
names(country_score)[1] <- "group"
names(country_score)[2] <- "individual"
country_score$values <- with(country_score, (100-values))
country_score$values1 <- with(country_score, (100-values))
country_score$values1 <- as.integer(country_score$values1)
country_score$values <- as.integer(country_score$values)

# OUTPUTS FOR GRAPH1 and GRAPH2

country_score_graph1 <- country_score %>% filter(group=='1.General' | group=='2.Natural capital' & individual!='Forest loss' & individual!='Water stress' & individual!='Deforestacion' & individual!='Estres hidrico')
index <- c(1,2,3,4,5,6,7,8,9,10,11,15,16,13,14,12)
country_score_graph1$index <- index
country_score_graph1 <- country_score_graph1[order(country_score_graph1$index),]
country_score_graph1$index <- NULL
if (esp == 1){
  write.csv(country_score_graph1,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_score_graph1.csv"), row.names = FALSE)
} else {
  write.csv(country_score_graph1,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_score_graph1.csv"), row.names = FALSE)
}

country_score_graph2 <- country_score %>% filter(group=='4.Economy' | group=='3.DRM' | group=='5.Pollution' | group=='6.Social' | group=='7.Services' | individual=='Forest loss' | individual=='Water stress' | individual=='Deforestacion' | individual=='Estres hidrico')
index2 <- c(8,9,10,2,6,1,3,5,7,4,15,11,16,14,13,17,12,18,19,20)
country_score_graph2$index <- index2
country_score_graph2 <- country_score_graph2[order(country_score_graph2$index),]
country_score_graph2$index <- NULL
if (esp == 1){
  write.csv(country_score_graph2,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_score_graph2.csv"), row.names = FALSE)
} else {
  write.csv(country_score_graph2,paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_score_graph2.csv"), row.names = FALSE)
}


##########
# Graph1 #
##########

# Create dataset
if (esp == 1){
  data <- read.csv(file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_score_graph1.csv"), header=TRUE, sep=",")
} else {
  data <- read.csv(file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_score_graph1.csv"), header=TRUE, sep=",")
}
data$order <- seq(1, nrow(data))

# Move order column to the front so it does not get rejected when transforming to long format (column necessary to keep order of dimensions for the graph)
data <- data %>% select(order, everything())

# Transform data in a tidy format (long format)
data <- reshape(data, 
                direction = "long",
                varying = list(names(data)[4:5]),
                v.names = "value",
                idvar = c("order", "individual", "group"),
                timevar = "observation",
                times = 1:2)

# Set a number of 'empty bar' to add at the end of each group
empty_bar <- 2
nObsType <- nlevels(as.factor(data$observation))
to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group)*nObsType, ncol(data)) )
colnames(to_add) <- colnames(data)
to_add$group <- rep(levels(data$group), each=empty_bar*nObsType )
data <- rbind(data, to_add)

# Group IDs
grpid = function(x) match(x, unique(x))
data <- data %>% mutate(group_id = group_indices(., group) %>% grpid)

data <- data %>% mutate(group_order=case_when(
  group_id == 1 ~ "A",
  group_id == 2 ~ "B",
  TRUE ~ NA_character_ # all else are NA
))

data <- data %>% arrange(group_order, order)
data$id <- rep( seq(1, nrow(data)/nObsType) , each=nObsType)

# Get the name and the y position of each label
label_data <- data %>% group_by(id, individual) %>% summarize(tot=sum(value))
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)

# prepare a data frame for base lines
base_data <- data %>% 
  group_by(group_order) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))

#allows to classify in the order we prefer
base_data <- base_data %>% mutate(group=case_when(
  group_order == "A" ~ "General",
  group_order == "B" ~ "Nat. capital",
  TRUE ~ NA_character_ # all else are NA
))

if (esp==1){base_data <- base_data %>% mutate(group=case_when(
  group_order == "A" ~ "General",
  group_order == "B" ~ "Capital nat.",
  TRUE ~ NA_character_ # all else are NA
)) } else {base_data <- base_data %>% mutate(group=case_when(
  group_order == "A" ~ "General",
  group_order == "B" ~ "Natural cap.",
  TRUE ~ NA_character_ # all else are NA
)) 
}

# prepare a data frame for grid (scales)
grid_data <- base_data
grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start <- grid_data$start - 1
grid_data <- grid_data[-1,]

# column combining 2 variables
data$cat <- paste(data$observation,data$group_order)

# Make the plot
p <- ggplot(data) +      
  
  # Add the stacked bar
  geom_bar(aes(x=as.factor(id), y=value, fill=cat, colour=cat), stat="identity", alpha=0.5, size=0.2) +
  scale_fill_manual(values=c("white","white","orange","limegreen")) +
  scale_colour_manual(values=c("black","black","black","black")) +
  
  # Add a val=100/75/50/25 lines. I do it at the beginning to make sur barplots are OVER it.
  geom_segment(data=grid_data, aes(x = end, y = 100, xend = start, yend = 100), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 80, xend = start, yend = 80), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 60, xend = start, yend = 60), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 40, xend = start, yend = 40), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 20, xend = start, yend = 20), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  
  # Add country annotation
  geom_label(x = 0, y = -65, label = i, hjust=0.5, fontface="bold", size=12) +
  
  # Add text showing the value of each 100/75/50/25 lines
  annotate("text", x = rep(max(data$id),5), y = c(20, 40, 60, 80, 100), label = c("20", "40", "60", "80", "100") , color="grey", size=5 , angle=0, fontface="bold", hjust=1) +
  
  ylim(-70,max(label_data$tot, na.rm=T)) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = margin(-3,-3,-3,-3, "cm") 
  ) +
  coord_polar() +
  
  # Add labels on top of each bar
  geom_text(data=label_data, aes(x=id, y=tot-50, label=individual, hjust=0.5), color="black", fontface="bold",alpha=1, size=5, angle= label_data$angle, inherit.aes = FALSE ) +
  
  # Add base line information
  geom_segment(data=base_data, aes(x = start, y = -5, xend = end, yend = -5), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
  geom_text(data=base_data, aes(x = title, y = -15, label=group), hjust=c(0.5,0.5), angle=c(-50,-50), colour = "black", alpha=0.8, size=5, fontface="bold", inherit.aes = FALSE)

# Save at png
if (esp == 1){
  ggsave(p, file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_score_graph1.png"), width=10, height=10)
} else {
  ggsave(p, file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_score_graph1.png"), width=10, height=10)
}

##########
# Graph2 #
##########
if (esp == 1){
  data <- read.csv(file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_score_graph2.csv"), header=TRUE, sep=",")
} else {
  data <- read.csv(file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_score_graph2.csv"), header=TRUE, sep=",")
}
data$order <- seq(1, nrow(data))

# Move order column to the front so it does not get rejected when transforming to long format (column necessary to keep order of dimensions for the graph)
data <- data %>% select(order, everything())

# Transform data in a tidy format (long format)
data <- reshape(data, 
                direction = "long",
                varying = list(names(data)[4:5]),
                v.names = "value",
                idvar = c("order", "individual", "group"),
                timevar = "observation",
                times = 1:2)

# Set a number of 'empty bar' to add at the end of each group
empty_bar <- 2
nObsType <- nlevels(as.factor(data$observation))
to_add <- data.frame( matrix(NA, empty_bar*nlevels(data$group)*nObsType, ncol(data)) )
colnames(to_add) <- colnames(data)
to_add$group <- rep(levels(data$group), each=empty_bar*nObsType )
data <- rbind(data, to_add)

# Group IDs
grpid = function(x) match(x, unique(x))
data <- data %>% mutate(group_id = group_indices(., group) %>% grpid)

data <- data %>% mutate(group_order=case_when(
  group_id == 1 ~ "A",
  group_id == 2 ~ "B",
  group_id == 3 ~ "C",
  group_id == 4 ~ "D",
  group_id == 5 ~ "E",
  group_id == 6 ~ "F",
  TRUE ~ NA_character_ # all else are NA
))

data <- data %>% arrange(group_order, order)
data$id <- rep( seq(1, nrow(data)/nObsType) , each=nObsType)

# Get the name and the y position of each label
label_data <- data %>% group_by(id, individual) %>% summarize(tot=sum(value))
number_of_bar <- nrow(label_data)
angle <- 90 - 360 * (label_data$id-0.5) /number_of_bar     # I substract 0.5 because the letter must have the angle of the center of the bars. Not extreme right(1) or extreme left (0)
label_data$hjust <- ifelse( angle < -90, 1, 0)
label_data$angle <- ifelse(angle < -90, angle+180, angle)

# prepare a data frame for base lines
base_data <- data %>% 
  group_by(group_order) %>% 
  summarize(start=min(id), end=max(id) - empty_bar) %>% 
  rowwise() %>% 
  mutate(title=mean(c(start, end)))

#allows to classify in the order we prefer
if (esp==1){base_data <- base_data %>% mutate(group=case_when(
  group_order == "A" ~ "Economia",
  group_order == "B" ~ "Destruccion\ncapital natural",
  group_order == "C" ~ "DRM",
  group_order == "D" ~ "Contaminacion",
  group_order == "E" ~ "Social",
  group_order == "F" ~ "Servicios",
  TRUE ~ NA_character_ # all else are NA
)) } else {base_data <- base_data %>% mutate(group=case_when(
  group_order == "A" ~ "Economy",
  group_order == "B" ~ "Natural cap.\ndepletion",
  group_order == "C" ~ "DRM",
  group_order == "D" ~ "Pollution",
  group_order == "E" ~ "Social",
  group_order == "F" ~ "Services",
  TRUE ~ NA_character_ # all else are NA
)) 
}

# prepare a data frame for grid (scales)
grid_data <- base_data
grid_data$end <- grid_data$end[ c( nrow(grid_data), 1:nrow(grid_data)-1)] + 1
grid_data$start <- grid_data$start - 1
grid_data <- grid_data[-1,]

# column combining 2 variables
data$cat <- paste(data$observation,data$group_order)

# Make the plot
p <- ggplot(data) +      
  
  # Add the stacked bar
  geom_bar(aes(x=as.factor(id), y=value, fill=cat, colour=cat), stat="identity", alpha=0.5, size=0.2) +
  scale_fill_manual(values=c("white","white","white","white","white","white","steelblue1","orange","turquoise3","red","orchid","tomato")) +
  scale_colour_manual(values=c("black","black","black","black","black","black","black","black","black","black","black","black")) +
  
  # Add a val=100/75/50/25 lines. I do it at the beginning to make sur barplots are OVER it.
  geom_segment(data=grid_data, aes(x = end, y = 100, xend = start, yend = 100), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 80, xend = start, yend = 80), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 60, xend = start, yend = 60), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 40, xend = start, yend = 40), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  geom_segment(data=grid_data, aes(x = end, y = 20, xend = start, yend = 20), colour = "grey", alpha=1, size=0.3 , inherit.aes = FALSE ) +
  
  # Add country annotation
  geom_label(x = 0, y = -65, label = i, hjust=0.5, fontface="bold", size=12) +
  
  # Add text showing the value of each 100/75/50/25 lines
  annotate("text", x = rep(max(data$id),5), y = c(20, 40, 60, 80, 100), label = c("20", "40", "60", "80", "100") , color="grey", size=5 , angle=0, fontface="bold", hjust=1) +
  
  ylim(-70,max(label_data$tot, na.rm=T)) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = margin(-3,-3,-3,-3, "cm") 
  ) +
  coord_polar() +
  
  # Add labels on top of each bar
  geom_text(data=label_data, aes(x=id, y=tot-50, label=individual, hjust=0.5), color="black", fontface="bold",alpha=1, size=5, angle= label_data$angle, inherit.aes = FALSE ) +
  
  # Add base line information
  geom_segment(data=base_data, aes(x = start, y = -5, xend = end, yend = -5), colour = "black", alpha=0.8, size=0.6 , inherit.aes = FALSE )  +
  geom_text(data=base_data, aes(x = title, y = -15, label=group), hjust=c(0.5,0.5,0.5,0.5,0.5,0.5), angle=c(-45,55,20,-30,-85,40), colour = "black", alpha=0.8, size=5, fontface="bold", inherit.aes = FALSE)

# Save at png
if (esp == 1){
  ggsave(p, file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/ESP/",group,'/',i,"_score_graph2.png"), width=10, height=10)
} else {
  ggsave(p, file=paste0("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/",group,'/',i,"_score_graph2.png"), width=10, height=10)
}
}
