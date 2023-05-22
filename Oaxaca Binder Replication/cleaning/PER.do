global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

/*//1. Download data 

dlw, coun(PER) y(1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(ALL) sur(ENAHO)
save "$user/_OaxacaBlinder_replication/SEDLAC/PER/PER_SEDLACall.dta"

*/

// 2. Set up analysis 

// Peru 

use "$user/_OaxacaBlinder_replication/SEDLAC/PER/PER_SEDLACall.dta", clear
drop if year < 2000

gen countrycode = upper(pais)
rename encuesta survey  

tab year
*keep if year == 2019
*keep if relacion == 1

	encode region_est1, gen(region) // regions
	encode region_est2, gen(prov) // provinces
	
	gen leading1 = 0
	replace leading1 = 1 if (lima == 1 & urbano == 1) // only Lima urban
	
	gen leading2 = 0
	replace leading2 = 1 if (lima == 1 & urbano == 1) | costaur == 1 // lima urban and coast urban
	
	gen leading3 = 0
	replace leading3 = 1 if (lima == 1 & urbano == 0) | costarur == 1 // rural lima and rural coast 
	
	gen leading4 = 0
	replace leading4 = 1 if (lima == 1 & urbano == 1) | costarur == 1 // lima urban and rural coast 

	gen noleading1 = leading1
	gen noleading2 = leading2
	gen noleading3 = leading3
	gen noleading4 = leading4
	recode noleading1 (0 = 1)(1 = 0)
	recode noleading2 (0 = 1)(1 = 0)	
	recode noleading3 (0 = 1)(1 = 0)	
	recode noleading4 (0 = 1)(1 = 0)	
	

** Incomes 
		
sum ila // total labor inide (individual)
sum ilf // household labor income ** 
sum ilpc // per capita labor income ** (based on hh)

sum ii // individual total income
sum ipcf_sr // household total income (without rent) - pov equivalent
sum itf // household total income 

	* prices 
	
// for international comparison	
	
gen ipcc_11 =   ipc11_sedlac
gen ipcc_05  =  ipc05_sedlac
gen ppp_05  =  ppp05
gen ppp_11  =  ppp11

tab year, sum(ipc_sedlac) // for time comparison

// household labor income 
	gen  hh_labinc_pc_11 = ilpc/(ipc_sedlac/ipcc_11)
	gen  hh_labinc_pc_ppp11 = hh_labinc_pc_11/ppp_11

// individual labor income 
	gen  ind_labinc_11 = ila/(ipc_sedlac/ipcc_11)
	gen  ind_labinc_ppp11 = ind_labinc_11/ppp_11
	
	gen  hh_totinc_pc_11 = ipcf_sr/(ipc_sedlac/ipcc_11)
	gen  hh_totinc_pc_ppp11 = (hh_totinc_pc_11)/ppp_11
	
	gen lind_labinc_ppp11 = log(ind_labinc_ppp11)
	gen  lhh_labinc_pc_ppp11 = log(hh_labinc_pc_ppp11)
	
		
	tab year [w=pondera_i] if cohi == 1, sum(lind_labinc_ppp11)

	
** Bottom 40%

	forvalue year=1997/2019{
	_pctile hh_totinc_pc_ppp11 [aweight=pondera_i] if year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	forvalue year=1997/2019{
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
 	
// ethnicity 
tab raza
tab raza_est 
tab lengua


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

*gen   hh_sp_ed  = edattain       if edattain~=.  &  relacion==2
*egen  hh_sp_edattain = mean(hh_sp_ed)    , by(id year) 
	
egen  hh_max_ed = max(edattain) if  edattain~=.  & (relacion>= 2) , by(id year) 
egen  hh_max_edattain = mean(hh_max_ed), by(id year) 
drop hh_max_ed

*gen   hh_edu_diff= hh_max_edu_edattain  if    hh_max_edu_edattain > hh_head_edattain   &  hh_max_edu_edattain >  hh_sp_edattain 	

// employment
sum ocupado
sum pea

tab pea ocupado

tab relab // type of occupation 

gen   empstat=.  
replace  empstat=1  if  ocupado==1
replace  empstat=2  if  desocupa==1
*replace  empstat=3  if  pea==0

// utilities 
rename piped_to_prem hh_piped_to_prem // agua is only at head level	
egen hh_elect = mean(elect), by(id year)  // elect is only at head level 
*sum imp_san_rec // improved sanitation

egen  hh_sewage = mean(cloacas), by(id year) 
egen  hh_toilet = mean(banio), by(id year) 

	
	tab year
	
	gen period = .
	replace period = 1 if year < = 2003
	*replace period = 2 if year >= 2005 & year < 2010
	*replace period = 3 if year >= 2010 & year < 2015
	replace period = 4 if year >= 2017
	
		
	tab year 
	
	split region_est2, parse(" - ")
	gen adm1 = region_est22

	
	keep id com urbano reg* prov year period leading* noleading* lind* lhh* ind_* hh_* ila ilf ilpc ii ipcf_sr itf p_reg b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* hh_piped_to_prem hh_elect hh_sewage hh_toilet lp_moderada adm1 jefe
	
	
	tab year leading1 [w=pondera]
	tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq

	gen province = real(region_est21)

save "$user/_OaxacaBlinder_replication/inputs/PER_SEDLACsmall.dta", replace
	
