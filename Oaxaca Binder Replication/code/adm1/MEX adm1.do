set scheme plottig 
global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"


global demographics gender age agesq casado hhsize hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60   //15
global labor i.relab // 5
global educ  i.edattain i.hh_max_edattain //8
	
	
// Dep IDs for shapefile	
	
use "$user/_OaxacaBlinder_replication/inputs/MEX_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15

gen statenum = real(CVE_ENT)
rename CVE_ENT cve_ent

	gen nobs = pondera 

	sum year, d 
	egen nryear = group(year)

	sum nryear
	local nyear = r(max)
	dis `nyear'

	collapse (mean) b40d pondera skilled (count) nobs [w=pondera], by(cve_ent state statenum leading1)

	gen pop = nobs*pondera/`nyear'
	egen totalpop = sum(pop)
	gen shpop = 100*pop/totalpop
	
	gen poor = b40d*pop
	egen totpoor = sum(poor)
	gen shpoor = 100*poor/totpoor
	
	gen unskilled = (1-skilled)*pop
	egen totunskilled = sum(poor)
	gen shunskilled = 100*unskilled/totunskilled

	
	table leading1, statistic(sum shpop)
	
	drop if leading1 == 1
		
save "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/MEX_adm1.dta", replace		
		
// State regressions		
		
forvalues period = 4/4{
use "$user/_OaxacaBlinder_replication/inputs/MEX_SEDLACsmall.dta", clear
gen statenum = real(CVE_ENT)
keep if cohi == 1 & cohh == 1
keep if age >= 15
	keep if jefe == 1


keep if period ==	`period'
	
	sum statenum
	local max = r(max)
	
forvalues r = 1/`max'{
		gen reg`r' = .
		replace reg`r' = 1 if statenum == `r'
		replace reg`r'  = 0 if leading1 == 1

xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax
						matrix b_`period'_`r' = e(b)
						matrix v_`period'_`r' = e(V)
						matrix N_`period'_`r' = e(N)
							
					preserve

					matsave b_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/MEX/adm1/") dropall replace
					
					restore
					
					preserve

					matsave v_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/MEX/adm1/") dropall replace
					
					restore
				
					preserve

					matsave N_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/MEX/adm1/") dropall replace
					
					restore 	
					
				
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax				

capture oaxaca, eform 							

			matrix eform_`period'_`r' = r(table)				
				
				preserve
				
				matsave eform_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/MEX/adm1/") dropall replace
										
				restore
			}
}					
	
					
// append  
					
forvalues period = 4/4{	
	forvalues r = 1/32{
		
		*** OBS
		use "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/N_`period'_`r'", clear
			gen period = "`period'"
			gen statenum = `r'
			gen df = c1 - 2*23 - 2
			
		save "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/tmp_N_`r'_`period'", replace
		
		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/v_`period'_`r'", clear
					gen period = "`period'"
					gen statenum = `r'

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
					
					keep var_ se_ _rowname period statenum
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/tmp_v_`r'_`period'", replace

	
					*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/b_`period'_`r'", clear
					gen period = "`period'"
					gen statenum = `r'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients period statenum
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 statenum period using "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/tmp_v_`r'_`period'", nogen
					merge 1:1 statenum period using "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/tmp_N_`r'_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/tmp_`r'_`period'", replace
				}	
}		
	

** Append period files, gen CI and p values and graph/export to map
 
use "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/tmp_1_4", clear
forvalues period = 4/4{		
		forvalues r = 1/32{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/tmp_`r'_`period'"
	duplicates drop
		}
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

		
merge m:1 statenum using "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/MEX_adm1.dta", nogen
*merge m:1 cve_ent using "LAC\MEX\MEX_poverty.dta", nogen

gen periodn = real(period)
drop period 
rename periodn period 

*replace b_overall_endowments = b_overall_endowments*100
*replace b_overall_coefficients = b_overall_coefficients*100
*replace b_overall_difference = b_overall_difference*100

save "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/Oaxaca_MEX.dta", replace

// append eform 
	
use "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/eform_4_1", clear
gen statenum = 1
forvalues r = 2/32{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/eform_4_`r'"
	replace statenum = `r' if statenum == .
		}
	
	keep overall_difference overall_explained overall_unexplained _rowname statenum
	
	reshape wide overall_difference overall_explained overall_unexplained, i(statenum) j(_rowname) string 
	
	foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}
		
	merge 1:1 statenum using "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/MEX_adm1", nogen
	merge 1:1 statenum using "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/Oaxaca_MEX.dta", nogen 
	
	gen diff_end = shend*overall_differenceb
	gen diff_ret = shret*overall_differenceb
	
	gen totdiff = diff_end + diff_ret
	
	
