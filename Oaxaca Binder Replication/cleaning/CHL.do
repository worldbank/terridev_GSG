global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

use "$user/_OaxacaBlinder_replication/SEDLAC/CHL/CHL_SEDLACall_0015.dta", clear

// harmonizing regions across years 
gen region_est3_00 = region_est3 if year == 2000
gen region_est3_03 = region_est3 if year == 2003
gen region_est3_15 = region_est3 if year == 2015

drop region_est3

append using "$user/_OaxacaBlinder_replication/SEDLAC/CHL/CHL_SEDLACall_17.dta", force

*drop if year < 2009 // 
*drop if year == 2020

gen region_est3_17 = region_est3 if year == 2017
split region_est3_17, parse(" - ")

gen region_est3_17n = real(region_est3_171)
			
drop region_est3_17 
rename region_est3_17n	region_est3_17		

gen countrycode = upper(pais)
rename encuesta survey  

tab year

*tab region_est1 // region
*tab region_est2 // state

*tab region_est2 year
*tab region_est2_prev year
*tab region year

*tab year

label list region

*split region_est1, parse(" - ")
*gen reg = real(region_est11) 

*tab reg if region == 13



** Incomes 
		
sum ila // total labor inide (individual)
sum ilpc // per capita labor income ** (based on hh)
sum ii // individual total income

// for international comparison	
	
gen ipcc_11 =   ipc11_sedlac
gen ipcc_05  =  ipc05_sedlac
gen ppp_05  =  ppp05
gen ppp_11  =  ppp11


