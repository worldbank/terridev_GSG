set scheme plottig 
global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

global demographics gender age agesq casado hhsize hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60   //15
global labor i.relab // 5
global educ  i.edattain i.hh_max_edattain //8

	
// State regressions		
		
use "$user/_OaxacaBlinder_replication/inputs/ARG_SEDLACsmall.dta", clear
*sum period
local period = 4
keep if period == `period'

keep if cohi == 1 & cohh == 1
keep if age >= 15

gen prov = real(region_est21) 

gen ID_1 = .
replace ID_1 = 1 if prov == 2
replace ID_1 = 1 if prov == 3
replace ID_1 = 1 if prov == 33
replace ID_1 = 1 if prov == 34
replace ID_1 = 1 if prov == 38
replace ID_1 = 2 if prov == 13
replace ID_1 = 2 if prov == 36
replace ID_1 = 3 if prov == 22
replace ID_1 = 4 if prov == 8
replace ID_1 = 5 if prov == 9
replace ID_1 = 5 if prov == 91
replace ID_1 = 6 if prov == 32
replace ID_1 = 7 if prov == 12
replace ID_1 = 8 if prov == 6
replace ID_1 = 8 if prov == 14
replace ID_1 = 9 if prov == 15
replace ID_1 = 10 if prov == 19
replace ID_1 = 11 if prov == 30
replace ID_1 = 12 if prov == 25
replace ID_1 = 13 if prov == 10
replace ID_1 = 14 if prov == 7
replace ID_1 = 15 if prov == 17
replace ID_1 = 16 if prov == 93
replace ID_1 = 17 if prov == 23
replace ID_1 = 18 if prov == 27
replace ID_1 = 19 if prov == 26
replace ID_1 = 20 if prov == 20
replace ID_1 = 21 if prov == 4
replace ID_1 = 21 if prov == 5
replace ID_1 = 22 if prov == 18
replace ID_1 = 23 if prov == 31
replace ID_1 = 24 if prov == 29


save "$user/_OaxacaBlinder_replication\outputs\ARG\adm1/ARG_SEDLACsmall_provlastp.dta", replace

	gen nobs = pondera 

	sum year, d 
	egen nryear = group(year)
 

	sum nryear
	local nyear = r(max)
	dis `nyear'

	collapse (mean) b40d pondera (count) nobs [w=pondera], by(ID_1)

	gen pop = nobs*pondera/`nyear'
	egen totalpop = sum(pop)

	save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/ARG_adm1", replace
	

use "$user/_OaxacaBlinder_replication\outputs\ARG\adm1/ARG_SEDLACsmall_provlastp.dta", clear
	
	sum ID_1
	local max = r(max)
	local period = 4

forvalues r = 1/`max'{
	use "$user/_OaxacaBlinder_replication\outputs\ARG\adm1/ARG_SEDLACsmall_provlastp.dta", clear
		keep if jefe == 1

		gen reg`r' = .
		replace reg`r' = 1 if ID_1 == `r'
		replace reg`r'  = 0 if leading1 == 1

capture xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax
						matrix b_`period'_`r' = e(b)
						matrix v_`period'_`r' = e(V)
						matrix N_`period'_`r' = e(N)
							
					preserve

					matsave b_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/ARG/adm1") dropall replace
					
					restore
					
					preserve

					matsave v_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/ARG/adm1/") dropall replace
					
					restore
				
					preserve

					matsave N_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/ARG/adm1/") dropall replace
					
					restore 	
				
capture qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax				

capture oaxaca, eform 							

			matrix eform_`period'_`r' = r(table)				
				
			matsave eform_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/ARG/adm1/") dropall replace
							
			}
					
					
// log decomposition 					



** Append period files, gen CI and p values and graph/export to map

// append  
	
	// r = 6 is BA no obs 
	// r = 16 dont have first period 
	// do this manually 

					
	forvalues r = 1/5{
		
		*** OBS
		 use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/N_`period'_`r'", clear
			gen period = "`period'"
			gen ID_1 = `r'
			gen df = c1 - 2*23 - 2
			
		 save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_N_`r'_`period'", replace

		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/v_`period'_`r'", clear
					gen period = "`period'"
					gen ID_1 = `r'

					gen line = _n
					keep if line == 3 | line == 4 | line == 5

					gen var_ = .

					replace var_ = overall_difference if line == 3
					replace var_ = overall_explained if line == 4
					replace var_ = overall_unexplained if line == 5
					
					gen se_ = sqrt(var)
					
					replace _rowname = "overall_difference" if _rowname == "overall:difference"
					replace _rowname = "overall_explained" if _rowname == "overall:explained"
					replace _rowname = "overall_unexplained" if _rowname == "overall:unexplained"
					
					keep var_ se_ _rowname period ID_1
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_v_`r'_`period'", replace
		
					*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/b_`period'_`r'", clear
					gen period = "`period'"
					gen ID_1 = `r'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients period ID_1
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_v_`r'_`period'", nogen
					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_N_`r'_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_`r'_`period'", replace
				}	
				
forvalues r = 7/24{
		
		*** OBS
		 use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/N_`period'_`r'", clear
			gen period = "`period'"
			gen ID_1 = `r'
			gen df = c1 - 2*23 - 2
			
		 save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_N_`r'_`period'", replace

		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/v_`period'_`r'", clear
					gen period = "`period'"
					gen ID_1 = `r'

					gen line = _n
					keep if line == 3 | line == 4 | line == 5

					gen var_ = .

					replace var_ = overall_difference if line == 3
					replace var_ = overall_explained if line == 4
					replace var_ = overall_unexplained if line == 5
					
					gen se_ = sqrt(var)
					
					replace _rowname = "overall_difference" if _rowname == "overall:difference"
					replace _rowname = "overall_explained" if _rowname == "overall:explained"
					replace _rowname = "overall_unexplained" if _rowname == "overall:unexplained"
					
					keep var_ se_ _rowname period ID_1
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_v_`r'_`period'", replace
		
					*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/b_`period'_`r'", clear
					gen period = "`period'"
					gen ID_1 = `r'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients period ID_1
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_v_`r'_`period'", nogen
					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_N_`r'_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_`r'_`period'", replace
				}	
		
 