save "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/Oaxaca_MEX_eform.dta", replace


use "$user/_OaxacaBlinder_replication/outputs/MEX/adm1/Oaxaca_MEX_eform.dta", clear

gen y = 0

twoway (bar overall_differenceb statenum, horizontal barwidth(0.9) color(edkblue) sort) (rcap overall_differenceul overall_differencell statenum, horizontal color(edkblue) sort),  xtitle("") ytitle(Individual Labor Income Gap (%), size(*1.4)) legend(off) ylabel(1 "Aguascalientes" 2 "Baja California" 3 "Baja California Sur" 4 "Campeche" 5 "Cohauila" 6 "Colima" 7 "Chiapas" 8 "Chihuahua" 9 "rural Distrito Federal" 10 "Durango" 11 "Guanajuato" 12 "Guerrero" 13 "Hidalgo" 14 "Jalisco" 15 "Mexico" 16 "Michoacan" 17 "Morelos" 18 "Nayarit" 19 "Nuevo Leon" 20 "Oaxaca" 21 "Puebla" 22 "Queretaro de Arteaga" 23 "Quintana Roo" 24 "San Luis Potosi" 25 "Sinaloa" 26 "Sonora" 27 "Tabasco" 28 "Tamaulipas" 29 "Tlaxcala" 30 "Veracruz-Llave" 31 "Yucatan" 32 "Zacatecas")


sort overall_differenceb

graph twoway (rbar y diff_end statenum if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y statenum if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb statenum if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end statenum if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end statenum if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y statenum if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))  (bar overall_differenceb statenum, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell statenum, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(1 2 7) region(lwidth(none)))  xtitle("") xtitle(Individual Labor Income Gap (%), size(*1.2)) ytitle("") ylabel(1 "Aguascalientes" 2 "Baja California" 3 "Baja California Sur" 4 "Campeche" 5 "Cohauila" 6 "Colima" 7 "Chiapas" 8 "Chihuahua" 9 "rural Distrito Federal" 10 "Durango" 11 "Guanajuato" 12 "Guerrero" 13 "Hidalgo" 14 "Jalisco" 15 "Mexico" 16 "Michoacan" 17 "Morelos" 18 "Nayarit" 19 "Nuevo Leon" 20 "Oaxaca" 21 "Puebla" 22 "Queretaro de Arteaga" 23 "Quintana Roo" 24 "San Luis Potosi" 25 "Sinaloa" 26 "Sonora" 27 "Tabasco" 28 "Tamaulipas" 29 "Tlaxcala" 30 "Veracruz-Llave" 31 "Yucatan" 32 "Zacatecas", labsize(*0.9))

	*	graph display, ysize(8) xsize(8)
		
// sorting by overall gap 
sort overall_differenceb
gen sorted = _n		
			
graph twoway (rbar y diff_end sorted if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb sorted if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end sorted if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end sorted if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))  (bar overall_differenceb sorted, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell sorted, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2) region(lwidth(none)))  xtitle("") xtitle("Per Capita Labor Income Gap (%)" "Relative to Metro Mexico", size(*1.2)) ytitle("") ylabel(9 "Aguascalientes" 4 "Baja California" 1 "Baja California Sur" 14 "Campeche" 12 "Cohauila" 13 "Colima" 32 "Chiapas" 8 "Chihuahua" 29 "rural Distrito Federal" 19 "Durango" 16 "Guanajuato" 31 "Guerrero" 27 "Hidalgo" 11 "Jalisco" 17 "Mexico" 22 "Michoacan" 15 "Morelos" 18 "Nayarit" 7 "Nuevo Leon" 30 "Oaxaca" 23 "Puebla" 10 "Queretaro de Arteaga" 2 "Quintana Roo" 24 "San Luis Potosi" 5 "Sinaloa" 3 "Sonora" 25 "Tabasco" 6 "Tamaulipas" 21 "Tlaxcala" 28 "Veracruz-Llave" 20 "Yucatan" 26 "Zacatecas", labsize(*0.9))			

		graph display, ysize(8) xsize(10)
		
