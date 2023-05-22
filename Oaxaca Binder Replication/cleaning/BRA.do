global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"
/*
use ""$user/_OaxacaBlinder_replication/SEDLAC/BRA/BRA_SEDLAC_PNAD.dta", clear
	drop  v2* v3* v5* v6* v7* v8* v9*
	
	append using "$user/_OaxacaBlinder_replication/SEDLAC/BRA/BRA_SEDLAC_PNADC"
	drop v0*
	drop  v2* v3*  v5* 

save "$user/_OaxacaBlinder_replication/SEDLAC/BRA/BRA_SEDLACall.dta", replace
	*/
//

use "$user/_OaxacaBlinder_replication/SEDLAC/BRA/BRA_SEDLACall.dta", clear
drop if year < 2012 // comparing PNADC only

gen countrycode = upper(pais)
rename encuesta survey  

** household 

drop if  relacion==6

**   Geography 

*gen  geo_level1 = real(substr(region_est1,1,1))   
gen  geo_level2 = real(substr(region_est2,1,2))   
*gen  geo_level3 = .


split region_est2, parse(" - ")

gen adm1 = region_est22
tab adm1

*encode region_est2, gen(state)

*gen   geo_l1  =  geo_level2 

gen  metro=(v1023==1) if year >= 2012 /* v1023 == 1 is capital, 2 for resto metro, for previous years use  v4107 is the variable that id Metro */
*replace metro=(v4107==1) if year < 2012

gen  metroall=(v1023==1 | v1023 == 2) if year >= 2012 /* v1023 == 1 is capital, 2 for resto metro, for previous years use  v4107 is the variable that id Metro */
replace metroall=metro if year < 2012

gen metro2=(rm_ride~=. & rm_ride~=22)
replace metro2=1 if geo_level2==53


tab year metro // comparison is proportion of people 
tab year metroall // comparison is proportion of people 


gen       urban_metro =.
replace   urban_metro = 1  if  urbano==1 &  metro==1
replace   urban_metro = 2  if  urbano==1 &  metro==0
replace   urban_metro = 3  if  urbano==0 &  metro==1
replace   urban_metro = 3  if  urbano==0 &  metro==0

*gen    urb_metro=(urban_metro==1 &   urban_metro~=.)
*gen    urb_nometro=(urban_metro==2 &   urban_metro~=.)
*gen    rur =(urban_metro==3 &   urban_metro~=.) 

***  define  metro (Rio, Sao Paolo,  Belo Horizonte)

gen  leading1=(metro==1  & (geo_level2==33  | geo_level2==35 |  geo_level2==31 ))
gen  noleading1 =(leading1==0)   

gen  leading2=(metroall==1  & (geo_level2==33  | geo_level2==35 |  geo_level2==31 ))
gen  noleading2 =(leading2==0)   

gen  leading3=(metro2==1  & (geo_level2==33  | geo_level2==35 |  geo_level2==31 ))
gen  noleading3 =(leading3==0)   



** Incomes 
		
sum ila // total labor inide (individual)
sum ilf // household labor income ** 
sum ilpc // per capita labor income ** (based on hh)

sum ii // individual total income
sum ipcf_sr // household total income (without rent) - pov equivalent
sum itf // household total income 

** correct income before deflating 

foreach inc in ila ilf ilpc ii ipcf_sr itf{
	replace `inc' = `inc'*p_reg if urbano == 0
}

** prices 
	
// for international comparison	
	
gen ipcc_11 =   ipc11_sedlac
gen ipcc_05  =  ipc05_sedlac
gen ppp_05  =  ppp05
gen ppp_11  =  ppp11

tab year, sum(ipc_sedlac) // for time comparison

merge m:1 geo_level2  year  urban_metro  using   "$user/_OaxacaBlinder_replication/cleaning/BRA_spdef.dta"
keep if  _merge==3

// household labor income 
	gen  hh_labinc_pc_11 = ilpc/(ipc_sedlac/ipcc_11)
	gen  hh_labinc_pc_ppp11 = (hh_labinc_pc_11/defla_ibge_11_pline)/ppp_11

	
// individual labor income 
	gen  ind_labinc_11 = ila/(ipc_sedlac/ipcc_11)
	gen  ind_labinc_ppp11 = (ind_labinc_11/defla_ibge_11_pline)/ppp_11
	
// household total inc 

	gen  hh_totinc_pc_11 = ipcf_sr/(ipc_sedlac/ipcc_11)
	gen  hh_totinc_pc_ppp11 = (hh_totinc_pc_11/defla_ibge_11_pline)/ppp_11
	
// individual total income 

	gen  ind_totinc_11 = ii/(ipc_sedlac/ipcc_11)
	gen  ind_totinc_ppp11 = (ind_totinc_11/defla_ibge_11_pline)/ppp_11

