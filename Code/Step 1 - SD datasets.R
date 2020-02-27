library(WDI)
library(plyr)
library(dplyr)
library(readxl)
library(rvest)
library(tidyverse)

######################
### WDI INDICATORS ###
######################

# WDI indicators
ind <-c('SP.POP.TOTL','AG.SRF.TOTL.K2','SP.URB.TOTL','SP.URB.TOTL.IN.ZS','SP.URB.GROW','NY.ADJ.SVNG.GN.ZS','NV.AGR.TOTL.ZS','EN.ATM.PM25.MC.M3','AG.LND.AGRI.K2','AG.LND.AGRI.ZS','AG.YLD.CREL.KG','VC.IDP.NWDS','EG.ELC.ACCS.ZS','DT.DOD.DECT.GN.ZS','NE.EXP.GNFS.ZS','SL.AGR.EMPL.ZS','AG.LND.FRST.K2','AG.LND.FRST.ZS','NY.GDP.FRST.RT.ZS','NV.AGR.TOTL.ZS','NW.NCA.PC','SH.STA.AIRP.P5','SH.STA.WASH.P5','SH.STA.BASS.ZS','VC.IHR.PSRC.P5','ER.H2O.INTR.PC','ER.H2O.FWST.ZS','SH.H2O.BASW.ZS')

