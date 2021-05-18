# SD Benchmark

## Prerequisites
The following packages have to be installed before running the code:
WDI, plyr, dplyr, rvest, readxl, tidyverse, data.table, ggplot2


## Step 1 - SD datasets

This code calls and gathers all the indicators necessary for the profiles and gathers them in different datasets for each income group with different files for inicator estimates, ranks and scores (necessary for the graphs).

The vast majority of indicators are downloaded from open libraries or through web-scraping.
However, 4 indicators could not be directly integrated (as they have to be extracted from files which are above 1Gb). For those inicators, the processed files, used as inputs in the code were uploaded to the "raw indicators folder". The indicators are the following:
  - solar_agg from the Solargis database
  - wind_agg from the Global Wind Atlas
  - Market access from Weiss et al. 2015
  - Biodiversity from the Terrestrial Biodiversity Indicators


## Step 2 - Country outputs

This code generates the graphs for each country.
Two variables have to be adjusted in the code (line 42-43):
1) The income group/region we select for cross-comparison:
  - linc: Low income countries
  - hinc: High Income countries
  - lmics: Low Middle Income countries
  - hmics: High Middle Income countries
  - MENA: Middle East and North Africa
  - LAC: Latin America and Carribean

2) The choice of the language for the outputs (line 49):
  - 0: english
  - 1: spanish
 
 Note: it is necessary to update the working directory and create the folder structure before running the code
