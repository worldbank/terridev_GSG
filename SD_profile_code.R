library(WDI)
library(plyr)
library(dplyr)
library(rvest)
library(readxl)
library(rvest)
library(tidyverse)

######################
### WDI INDICATORS ###
######################

# WDI indicators
ind <-c('SP.POP.TOTL','AG.SRF.TOTL.K2','SP.URB.TOTL','SP.URB.TOTL.IN.ZS','SP.URB.GROW','NY.ADJ.SVNG.GN.ZS','NV.AGR.TOTL.ZS','EN.ATM.PM25.MC.M3','AG.LND.ARBL.HA.PC','AG.LND.ARBL.HA','AG.YLD.CREL.KG','VC.IDP.NWDS','EG.ELC.ACCS.ZS','DT.DOD.DECT.GN.ZS','NE.EXP.GNFS.ZS','SL.AGR.EMPL.ZS','AG.LND.FRST.K2','AG.LND.FRST.ZS','NY.GDP.FRST.RT.ZS','NV.AGR.TOTL.ZS','NW.NCA.PC','SH.STA.AIRP.P5','SH.STA.WASH.P5','SH.STA.BASS.ZS','VC.IHR.PSRC.P5','ER.H2O.INTR.PC','ER.H2O.FWST.ZS','SH.H2O.BASW.ZS')

# Importation and cleaning of each WDI indicator
for(i in ind){
  print(i)
  wdi <- WDI(country = "all", indicator = i, start = 2000, end = NULL, extra = TRUE, cache = NULL)
  wdi <- na.omit(wdi)
  wdi <- wdi %>% group_by(iso2c) %>% filter(year==max(year))
  wdi <- subset(wdi, select = -c(iso2c,year,country,capital,longitude,latitude,lending)) %>% rename(iso3=iso3c)
  assign(paste('wdi_',i,sep=''),wdi)
}

######################
### WEF INDICATORS ###
######################

# WEF Global Competitiveness Index dataset
WEF <- read.csv("https://tcdata360-backend.worldbank.org/api/v1/datasets/53/dump.csv")
social_capital <- WEF %>% filter(Subindicator.Type=='Value') %>% filter(Indicator=='GCI 4.0: Social capital')
social_capital <- subset(social_capital, select = c(Country.ISO3,X2019) ) %>% rename(iso3=Country.ISO3,social_capital=X2019)

trust_in_politicians <- WEF %>% filter(Subindicator.Type=='1-7 Best') %>% filter(Indicator=='Public trust in politicians')
trust_in_politicians <- subset(trust_in_politicians, select = c(Country.ISO3,X2017.2018) ) %>% rename(iso3=Country.ISO3,trust_poli=X2017.2018)

#################
### COASTLINE ###
#################

# Coastline with web scraping
library(rvest)
URL <- "https://web.archive.org/web/20120419075053/http://earthtrends.wri.org/text/coastal-marine/variable-61.html"
page <- read_html(URL) #Creates an html document from URL
table <- html_table(page, fill = TRUE) #Parses tables into data frames
coastline_table <- table[[4]]
coastline_table <- tail(coastline_table,-19)
coastline_table <- subset(coastline_table, select = c(X2,X3)) %>% rename(iso3=X2,coastline=X3)
coastline_table$coastline <- as.numeric(gsub(",","",coastline_table$coastline)) # delete commas


###################
### FOREST LOSS ###
###################

# FAO Web scraping country codes
URL <- "http://www.fao.org/countryprofiles/iso3list/en/"
page <- read_html(URL) #Creates an html document from URL
table <- html_table(page, fill = TRUE) #Parses tables into data frames
FAO_cc <- table[[1]] %>% rename(iso3=ISO3,country='Short name')
FAO_cc <- subset(FAO_cc, select = c(country,iso3))

# Deforestation
temp <- tempfile()
download.file("http://fenixservices.fao.org/faostat/static/bulkdownloads/Emissions_Land_Use_Forest_Land_E_All_Data.zip",temp,mode="wb")
unzip(temp, "Emissions_Land_Use_Forest_Land_E_All_Data.csv")
defor <- read.table("Emissions_Land_Use_Forest_Land_E_All_Data.csv", sep=",",skip=2, header=F)
defor <- defor %>% filter(V4=='Forest land') %>% filter(V6=='Area') %>% filter(V55=="F")
defor <- subset(defor, select = c(V2,V8,V62)) %>% rename(country=V2,forest_1990=V8,forest_2017=V62)
defor2 <- left_join(defor,FAO_cc)
defor2 <- subset(defor2,select = -c(country))
# Correcting issues due to translation of variables
defor2[214, 4] = "GBR"
defor2[42, 4] = "CHN"
defor2[48, 4] = "CIV"
defor2$forest_loss <- with(defor2, (forest_2017-forest_1990)/forest_1990)

#############
### SOLAR ###
#############
solar <- read_excel("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Add_dim/dim_used/cleaned/solar_agg.xlsx")
solar <- solar %>% rename(iso3=cc)

############
### WIND ###
############
wind <- read_excel("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Add_dim/dim_used/cleaned/wind_agg.xlsx")
wind <- wind %>% rename(iso3=cc)

##################
## BIODIVERSITY ##
##################
biodiv <- read_excel("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Add_dim/dim_used/cleaned/biodiv_agg.xlsx")
biodiv <- biodiv %>% rename(iso3=cc)

#____________#
#_ JOIN ALL _#
#____________#
wdi_SP.POP.TOTL <- wdi_SP.POP.TOTL[,c(2,3,4,1)] #Change order to get an inntegrated dataframe starting with string columns
ind2 <- list(wdi_SP.POP.TOTL,biodiv,wind,solar,defor2,coastline_table,trust_in_politicians,social_capital,
             wdi_AG.SRF.TOTL.K2,wdi_SP.URB.TOTL,wdi_SP.URB.TOTL.IN.ZS,wdi_SP.URB.GROW,wdi_NY.ADJ.SVNG.GN.ZS,
             wdi_EN.ATM.PM25.MC.M3,wdi_AG.LND.ARBL.HA.PC,wdi_AG.YLD.CREL.KG,wdi_VC.IDP.NWDS,wdi_EG.ELC.ACCS.ZS,
             wdi_DT.DOD.DECT.GN.ZS,wdi_NE.EXP.GNFS.ZS,wdi_SL.AGR.EMPL.ZS,wdi_AG.LND.FRST.K2,wdi_AG.LND.FRST.ZS,
             wdi_NY.GDP.FRST.RT.ZS,wdi_NV.AGR.TOTL.ZS,wdi_NW.NCA.PC,wdi_SH.STA.AIRP.P5,wdi_SH.STA.WASH.P5,wdi_SH.STA.BASS.ZS,
             wdi_VC.IHR.PSRC.P5,wdi_ER.H2O.INTR.PC,wdi_ER.H2O.FWST.ZS,wdi_SH.H2O.BASW.ZS)

integrated <- join_all(ind2, type = "left", match = "all")

#___________#
#_ RANKING _#
#___________#

rank_f <- function(x, na.rm=FALSE) (rank(-x,na.last = "keep"))
integrated_rk <- integrated %>% mutate_if(is.double, rank_f)

#__________#
#_ EXPORT _#
#__________#

write.csv(integrated,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv", row.names = FALSE)
write.csv(integrated_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_rk.csv", row.names = FALSE)

