global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

/*//1. Download data 

*dlw, coun(COL) y(2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(ALL) 
*save "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_1.dta" //too big

dlw, coun(COL) y(2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(LAB) sur(GEIH)

save "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_LAB.dta"

dlw, coun(COL) y(2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(HHD) 
save "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_HHD.dta"

dlw, coun(COL) y(2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(IND) 
save "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_IND.dta", replace

dlw, coun(COL) y(2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(POV) 
save "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_POV.dta"

dlw, coun(COL) y(2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(REG) 
save "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_REG.dta"

use "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_REG.dta"

	merge 1:1 year id using "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_HHD", nogen
	merge 1:m year id using "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_IND", nogen
	merge 1:1 year id com using "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_LAB", nogen
	merge 1:1 year id com using "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC_POV", nogen

save "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLACall.dta", replace

*/

// 2. Set up analysis 

// Colombia
use "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLACall.dta", clear
append using  "$user/_OaxacaBlinder_replication/SEDLAC/COL/COL_SEDLAC0105", force


gen countrycode = upper(pais)
rename encuesta survey  

tab year
*keep if year == 2019
*keep if relacion == 1

	*encode region_est1, gen(region) // regions
	encode region_est2, gen(dep) // departments
	encode region_est3, gen(dist) // district

split region_est2, parse(" - ")

tab year region_est2 
	
** Incomes 
		
sum ila // total labor inide (individual)
sum ilpc // per capita labor income ** (based on hh)
sum ii // individual total income
sum ipcf

* prices 
	
// for international comparison	
	
gen ipcc_11 =   ipc11_sedlac
gen ipcc_05  =  ipc05_sedlac
gen ppp_05  =  ppp05
gen ppp_11  =  ppp11

tab year, sum(ipc_sedlac) // for time comparison

drop _merge 

merge m:1 countrycode year using "$user/_OaxacaBlinder_replication/cleaning/CEPALdef" 

keep if _merge == 3
drop _merge

** correct income before deflating properly

foreach inc in ila ilpc ii ipcf{
	replace `inc' = `inc'*0.8695 if urbano == 0
	replace `inc' = `inc'/def if urbano == 0 
}

// household labor income 
	gen  hh_labinc_pc_11 = ilpc/(ipc_sedlac/ipcc_11)
	gen  hh_labinc_pc_ppp11 = hh_labinc_pc_11/ppp_11

	// household total inc 

	gen  hh_totinc_pc_11 = ipcf/(ipc_sedlac/ipcc_11)
	gen  hh_totinc_pc_ppp11 = (hh_totinc_pc_11)/ppp_11
	
// individual labor income 
	gen  ind_labinc_11 = ila/(ipc_sedlac/ipcc_11)
	gen  ind_labinc_ppp11 = ind_labinc_11/ppp_11

	gen lind_labinc_ppp11 = log(ind_labinc_ppp11)
	gen  lhh_labinc_pc_ppp11 = log(hh_labinc_pc_ppp11)
	gen lhh_totinc_pc_ppp11 = log(hh_totinc_pc_ppp11)
	
** determining leading region 	
*collapse (mean) ilpc,  by(year region dep dist urbano) 


	gen leading1 = 0
	replace leading1 = 1 if (dep == 3 & urbano == 1) // only Bogota urban
	
	gen leading2 = 0
	replace leading2 = 1 if (dep == 3 | dep == 1 | dep == 24 ) & urbano == 1 // adding urban valle and antioquia to include Medellin and Cali (as check)
	
	gen geo3 = real(substr(region_est3,1,5))

	gen metro = 0
	replace metro = 1 if geo3 ==  76001 | geo3 ==  11001 | geo3 ==  5001
	
	gen leading3 = 0
	replace leading3 = 1 if metro == 1 // Bogota, Medellin and Cali 
	
	tab leading1 metro
	
	tab region_est3 if metro == 1

	gen noleading1 = leading1
	gen noleading2 = leading2
	gen noleading3 = leading3

	recode noleading1 (0 = 1)(1 = 0)
	recode noleading2 (0 = 1)(1 = 0)	
	recode noleading3 (0 = 1)(1 = 0)	

	
** Bottom 40%

	forvalue year=2001/2020{
	_pctile hh_totinc_pc_ppp11 [aweight=pondera] if year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	forvalue year=2001/2020{
	replace b40 = b40_`year' if year == `year'
	}
	
	drop b40_*
	
	gen b40d = 0
	replace b40d = 1 if hh_totinc_pc_ppp11 < b40

** skilled 
gen skilled=(nivel>=5)    

** Urban/Rural 
sum urbano

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
gen   empstat=.  
replace  empstat=1  if  ocupado==1
replace  empstat=2  if  desocupa==1
replace  empstat=3  if  pea==0

tab relab // type of occupation 

// utilities 
rename  agua hh_piped_to_prem
rename elect hh_elect 
rename   cloacas hh_sewage
rename   banio hh_toilet

	
	gen period = .
	replace period = 1 if year <= 2003
	*replace period = 2 if year >= 2005 & year < 2010
	*replace period = 3 if year >= 2010 & year < 2015
	replace period = 4 if year >= 2017
	
tab leading1

	
	replace cohi = 1
	replace casado = 0
	replace pondera_i = pondera
	 	
	tab year leading1 [w=pondera]
	tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq // check leading region observation 
	
	encode region_est22, gen(adm)
	
	
	label define adm 2 "Atlántico", modify
	label define adm 3 "Bogotá", modify
	label define adm 4 "Bolívar", modify
	label define adm 5 "Boyacá", modify
	label define adm 7 "Caquetá", modify
	label define adm 10 "Chocá", modify
	label define adm 12 "Córdoba", modify
	label define adm 17 "Nariño", modify
	label define adm 19 "Quindáo", modify

	decode adm, gen(adm1)

	replace hh_piped_to_prem = 0 if hh_piped_to_prem == .
	replace hh_elect = 0 if hh_elect == .
	replace hh_sewage = 0 if hh_sewage == .
	replace hh_toilet = 0 if hh_toilet == .

			keep id com urbano region* geo* jefe year period leading* noleading* lind* lhh* ind_* hh_* ila ilpc ii ipcf  b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* hh_piped_to_prem hh_elect hh_sewage hh_toilet  def adm1 
		
	
save "$user/_OaxacaBlinder_replication/inputs/COL_SEDLACsmall.dta", replace


