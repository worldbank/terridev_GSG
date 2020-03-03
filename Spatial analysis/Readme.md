# Spatial analysis

## Prerequisites
The following packages have to be installed before running the code:
BAMMtools, BBmisc, classInt, cowplot, data.table, doBy, foreign, ggplot2, mapproj, maptools, plyr, dplyr, raster, regeos, RColorBrewer,
rgdal, shapefiles, sp, stringr, tidyr, tidyverse, viridis, viridisLite, readstata13


## Objective
This code produces a lagginess index which classifies regions within countries from 0 to 100, 0 being the least disadvantaged area and 100 the
most disadvantaged area. This classification is based on the combination of three dimensions: poverty, economic activity and accessibility.


## Workflow
The code first gathers the data from three different sources:
- Poverty: HDD database
- Economic activity: VIIRS
- Accessibility: Author's calculation based on a gravity model to calculate access to cities (5km grid)

Then, it calcualtes the lagginess index by standardizing each variable and combining it in a single index going from 0 to 100.
The results for each dimension and the lagginess index are exported to maps. Finally, several statistics are computed, representing
the share of specific assets/dimensions located in disadvantaged areas (i.e. high environmental risk areas, high biodiversity areas).
