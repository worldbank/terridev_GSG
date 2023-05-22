global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

/* 
// Download data
dlw, coun(ARG) y(2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2015 2016 2017 2018 2019) t(SEDLAC-03) mod(ALL) sur(EPHC) per(S2)
save "$user/_OaxacaBlinder_replication/SEDLAC/ARG/ARG_SEDLACall.dta", replace

*/

**********************************************************************************
use "$user/_OaxacaBlinder_replication/SEDLAC/ARG/ARG_SEDLACall.dta", clear

gen countrycode = upper(pais)
rename encuesta survey  

tab year

tab region_est1 // region
tab region_est2 // state

split region_est2, parse(" - ")
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

gen   pl_ll =  lp_moderada   if   prov==32       /*  poverty line from Buenos Aires  */
egen   pl_lead = max(pl_ll) , by(year)     

gen    adj_urb =  lp_moderada/pl_lead       /* index to adjusted  */

foreach inc in ila ilf ilpc ii ipcf_sr itf{
replace   `inc'   =    `inc'  * p_reg    /*   remove sedlac adjustment  (no neded reely in this case since p_reg=1    */
replace   `inc'   =   `inc'  /  adj_urb     /*  adjusting  */

	}

// household labor income 
	gen  hh_labinc_pc_11 = ilpc/(ipc_sedlac/ipcc_11)
	gen  hh_labinc_pc_ppp11 = hh_labinc_pc_11/ppp_11

	
// individual labor income 
	gen  ind_labinc_11 = ila/(ipc_sedlac/ipcc_11)
	gen  ind_labinc_ppp11 = ind_labinc_11/ppp_11
	
// household total inc 

	gen  hh_totinc_pc_11 = ipcf_sr/(ipc_sedlac/ipcc_11)
	gen  hh_totinc_pc_ppp11 = hh_totinc_pc_11/ppp_11
	
// individual total income 

	gen  ind_totinc_11 = ii/(ipc_sedlac/ipcc_11)
	gen  ind_totinc_ppp11 = ind_totinc_11/ppp_11

// 	logs
	gen lind_labinc_ppp11 = log(ind_labinc_ppp11)
	gen lhh_labinc_pc_ppp11 = log(hh_labinc_pc_ppp11)
	gen lhh_totinc_pc_ppp11 = log(hh_totinc_pc_ppp11)
	gen lind_totinc_11 = log(ind_totinc_ppp11)	
	
		tab region_est22 [w=pondera_i] if cohi == 1 & year == 2019, sum(hh_totinc_pc_ppp11)

	gen leading1 = 0
	replace leading1 = 1 if prov == 32 // only City of BA
	
	*gen leading2 = 0
	*replace leading2 = 1 if (leading1 == 1 | metro == 1) & urbano == 1
	
	gen noleading1 = leading1
	*gen noleading2 = leading2
	
	recode noleading1 (0 = 1)(1 = 0)
	*recode noleading2 (0 = 1)(1 = 0)	
	
	tab year leading1 [w=pondera]
	tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq
	
** Bottom 40%

			forvalue year=2000/2019{
			_pctile hh_totinc_pc_ppp11 [aweight=pondera] if year == `year', p(40) 
			return list
			gen b40_`year' = r(r1)
			}
			
			gen b40 = .
			forvalue year=2000/2019{
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
egen hh_piped_to_prem = mean(agua), by(year id) // water

		
	tab year
	
	gen period = .
	replace period = 1 if year <= 2005
	replace period = 4 if year >= 2017 & year <= 2019
	
	tab year period
	
	gen adm1 = region_est22 
	
keep id com urbano region* year period leading* noleading* lind* lhh* ind_* hh_* ila ilf ilpc ii ipcf_sr itf p_reg b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* hh_piped_to_prem hh_sewage hh_toilet lp_moderada adm1 jefe
		
	tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq
	tab year period [w=pondera_i]

		
save "$user/_OaxacaBlinder_replication/inputs/ARG_SEDLACsmall.dta", replace
			