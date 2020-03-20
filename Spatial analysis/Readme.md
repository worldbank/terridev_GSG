# Spatial analysis

## Prerequisites
The following packages have to be installed before running the code:
BAMMtools, BBmisc, classInt, cowplot, data.table, doBy, foreign, ggplot2, mapproj, maptools, plyr, dplyr, raster, regeos, RColorBrewer, rgdal, shapefiles, sp, stringr, tidyr, tidyverse, viridis, viridisLite, readstata13

## Objective
This code produces a lagginess index which classifies regions within countries from 0 to 100, 0 being the least disadvantaged area and 100 the most disadvantaged area. This classification is based on the combination of three dimensions: poverty, economic activity and accessibility.

## Workflow
First step:The first code estimates accessibility at a subnational level based on a gravity model to calculate access to cities (5km grid). Raster files with accessibility values are available for all countries in Latin America.

Second Step: The Lagginess Index code gathers the data from three different sources:
 - Poverty: HDD database
 - Economic activity: Nightlight activity (VIIRS, 2016), 
 - Accessibility: Author's calculation based on a gravity model to calculate access to cities (5km grid)(estimated in the 
   First Step).

Then, it calculates the lagginess index by standardizing each variable and combining it in a single index going from 0 to 100. The areas with an index value on the top 40% percentile are then classified as Lagginess Areas.The results for each dimension and the lagginess index scores are exported to maps. Finally, several statistics are computed, representing the share of specific assets/dimensions located in disadvantaged areas, previously calculated (i.e., natural resources, population, and disaster risk).

## Additional codes:

 - Map of risk distribution: Build a map of risk distribution
 - Biodiversity calculation: estimation of the share of biodiversity (>450 species) at the subnational level.