# Importation and cleaning of each WDI indicator
for(i in ind){
  print(i)
  if (i == 'VC.IDP.NWDS'){
  wdi <- WDI(country = "all", indicator = i, start = 2000, end = NULL, extra = TRUE, cache = NULL)
  wdi <- na.omit(wdi)
  wdi <- wdi %>% group_by(iso2c) %>% summarize(VC.IDP.NWDS=sum(VC.IDP.NWDS),region=first(region),income=first(income),iso3=first(iso3c))
  wdi <- subset(wdi, select = -c(iso2c))
  assign(paste('wdi_',i,sep=''),wdi)
  } else {
  wdi <- WDI(country = "all", indicator = i, start = 2000, end = NULL, extra = TRUE, cache = NULL)
  wdi <- na.omit(wdi)
  wdi <- wdi %>% group_by(iso2c) %>% filter(year==max(year))
  wdi <- subset(wdi, select = -c(iso2c,year,capital,longitude,latitude,lending,country)) %>% rename(iso3=iso3c)
  assign(paste('wdi_',i,sep=''),wdi)
    }
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
defor <- subset(defor, select = c(V2,V12,V62)) %>% rename(country=V2,forest_1992=V12,forest_2017=V62)
defor2 <- left_join(defor,FAO_cc)
defor2 <- subset(defor2,select = -c(country))
# Correcting issues due to translation of variables
defor2[214, 3] = "GBR"
defor2[42, 3] = "CHN"
defor2[48, 3] = "CIV"
defor2$forest_loss <- with(defor2, (forest_2017-forest_1992)/forest_1992)


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

####################
## Climate Change ##
####################
biodiv <- read_excel("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Add_dim/dim_used/cleaned/biodiv_agg.xlsx")
biodiv <- biodiv %>% rename(iso3=cc)

###################
## Market access ##
###################
mark_acc <- read_excel("/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Add_dim/dim_used/cleaned/market_access.xlsx")
mark_acc <- mark_acc %>% rename(iso3=cc)

#____________#
#_ JOIN ALL _#
#____________#
wdi_SP.POP.TOTL <- wdi_SP.POP.TOTL[,c(2,3,4,1)] #Change order to get an inntegrated dataframe starting with string columns
ind2 <- list(wdi_SP.POP.TOTL,biodiv,wind,solar,defor2,coastline_table,trust_in_politicians,social_capital,
             wdi_AG.SRF.TOTL.K2,wdi_SP.URB.TOTL,wdi_SP.URB.TOTL.IN.ZS,wdi_SP.URB.GROW,wdi_NY.ADJ.SVNG.GN.ZS,
             wdi_EN.ATM.PM25.MC.M3,wdi_AG.LND.AGRI.K2,wdi_AG.LND.AGRI.ZS,wdi_AG.YLD.CREL.KG,wdi_VC.IDP.NWDS,wdi_EG.ELC.ACCS.ZS,
             wdi_DT.DOD.DECT.GN.ZS,wdi_NE.EXP.GNFS.ZS,wdi_SL.AGR.EMPL.ZS,wdi_AG.LND.FRST.K2,wdi_AG.LND.FRST.ZS,
             wdi_NY.GDP.FRST.RT.ZS,wdi_NV.AGR.TOTL.ZS,wdi_NW.NCA.PC,wdi_SH.STA.AIRP.P5,wdi_SH.STA.WASH.P5,wdi_SH.STA.BASS.ZS,
             wdi_VC.IHR.PSRC.P5,wdi_ER.H2O.INTR.PC,wdi_ER.H2O.FWST.ZS,wdi_SH.H2O.BASW.ZS,mark_acc)

integrated <- join_all(ind2, type = "left", match = "all")
# Forest cover per area and capita
integrated$forest_cover <- with(integrated, (forest_2017/AG.SRF.TOTL.K2))
integrated$forest_cover_pc <- with(integrated, (forest_2017/SP.POP.TOTL))

# Agriland per capita
integrated$agriland_pc <- with(integrated, (AG.LND.AGRI.K2/(SP.POP.TOTL/100)))

# Displacement per 1,000 inhabitants
integrated$VC.IDP.NWDS <- with(integrated,(VC.IDP.NWDS/(SP.POP.TOTL/1000)))

integrated[13, 3] = "Upper middle income" # Correct Argentina incomegroup
write.csv(integrated,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD.csv", row.names = FALSE)

#_____________________#
#_ RENAME INDICATORS _#
#_____________________#
# variables have to be renamed at a later stage within country dataframe because spaces are filled with points if done a this stage

#___________#
#_ RANKING _#
#___________#

# World
rank_f <- function(x, na.rm=FALSE) (rank(-x,na.last = "keep"))
neg_cols <- c('forest_loss')
integrated[neg_cols] <- integrated[neg_cols]*(-1)
integrated_rk <- integrated %>% mutate_if(is.double, rank_f)
write.csv(integrated_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_rk.csv", row.names = FALSE)

# High income
integrated_hinc <- integrated %>% filter(income=='High income')
integrated_hinc_rk <- integrated_hinc %>% mutate_if(is.double, rank_f)
write.csv(integrated_hinc_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_hinc_rk.csv", row.names = FALSE)

# Low income
integrated_linc <- integrated %>% filter(income=='Low income')
integrated_linc_rk <- integrated_linc %>% mutate_if(is.double, rank_f)
write.csv(integrated_linc_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_linc_rk.csv", row.names = FALSE)

# Upper MICS
integrated_umics <- integrated %>% filter(income=='Upper middle income')
integrated_umics_rk <- integrated_umics %>% mutate_if(is.double, rank_f)
write.csv(integrated_umics_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_umics_rk.csv", row.names = FALSE)

# Lower MICS
integrated_lmics <- integrated %>% filter(income=='Lower middle income')
integrated_lmics_rk <- integrated_lmics %>% mutate_if(is.double, rank_f)
write.csv(integrated_lmics_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_lmics_rk.csv", row.names = FALSE)

# MENA
integrated_MENA <- integrated %>% filter(region=='Middle East & North Africa')
integrated_MENA_rk <- integrated_MENA %>% mutate_if(is.double, rank_f)
write.csv(integrated_MENA_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_MENA_rk.csv", row.names = FALSE)

# LAC
integrated_LAC <- integrated %>% filter(region=='Latin America & Caribbean')
integrated_LAC_rk <- integrated_LAC %>% mutate_if(is.double, rank_f)
write.csv(integrated_LAC_rk,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_LAC_rk.csv", row.names = FALSE)

#_________#
#_ SCORE _#
#_________#
integrated_core <- integrated_rk[,c(1:3)]
fn <- function(x) (x-max(x,na.rm = TRUE))/(min(x,na.rm = TRUE) - max(x,na.rm = TRUE)) * 100 #na.rm = TRUE
fn(c(0,1,0))

# World
integrated_score <- data.frame(lapply(integrated_rk[,c(4:43)], fn))
integrated_score <- cbind(integrated_core,integrated_score)
write.csv(integrated_score,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_score.csv", row.names = FALSE)

# High income
integrated_hinc_core <- integrated_hinc_rk[,c(1:3)]
integrated_hinc_score <- data.frame(lapply(integrated_hinc_rk[,c(4:43)], fn))
integrated_hinc_score <- cbind(integrated_hinc_core,integrated_hinc_score)
write.csv(integrated_hinc_score,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_hinc_score.csv", row.names = FALSE)

# Low income
integrated_linc_core <- integrated_linc_rk[,c(1:3)]
integrated_linc_score <- data.frame(lapply(integrated_linc_rk[,c(4:43)], fn))
integrated_linc_score <- cbind(integrated_linc_core,integrated_linc_score)
write.csv(integrated_linc_score,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_linc_score.csv", row.names = FALSE)

# Upper MICS
integrated_umics_core <- integrated_umics_rk[,c(1:3)]
integrated_umics_score <- data.frame(lapply(integrated_umics_rk[,c(4:43)], fn))
integrated_umics_score <- cbind(integrated_umics_core,integrated_umics_score)
write.csv(integrated_umics_score,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_umics_score.csv", row.names = FALSE)

#LMICS
integrated_lmics_core <- integrated_lmics_rk[,c(1:3)]
integrated_lmics_score <- data.frame(lapply(integrated_lmics_rk[,c(4:43)], fn))
integrated_lmics_score <- cbind(integrated_lmics_core,integrated_lmics_score)
write.csv(integrated_lmics_score,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_lmics_score.csv", row.names = FALSE)

#MENA
integrated_MENA_core <- integrated_MENA_rk[,c(1:3)]
integrated_MENA_score <- data.frame(lapply(integrated_MENA_rk[,c(4:43)], fn))
integrated_MENA_score <- cbind(integrated_MENA_core,integrated_MENA_score)
write.csv(integrated_MENA_score,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_MENA_score.csv", row.names = FALSE)

#LAC
integrated_LAC_core <- integrated_LAC_rk[,c(1:3)]
integrated_LAC_score <- data.frame(lapply(integrated_LAC_rk[,c(4:43)], fn))
integrated_LAC_score <- cbind(integrated_LAC_core,integrated_LAC_score)
write.csv(integrated_LAC_score,"/Volumes/Elements/Documents/ArcGIS/LAC/Presentations_AW/Database/DB_SD_LAC_score.csv", row.names = FALSE)

#if making negative outcomes as negative
#neg_cols <- c('forest_loss','EN.ATM.PM25.MC.M3','VC.IDP.NWDS','DT.DOD.DECT.GN.ZS','SH.STA.AIRP.P5','SH.STA.WASH.P5','VC.IHR.PSRC.P5','ER.H2O.FWST.ZS')
#integrated_score[neg_cols] <- integrated_score[neg_cols]*(-1)