drop _merge
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
	
		*tab region_est11 [w=pondera_i] if cohi == 1 & year == 2017, sum(hh_totinc_pc_ppp11)

	gen leading1 = 0
	*replace leading1 = 1 if region == 13 & urbano == 1

	
	replace leading1 = 1 if region_est3_00 == 13101
	replace leading1 = 1 if region_est3_00 == 13102
	replace leading1 = 1 if region_est3_00 == 13103
	replace leading1 = 1 if region_est3_00 == 13104
	replace leading1 = 1 if region_est3_00 == 13105
	replace leading1 = 1 if region_est3_00 == 13106
	replace leading1 = 1 if region_est3_00 == 13107
	replace leading1 = 1 if region_est3_00 == 13108
	replace leading1 = 1 if region_est3_00 == 13109
	replace leading1 = 1 if region_est3_00 == 13110
	replace leading1 = 1 if region_est3_00 == 13111
	replace leading1 = 1 if region_est3_00 == 13112
	replace leading1 = 1 if region_est3_00 == 13113
	replace leading1 = 1 if region_est3_00 == 13114
	replace leading1 = 1 if region_est3_00 == 13115
	replace leading1 = 1 if region_est3_00 == 13116
	replace leading1 = 1 if region_est3_00 == 13117
	replace leading1 = 1 if region_est3_00 == 13118
	replace leading1 = 1 if region_est3_00 == 13119
	replace leading1 = 1 if region_est3_00 == 13120
	replace leading1 = 1 if region_est3_00 == 13121
	replace leading1 = 1 if region_est3_00 == 13122
	replace leading1 = 1 if region_est3_00 == 13123
	replace leading1 = 1 if region_est3_00 == 13124
	replace leading1 = 1 if region_est3_00 == 13125
	replace leading1 = 1 if region_est3_00 == 13126
	replace leading1 = 1 if region_est3_00 == 13127
	replace leading1 = 1 if region_est3_00 == 13128
	replace leading1 = 1 if region_est3_00 == 13129
	replace leading1 = 1 if region_est3_00 == 13130
	replace leading1 = 1 if region_est3_00 == 13131
	replace leading1 = 1 if region_est3_00 == 13132
	
	replace leading1 = 1 if region_est3_03 == 13101
	replace leading1 = 1 if region_est3_03 == 13102
	replace leading1 = 1 if region_est3_03 == 13103
	replace leading1 = 1 if region_est3_03 == 13104
	replace leading1 = 1 if region_est3_03 == 13105
	replace leading1 = 1 if region_est3_03 == 13106
	replace leading1 = 1 if region_est3_03 == 13107
	replace leading1 = 1 if region_est3_03 == 13108
	replace leading1 = 1 if region_est3_03 == 13109
	replace leading1 = 1 if region_est3_03 == 13110
	replace leading1 = 1 if region_est3_03 == 13111
	replace leading1 = 1 if region_est3_03 == 13112
	replace leading1 = 1 if region_est3_03 == 13113
	replace leading1 = 1 if region_est3_03 == 13114
	replace leading1 = 1 if region_est3_03 == 13115
	replace leading1 = 1 if region_est3_03 == 13116
	replace leading1 = 1 if region_est3_03 == 13117
	replace leading1 = 1 if region_est3_03 == 13118
	replace leading1 = 1 if region_est3_03 == 13119
	replace leading1 = 1 if region_est3_03 == 13120
	replace leading1 = 1 if region_est3_03 == 13121
	replace leading1 = 1 if region_est3_03 == 13122
	replace leading1 = 1 if region_est3_03 == 13123
	replace leading1 = 1 if region_est3_03 == 13124
	replace leading1 = 1 if region_est3_03 == 13125
	replace leading1 = 1 if region_est3_03 == 13126
	replace leading1 = 1 if region_est3_03 == 13127
	replace leading1 = 1 if region_est3_03 == 13128
	replace leading1 = 1 if region_est3_03 == 13129
	replace leading1 = 1 if region_est3_03 == 13130
	replace leading1 = 1 if region_est3_03 == 13131
	replace leading1 = 1 if region_est3_03 == 13132

	replace leading1 = 1 if region_est3_15 == 13101
	replace leading1 = 1 if region_est3_15 == 13108
	replace leading1 = 1 if region_est3_15 == 13104
	replace leading1 = 1 if region_est3_15 == 13107
	replace leading1 = 1 if region_est3_15 == 13127
	replace leading1 = 1 if region_est3_15 == 13123
	replace leading1 = 1 if region_est3_15 == 13132
	replace leading1 = 1 if region_est3_15 == 13115
	replace leading1 = 1 if region_est3_15 == 13114
	replace leading1 = 1 if region_est3_15 == 13120
	replace leading1 = 1 if region_est3_15 == 13113
	replace leading1 = 1 if region_est3_15 == 13118
	replace leading1 = 1 if region_est3_15 == 13122
	replace leading1 = 1 if region_est3_15 == 13110
	replace leading1 = 1 if region_est3_15 == 13129
	replace leading1 = 1 if region_est3_15 == 13111
	replace leading1 = 1 if region_est3_15 == 13112
	replace leading1 = 1 if region_est3_15 == 13131
	replace leading1 = 1 if region_est3_15 == 13130
	replace leading1 = 1 if region_est3_15 == 13109
	replace leading1 = 1 if region_est3_15 == 13105
	replace leading1 = 1 if region_est3_15 == 13121
	replace leading1 = 1 if region_est3_15 == 13116
	replace leading1 = 1 if region_est3_15 == 13106
	replace leading1 = 1 if region_est3_15 == 13102
	replace leading1 = 1 if region_est3_15 == 13119
	replace leading1 = 1 if region_est3_15 == 13126
	replace leading1 = 1 if region_est3_15 == 13117
	replace leading1 = 1 if region_est3_15 == 13124
	replace leading1 = 1 if region_est3_15 == 13103
	replace leading1 = 1 if region_est3_15 == 13128
	replace leading1 = 1 if region_est3_15 == 13125
	
	
	label list region


