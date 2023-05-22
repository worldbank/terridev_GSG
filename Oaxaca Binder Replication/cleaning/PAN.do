global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

/*
dlw, coun(PAN) y(1995 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(ALL)  sur(EH) 
save "$user/_OaxacaBlinder_replication/SEDLAC/PAN/PAN_SEDLAC.dta", replace

dlw, coun(PAN) y(2007 2008 2014) t(SEDLAC-03) mod(ALL)  sur(EH) 
save "$user/_OaxacaBlinder_replication/SEDLAC/PAN/PAN_SEDLAC070814.dta", replace


*/

*************

use "$user/_OaxacaBlinder_replication/SEDLAC/PAN/PAN_SEDLAC.dta", clear
drop if year < 2000
append using "$user/_OaxacaBlinder_replication/SEDLAC/PAN/PAN_SEDLAC070814", force

append using "$user/_OaxacaBlinder_replication/SEDLAC/PAN/PAN_SEDLAC_2010", force
append using "$user/_OaxacaBlinder_replication/SEDLAC/PAN/PAN_SEDLAC_2012", force

**# Bookmark #1
gen countrycode = upper(pais)
rename encuesta survey  

tab year

tab region_est1 // region
tab region_est2 // state

split region_est2, parse(" - ")
	
	gen adm1 = region_est22
			replace adm1 = "Panama" if adm1 == "Panama-Oeste"		

drop prov
gen prov = real(region_est21) 
						
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

merge m:1 countrycode year using "$user/_OaxacaBlinder_replication/cleaning/CEPALdef" 
keep if _merge == 3
drop _merge

** correct income before deflating properly

foreach inc in ila ilf ilpc ii ipcf_sr itf{
	replace `inc' = `inc'*p_reg if urbano == 0
	replace `inc' = `inc'/def if urbano == 0 
}


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
	
		tab region_est22 [w=pondera_i] if cohi == 1 & year == 2019, sum(hh_totinc_pc_ppp11)

		tab prov region_est22

		tab prov year
		
	gen leading1 = 0
		replace leading1 = 1 if (prov == 8 | prov == 13) & urbano == 1 // only urban in old Panama province (panama and panama oeste)
	
	*gen leading2 = 0
	*replace leading2 = 1 if (leading1 == 1 | metro == 1) & urbano == 1
	
	gen noleading1 = leading1
	*gen noleading2 = leading2
	
	recode noleading1 (0 = 1)(1 = 0)
	*recode noleading2 (0 = 1)(1 = 0)	
	
	
** Bottom 40%

	foreach year in  2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 {
	_pctile hh_totinc_pc_ppp11 [aweight=pondera_i] if cohi ==1 & year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019{
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
*egen hh_elect = mean(elect), by(id)  
egen  hh_sewage = mean(cloacas), by(year id) 
egen  hh_toilet = mean(banio), by(year  id) 
egen hh_piped_to_prem = mean(agua), by(year id) 
egen hh_elect = mean(elect), by(id year)  

	
	tab year
	
	gen period = .
	replace period = 1 if year >= 2001 & year <= 2003
	*replace period = 2 if year >= 2005 & year <= 2009
	*replace period = 3 if year >= 2010 & year <= 2014
	replace period = 4 if year >= 2017 & year <= 2019
	
	tab year period


	tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq
	
		keep id com urbano region* prov year period leading* noleading* lind* lhh* ind_* hh_* ila ilf ilpc ii ipcf_sr itf p_reg b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* hh_piped_to_prem hh_elect hh_sewage hh_toilet lp_moderada def adm1 jefe
		
		// no access to serv in survey
		replace hh_piped_to_prem = 0
		replace hh_elect = 0
		replace hh_sewage = 0
		replace hh_toilet = 0
		
		tab adm1
		
		tab year [w=pondera_i] if cohi == 1, sum(lind_labinc_ppp11) //check

		
save "$user/_OaxacaBlinder_replication/inputs/PAN_SEDLACsmall.dta", replace