// 	logs
	gen lind_labinc_ppp11 = log(ind_labinc_ppp11)
	gen lhh_labinc_pc_ppp11 = log(hh_labinc_pc_ppp11)
	gen lhh_totinc_pc_ppp11 = log(hh_totinc_pc_ppp11)
	gen lind_totinc_11 = log(ind_totinc_ppp11)	
	
** Bottom 40%

*tab year

	forvalue year=2012/2020{
	_pctile hh_totinc_pc_ppp11 [aweight=pondera] if year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	forvalue year=2012/2020{
	replace b40 = b40_`year' if year == `year'
	}
	
	drop b40_*
	
	gen b40d = 0
	replace b40d = 1 if hh_totinc_pc_ppp11 < b40
	

** skilled 
gen skilled=(nivel>=5)    

** Urban/Rural 
sum urbano

** Demographics

// gender
gen gender = hombre 

gen  age =  edad
gen  agesq = age^2 

// family size and age idposition
bysort year id: egen  hhsize = count(id)
*reg miembros hhsize

egen  hh_s_02 = count(id)  if age<=2 & age~=. , by(id year) 
egen  hh_size_02 = mean(hh_s_02), by(id year) 
replace  hh_size_02=0 if  hh_size_02==.
gen   hh_size_02_sq = hh_size_02^2
drop  hh_s_02

egen  hh_s_311 = count(id)  if age>2 &  age<=11  & age~=., by(id year) 
egen  hh_size_311 = mean(hh_s_311)   , by(id year) 
replace  hh_size_311=0 if  hh_size_311==.
gen   hh_size_311_sq = hh_size_311^2
drop  hh_s_311

egen  hh_s_1217 = count(id)  if age>11 &  age<=17 & age~=., by(id year) 
egen  hh_size_1217 = mean(hh_s_1217)   , by(id year) 
replace  hh_size_1217=0 if  hh_size_1217==.
gen   hh_size_1217_sq = hh_size_1217^2
drop  hh_s_1217

egen  hh_s_1859 = count(id)  if age>17 &  age<=59 & age~=., by(id year) 
egen  hh_size_1859 = mean(hh_s_1859 )   , by(id year) 
replace  hh_size_1859=0 if  hh_size_1859==.
gen   hh_size_1859_sq = hh_size_1859^2
drop  hh_s_1859

egen  hh_s_60 = count(id)  if age>59  & age~=. , by(id year) 
egen  hh_size_60 = mean(hh_s_60 )   , by(id year) 
replace  hh_size_60=0 if  hh_size_60==.
gen   hh_size_60_sq = hh_size_60^2
drop  hh_s_60
 	
	
// ethnicity 
*tab raza
*ab raza_est 

// Female had 
gen   hh_fhead= .
replace hh_fhead = 1 if relacion==1  & gender==0
replace hh_fhead = 0 if relacion!=1  | gender==1
	
// education 

gen edattain = 1        if  nivel==0  | nivel==1
replace  edattain = 2   if  nivel==2  | nivel==3
replace  edattain = 3   if  nivel==4  | nivel==5
replace  edattain = 4   if  nivel==6

gen   hh_head_ed  = edattain       if edattain~=.  &  relacion==1   
egen  hh_head_edattain = mean(hh_head_ed), by(id year) 
drop hh_head_ed

	
egen  hh_max_ed = max(edattain) if  edattain~=.  & (relacion>= 2) , by(id year) 
egen  hh_max_edattain = mean(hh_max_ed), by(id year) 
drop hh_max_ed


// employment
sum ocupado
sum pea

tab pea ocupado

tab relab // type of occupation 

gen   empstat=.  
replace  empstat=1  if  ocupado==1
replace  empstat=2  if  desocupa==1
replace  empstat=3  if  pea==0


* utilities 
egen  hh_sewage = mean(cloacas), by(year id) 
egen  hh_toilet = mean(banio), by(year  id) 
egen hh_piped_to_prem = mean(agua), by(year id) 
egen hh_elect = mean(elect), by(id year)  

// some survey dont have utilities 

		replace hh_piped_to_prem = 0
		replace hh_elect = 0
		replace hh_sewage = 0
		replace hh_toilet = 0 
	

	gen period = .

	replace period = 1 if year >= 2012 & year <= 2014
	*replace period = 2 if year >= 2014 & year <= 2015
	*replace period = 3 if year >= 2016 & year <= 2017
	replace period = 4 if year >= 2017 & year <= 2019
	
	tab year period

keep id com urbano region* jefe state metro* year period* leading* noleading* urban_metro* geo_level* urb* lind* lhh* ind_* hh_* ila ilf ilpc ii ipcf_sr itf p_reg b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* lp_moderada adm1 raza*

	
	tab year leading1 [w=pondera]
	tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq
	
	replace casado = 0

save "$user/_OaxacaBlinder_replication/inputs/BRA_SEDLACsmall.dta", replace
 
