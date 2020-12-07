
# SD Benchmark - RISE FRAMEWORK 

## Step 1 - Create the world datasets with all the benchmarking variables -

This code calls and gathers all the indicators necessary for the benchmarking profiles and gathers them in different datasets:

 1) Indicators Raw values and Percentil ranking (variables with suffix "_per") - For global comparison
 2) Score dataset -  For comparison within income gruop (one file per income group)

The vast majority of indicators are downloaded from open libraries (WDI) or through web-scraping, sources and value of the indicators are explained in the code.
However, some indicators could not be directly integrated. As they are the result were part of calculations from the Chief Economist Office (Sustainable Development.
These files are store in the folder "Raw indicators", used as inputs in the code were uploaded to the "Raw indicators" folder.

The complete set of variables, code names and relation with each pillar and version, can be found in the file "Benchmarking Variables_V1205".


## Step 2 - Country outputs
This code is divided in two parts.

First part: It creates the aggregate score for each of the RISE pillars.
The composition of the pillars varies depending the version of the benchmarking selected

##v0 
Refers to a set of indicators selected and vetted by the Chief Economist Office -Sustainable Development (work lead by Jason Daniel Russ). 
This version is updated with the criteria from November 30, 2020

##v1
Refers to a set of indicators selected by the MENA - Sustainable Development team focusing on Egypt analysis  


Second part:  This code generates the following graphs and files for each country, depending on the version selected:

1) Percentil graph with all the indicators
2) Columns bar graph for comparison against countries from the reginal group (eg. MENA/LAC/ECA/SSA) and Columns bar graph for comparison against income groups
3) Individual graphs for each RISE pillar
4) CSV with values per country to integrate in the pdf presentation. It classifies the value of the country in 1 (worse performance)= country value below 1 SD (standard deviation) of the value of Income or aspirational group,
2= country value within 1 SD and 3 (better performance) = country value above 1 SD (standard deviation) of the value of Income or aspirational group

 Note: it is necessary to update the working directory and create the folder structure before running the code. Please make sure to load all the libraries before running the code