use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_1_4", clear
forvalues r = 1/24{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/tmp_`r'_4"
		}
		
	
		duplicates drop
		
		
		foreach var in overall_difference overall_endowments overall_coefficients{
			gen lo_`var' = b_`var'-1.96*se_`var'
			gen hi_`var' = b_`var'+1.96*se_`var'
			gen t_`var' = b_`var'/se_`var'
			gen p_`var' = 2*ttail(df,abs(t_`var'))
		}
		
		sum p_overall_difference
		
		** keep only the diff who are significant
		
		*replace b_overall_endowments = . if p_overall_endowments > .05 | p_overall_difference > .05
		*replace b_overall_coefficients = . if p_overall_coefficients > .05 | p_overall_difference > .05
		 
		*replace b_overall_difference = . if p_overall_difference > .05
		
		gen shend = b_overall_endowments/b_overall_difference //if b_overall_difference != .
		gen shret = b_overall_coefficients/b_overall_difference //if b_overall_difference != .			

		
gen periodn = real(period)
drop period 
rename periodn period 

merge 1:1 ID_1 using  "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/ARG_adm1", nogen

save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/Oaxaca_ARG.dta", replace

// append eform 
	
use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/eform_4_1", clear
gen ID_1 = 1
forvalues r = 2/24{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/eform_4_`r'"
	replace ID_1 = `r' if ID_1 == .
		}
	
	keep overall_difference overall_explained overall_unexplained _rowname ID_1
	
	reshape wide overall_difference overall_explained overall_unexplained, i(ID_1) j(_rowname) string 
	
	foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}
	merge 1:1 ID_1 using "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/Oaxaca_ARG.dta", nogen 
	
	gen diff_end = shend*overall_differenceb
	gen diff_ret = shret*overall_differenceb
	
	gen totdiff = diff_end + diff_ret
	
	
save "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/Oaxaca_ARG_eform.dta", replace

use "$user/_OaxacaBlinder_replication/outputs/ARG/adm1/Oaxaca_ARG_eform.dta", clear

gen y = 0

twoway (bar overall_differenceb ID_1, horizontal barwidth(0.9) color(edkblue) sort) (rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue) sort),  xtitle("") ytitle(Individual Labor Income Gap (%), size(*1.4)) legend(off) ylabel(1 "Buenos Aires" 2 "Cordoba" 3 "Catamarca" 4 "Chaco" 5 "Chubut" 6 "Ciudad de Buenos Aires" 7 "Corrientes" 8 "Entre Rios" 9 "Formosa" 10 "Jujuy" 11 "La Pampa" 12 "La Rioja" 13 "Mendoza" 14 "Misiones" 15 "Neuquen" 16 "Rio Negro" 17 "Salta" 18 "San Juan" 19 "San Luis" 20 "Santa Cruz" 21 "Santa Fe" 22 "Santiago del Estero" 23 "Tierra del Fuego" 24 "Tucuman")


sort overall_differenceb

graph twoway (rbar y diff_end ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb ID_1 if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end ID_1 if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))  (bar overall_differenceb ID_1, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(1 2 7) region(lwidth(none)))  xtitle("") xtitle(Individual Labor Income Gap (%), size(*1.2)) ytitle("") ylabel(1 "Buenos Aires" 2 "Cordoba" 3 "Catamarca" 4 "Chaco" 5 "Chubut" 6 "Ciudad de Buenos Aires" 7 "Corrientes" 8 "Entre Rios" 9 "Formosa" 10 "Jujuy" 11 "La Pampa" 12 "La Rioja" 13 "Mendoza" 14 "Misiones" 15 "Neuquen" 16 "Rio Negro" 17 "Salta" 18 "San Juan" 19 "San Luis" 20 "Santa Cruz" 21 "Santa Fe" 22 "Santiago del Estero" 23 "Tierra del Fuego" 24 "Tucuman", labsize(*0.9))

	graph display, ysize(8) xsize(10)
		
// sorting by overall gap 
sort overall_differenceb
gen sorted = _n		
		
		drop if sorted == 24 // leading
	
graph twoway (rbar y diff_end sorted if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb sorted if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end sorted if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end sorted if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))  (bar overall_differenceb sorted, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell sorted, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2) region(lwidth(none)))  xtitle("") xtitle("Per capita Labor Income Gap (%)" "Relative to the City of Buenos Aires", size(*1.2)) ytitle("") ylabel(22 "Corrientes" 23 "Chaco" 18 "Salta" 21 "Misiones" 13 "Córdoba" 15 "Tucumán" 14 "Buenos Aires" 10 "Mendoza" 20 "Santiago del Estero" 12 "San Juan" 16 "Catamarca" 19 "Formosa" 11 "Entre Ríos" 17 "Jujuy" 7 "Santa Fe" 6 "La Pampa" 5 "Río Negro" 9 "La Rioja" 8 "San Luis" 2 "Santa Cruz" 3 "Neuquén" 4 "Chubut" 1 "Tierra del Fuego", labsize(*0.9))			

		graph display, ysize(8) xsize(10)
		



