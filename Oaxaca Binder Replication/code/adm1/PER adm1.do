set scheme plottig 
global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"


global demographics gender age agesq casado hhsize hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60   //15
global labor i.relab // 5
global educ  i.edattain i.hh_max_edattain //8
	
use "$user/_OaxacaBlinder_replication/inputs/PER_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15


	gen nobs = pondera 

	sum year, d 
	egen nryear = group(year)


gen area = real(region_est21)
rename id hhid
	
gen id = .	
replace id = 0 if area == 23
replace id = 1 if area == 18
replace id = 2 if area == 4
replace id = 3 if area == 17
replace id = 4 if area == 6
replace id = 5 if area == 11
replace id = 6 if area == 21
replace id = 7 if area == 25
replace id = 8 if area == 8
replace id = 9 if area == 3
replace id = 10 if area == 5
replace id = 11 if area == 9
replace id = 12 if area == 7
replace id = 13 if area == 15
replace id = 14 if area == 12
replace id = 15 if area == 19
replace id = 16 if area == 2
replace id = 17 if area == 10
replace id = 18 if area == 13
replace id = 19 if area == 14
replace id = 20 if area == 22
replace id = 21 if area == 1
replace id = 22 if area == 20
replace id = 23 if area == 24
replace id = 24 if area == 16


save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/PER_SEDLACsmall_provlastp.dta", replace // last period 2017-2019 


	sum nryear
	local nyear = r(max)
	dis `nyear'

	collapse (mean) b40d pondera skilled (count) nobs [w=pondera], by(id area region_est22 leading1)

	gen pop = nobs*pondera/`nyear'
	egen totalpop = sum(pop)

	
	gen poor = b40d*pop
	egen totpoor = sum(poor)
	gen shpoor = 100*poor/totpoor
		gen shpop = 100*pop/totalpop

	
	gen unskilled = (1-skilled)*pop
	egen totunskilled = sum(poor)
	gen shunskilled = 100*unskilled/totunskilled
	
		
	table leading1, statistic(sum shpop)
	
	drop if leading1 == 1

	save "$user/_OaxacaBlinder_replication/outputs\PER\adm1/PER_adm1.dta", replace

	
	use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/PER_SEDLACsmall_provlastp.dta", clear

	sum id
	local max = r(max)
	local period = 4
	
forvalues r = 0/`max'{
    
use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/PER_SEDLACsmall_provlastp.dta", clear
	keep if jefe == 1

		gen reg`r' = .
		replace reg`r' = 1 if id == `r'
		replace reg`r'  = 0 if leading1 == 1

capture xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax
						matrix b_`period'_`r' = e(b)
						matrix v_`period'_`r' = e(V)
						matrix N_`period'_`r' = e(N)
							
					preserve

					matsave b_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/PER/adm1/") dropall replace
					
					restore
					
					preserve

					matsave v_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/PER/adm1/") dropall replace
					
					restore
				
					preserve

					matsave N_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/PER/adm1/") dropall replace
					
					restore 	
capture qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax				

capture oaxaca, eform 							

			matrix eform_`period'_`r' = r(table)				
				
			matsave eform_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/PER/adm1/") dropall replace
								

			}

		
		
// 12 is Callao (no obs since all leading)
			
						
// append before - // log decomposition to get the shares  
					
forvalues period = 4/4{	
	forvalues r = 0/11{
		
		*** OBS
		use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/N_`period'_`r'", clear
			gen period = "`period'"
			gen id = `r'
			gen df = c1 - 2*32 - 2
			
		save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_N_`r'_`period'", replace
		
		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/v_`period'_`r'", clear
					gen period = "`period'"
					gen id = `r'

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
					
					keep var_ se_ _rowname period id
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_v_`r'_`period'", replace

	
					*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/b_`period'_`r'", clear
					gen period = "`period'"
					gen id = `r'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients period id
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 id period using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_v_`r'_`period'", nogen
						merge 1:1 id period using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_N_`r'_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_`r'_`period'", replace
				}	

			
forvalues r = 13/24{
		
		*** OBS
		use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/N_`period'_`r'", clear
			gen period = "`period'"
			gen id = `r'
			gen df = c1 - 2*23 - 2
			
		save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_N_`r'_`period'", replace
		
		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/v_`period'_`r'", clear

					gen period = "`period'"
					gen id = `r'

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
					
					keep var_ se_ _rowname id period
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_v_`r'_`period'", replace
				
					*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/b_`period'_`r'", clear
					gen period = "`period'"
					gen id = `r'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					
					keep  overall_difference overall_endowments overall_coefficients period id
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 id period using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_v_`r'_`period'", nogen
						merge 1:1 id period using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_N_`r'_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_`r'_`period'", replace
				}	
}		
	