replace leading1 = 1 if region_est3_17 == 237
replace leading1 = 1 if region_est3_17 == 238
replace leading1 = 1 if region_est3_17 == 239
replace leading1 = 1 if region_est3_17 == 240
replace leading1 = 1 if region_est3_17 == 241
replace leading1 = 1 if region_est3_17 == 242
replace leading1 = 1 if region_est3_17 == 243
replace leading1 = 1 if region_est3_17 == 244
replace leading1 = 1 if region_est3_17 == 245
replace leading1 = 1 if region_est3_17 == 246
replace leading1 = 1 if region_est3_17 == 247
replace leading1 = 1 if region_est3_17 == 248
replace leading1 = 1 if region_est3_17 == 249
replace leading1 = 1 if region_est3_17 == 250
replace leading1 = 1 if region_est3_17 == 251
replace leading1 = 1 if region_est3_17 == 252
replace leading1 = 1 if region_est3_17 == 253
replace leading1 = 1 if region_est3_17 == 254
replace leading1 = 1 if region_est3_17 == 255
replace leading1 = 1 if region_est3_17 == 256
replace leading1 = 1 if region_est3_17 == 257
replace leading1 = 1 if region_est3_17 == 258
replace leading1 = 1 if region_est3_17 == 259
replace leading1 = 1 if region_est3_17 == 260
replace leading1 = 1 if region_est3_17 == 261
replace leading1 = 1 if region_est3_17 == 262
replace leading1 = 1 if region_est3_17 == 263
replace leading1 = 1 if region_est3_17 == 264
replace leading1 = 1 if region_est3_17 == 265
replace leading1 = 1 if region_est3_17 == 266
replace leading1 = 1 if region_est3_17 == 267
replace leading1 = 1 if region_est3_17 == 268

	
	*gen leading2 = 0
	*replace leading2 = 1 if (leading1 == 1 | metro == 1) & urbano == 1
	
	gen noleading1 = leading1
	*gen noleading2 = leading2
	recode noleading1 (0 = 1)(1 = 0)
	*recode noleading2 (0 = 1)(1 = 0)	
	
	tab leading1 urbano
	replace leading1 = 0 if urbano == 0

			tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq

	
** Bottom 40%

	foreach year in 2000 2003 2015 2017  {
	_pctile hh_totinc_pc_ppp11 [aweight=pondera_i] if cohi ==1 & year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	foreach year in 2000 2003 2015 2017 {
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

		gen period = .
		replace period = 1 if year == 2000 | year == 2003
		replace period = 4 if year == 2015 | year == 2017

		decode region, gen(adm1)

		label define region  1 "Tarapaca", modify
		label define region     2 "Antofagasta", modify
		label define region    3 "Atacama", modify
		label define region    4 "Coquimbo", modify
        label define region   5 "Valparaiso", modify
		label define region    6 "O'Higgins", modify
		label define region    7 "Maule", modify
		label define region     8 "Biobio", modify
		label define region       9 "La Araucania", modify
		label define region     10 "Los Lagos", modify
		label define region     11 "Aysandel Gral. Carlos Ibañez del Campo", modify
		label define region     12 "Magallanes y de la Antartica Chilena", modify
		label define region     13 "Santiago", modify
		label define region     14 "Los Rios", modify
		label define region    15 "Arica y Parinacota", modify
		label define region     16 "Nuble", modify

keep id com urbano reg* year  leading* jefe noleading* lind* lhh* ind_* hh_* ila ilf ilpc ii ipcf_sr itf def p_reg b40* skilled* cohh cohi pondera* gender age agesq hhsize casado hh_size_02 hh_size_02_sq hh_size_311 hh_size_311_sq hh_size_1217 hh_size_1217_sq hh_size_1859 hh_size_1859_sq hh_size_60 hh_size_60_sq empstat* relab* edattain* hh_max_edattain* hh_piped_to_prem hh_elect hh_sewage hh_toilet lp_moderada def  ipcc_11 ppp_11 adm1
	
		tab year leading1 [w=pondera] if lind_labinc_ppp11 != ., row nofreq

		save "$user/_OaxacaBlinder_replication/inputs/CHL_SEDLACsmall.dta", replace

