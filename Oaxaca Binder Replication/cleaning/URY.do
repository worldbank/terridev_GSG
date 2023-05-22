global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

*dlw, coun(URY) y(1992 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020) t(SEDLAC-03) mod(ALL)  sur(ECH) 
*save $user/_OaxacaBlinder_replication/SEDLAC/URY/URY_SEDLAC.dta"

*drop if year < 2000

/*

drop d1*	d2*	d3*	d4*
drop e1*	e2*	e3*	e4* e5*
drop f1*	f2*	f3*	f4* f6* f7* f8* f9* 
*drop g1*	g2*	g3*	g4* g_id*
*drop h1*	h2*	

*save $user/_OaxacaBlinder_replication/SEDLAC/URY/URY_SEDLAC.dta", replace
*/


use "$user/_OaxacaBlinder_replication/SEDLAC/URY/URY_SEDLAC.dta", clear
append using "$user/_OaxacaBlinder_replication/SEDLAC/URY/URY_SEDLACall_02", force

drop if year == 2020
tab year, sum(urbano)

drop if urbano == 0 // only urban before 2007, for comparison


gen countrycode = upper(pais)
rename encuesta survey  

tab year


*tab region_est1 // region
tab region_est2 // département

split region_est2, parse(" - ")
gen dept = real(region_est21) 
gen adm1 = region_est22

tab dept
*tab region_est2
			
** Incomes   
sum ila // total labor inide (individual)
sum ilpc // per capita labor income ** (based on hh)
sum ii // individual total income

// for international comparison	
	
gen ipcc_11 =   ipc11_sedlac
gen ipcc_05  =  ipc05_sedlac
gen ppp_05  =  ppp05
gen ppp_11  =  ppp11

tab year, sum(ipc_sedlac) // for time comparison

tab dept urbano

	gen leading1 = 0
		replace leading1 = 1 if dept == 1 // only Montevideo 
	
	gen noleading1 = leading1
	
	recode noleading1 (0 = 1)(1 = 0)

tab year dept 
tab dept leading1 	

tab leading1 urbano 

tab year, sum(urbano)
 
** no price adjustment applied 
	
// household labor income 
	gen  hh_labinc_pc_11 = ilpc/(ipc_sedlac/ipcc_11)
	gen  hh_labinc_pc_ppp11 = (hh_labinc_pc_11)/ppp_11

	
// individual labor income 
	gen  ind_labinc_11 = ila/(ipc_sedlac/ipcc_11)
	gen  ind_labinc_ppp11 = (ind_labinc_11)/ppp_11
	
// household total inc 

	gen  hh_totinc_pc_11 = ipcf_sr/(ipc_sedlac/ipcc_11)
	gen  hh_totinc_pc_ppp11 = (hh_totinc_pc_11)/ppp_11
	
// individual total income 

	gen  ind_totinc_11 = ii/(ipc_sedlac/ipcc_11)
	gen  ind_totinc_ppp11 = (ind_totinc_11)/ppp_11

// 	logs
	gen lind_labinc_ppp11 = log(ind_labinc_ppp11)
	gen lhh_labinc_pc_ppp11 = log(hh_labinc_pc_ppp11)
	gen lhh_totinc_pc_ppp11 = log(hh_totinc_pc_ppp11)
	gen lind_totinc_11 = log(ind_totinc_ppp11)	
	
	*	tab dept [w=pondera_i] if cohi == 1 & year == 2020, sum(hh_totinc_pc_ppp11)

	
** Bottom 40%

	forvalues year = 2000 /2020 {
	_pctile hh_totinc_pc_ppp11 [aweight=pondera_i] if cohi ==1 & year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	
	forvalues year = 2000 /2020 {
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

// age
gen  age =  edad
gen  agesq = age^2 

// family size and age idposition
bysort year id: egen  hhsize = count(id)
reg miembros hhsize

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

count

tab agua
tab cloacas
tab banio 

// utilities 
egen  hh_sewage = mean(cloacas), by(year id) 
egen  hh_toilet = mean(banio), by(year  id) 
egen hh_piped_to_prem = mean(agua), by(year id) 
egen hh_elect = mean(elect), by(id year)  

	
	tab year
	
	gen period = .
	replace period = 1 if year <= 2002
*	replace period = 2 if year >= 2005 & year < 2010
*	replace period = 3 if year >= 2010 & year < 2015
	replace period = 4 if year >= 2017 

	tab year period
			
		keep id com urbano region* dept year period leading* noleading* lind* lhh* ind_* hh_* ila ilf ilpc ii ipcf_sr itf p_reg b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* hh_piped_to_prem hh_elect hh_sewage hh_toilet lp_moderada  jefe adm1  

		tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq

save "$user/_OaxacaBlinder_replication/inputs/URY_SEDLACsmall.dta", replace