** Append period files, gen CI and p values and graph/export to map
 
use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_0_4", clear
forvalues period = 4/4{		
		forvalues r = 1/24{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/tmp_`r'_`period'"
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
	

gen periodn = real(period)
drop period 
rename periodn period 

replace b_overall_endowments = b_overall_endowments*100
replace b_overall_coefficients = b_overall_coefficients*100

save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/Oaxaca_PER.dta", replace

// append eform 


use "$user/_OaxacaBlinder_replication/outputs/PER/adm1/eform_4_0", clear
gen id = 0
forvalues r = 1/24{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/eform_4_`r'"
	replace id = `r' if id == .
		}
	
	keep overall_difference overall_explained overall_unexplained _rowname id
	
	reshape wide overall_difference overall_explained overall_unexplained, i(id) j(_rowname) string 
	
	foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}
		
	merge 1:1 id using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/Oaxaca_PER.dta", nogen 
	merge 1:1 id using "$user/_OaxacaBlinder_replication/outputs/PER/adm1/PER_adm1.dta", nogen 

	gen diff_end = shend*overall_differenceb
	gen diff_ret = shret*overall_differenceb
	
	gen totdiff = diff_end + diff_ret
	
	gen ID_1 = id

save "$user/_OaxacaBlinder_replication/outputs/PER/adm1/Oaxaca_PER_eform.dta", replace

gen y = 0

twoway (bar overall_differenceb ID_1, horizontal barwidth(0.9) color(edkblue) sort) (rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue) sort),  xtitle("") ytitle(Individual Labor Income Gap (%), size(*1.4)) legend(off) ylabel(0 "Tacna" 1 "Moquegua" 2 "Arequipa" 3 "Madre de Dios" 4 "Cajamarca" 5 "Ica" 6 "Puno" 7 "Ucayali" 8 "Cusco" 9 "Apurímac" 10 "Ayacucho" 11 "Huancavelica" 12 "Callao" 13 "Lima" 14 "Junín" 15 "Pasco" 16 "Ancash" 17 "Huánuco" 18 "La Libertad" 19 "Lambayeque" 20 "San Martín" 21 "Amazonas" 22 "Piura" 23 "Tumbes" 24 "Loreto")

graph twoway (rbar y diff_end ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb ID_1 if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end ID_1 if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))  (bar overall_differenceb ID_1, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(1 2 7) region(lwidth(none)))  xtitle("") xtitle(Individual Labor Income Gap (%), size(*1.2)) ytitle("") ylabel(0 "Tacna" 1 "Moquegua" 2 "Arequipa" 3 "Madre de Dios" 4 "Cajamarca" 5 "Ica" 6 "Puno" 7 "Ucayali" 8 "Cusco" 9 "Apurímac" 10 "Ayacucho" 11 "Huancavelica" 12 "Callao" 13 "Lima" 14 "Junín" 15 "Pasco" 16 "Ancash" 17 "Huánuco" 18 "La Libertad" 19 "Lambayeque" 20 "San Martín" 21 "Amazonas" 22 "Piura" 23 "Tumbes" 24 "Loreto", labsize(*0.9))

	*	graph display, ysize(8) xsize(8)
		
// sorting by overall gap 
sort overall_differenceb
gen sorted = _n		
		
		drop if id == 12 // leading
	
graph twoway (rbar y diff_end sorted if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb sorted if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end sorted if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end sorted if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))  (bar overall_differenceb sorted, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell sorted, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2) region(lwidth(none)))  xtitle("") xtitle("Per Capita Labor Income Gap (%)" "Relative to Metro Lima", size(*1.2)) ytitle("") ylabel(5 "Tacna" 4 "Moquegua" 1 "Arequipa" 3 "Madre de Dios" 23 "Cajamarca" 2 "Ica" 19 "Puno" 10 "Ucayali" 14 "Cusco" 16 "Apurímac" 22 "Ayacucho" 24 "Huancavelica" 6 "Lima rural" 11 "Junín" 18 "Pasco" 13 "Ancash" 21 "Huánuco" 9 "La Libertad" 8 "Lambayeque" 15 "San Martín" 17 "Amazonas" 12 "Piura" 7 "Tumbes" 20 "Loreto", labsize(*0.9))			

		graph display, ysize(8) xsize(10)
		

