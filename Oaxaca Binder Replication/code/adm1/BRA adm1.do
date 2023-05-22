set scheme plottig 
global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"


global demographics gender age agesq casado hhsize hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60   //15
global labor i.relab // 5
global educ  i.edattain i.hh_max_edattain //8
	
// Dep IDs for shapefile	
	
use "$user/_OaxacaBlinder_replication/inputs/BRA_SEDLACsmall.dta", clear
keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

	gen CD_GEOCODU = real(region_est21)

	gen nobs = pondera 

	sum year, d 
	egen nryear = group(year)

	sum nryear
	local nyear = r(max)
	dis `nyear'

	collapse (mean) b40d pondera skilled (count) nobs [w=pondera], by(CD_GEOCODU leading1)

	gen pop = nobs*pondera/`nyear'
	egen totalpop = sum(pop)
			gen shpop = 100*pop/totalpop

	gen poor = b40d*pop
	egen totpoor = sum(poor)
	gen shpoor = 100*poor/totpoor
	
	gen unskilled = (1-skilled)*pop
	egen totunskilled = sum(poor)
	gen shunskilled = 100*unskilled/totunskilled

	gen ID_1 = .	
	replace ID_1 = 1 if CD_GEOCODU == 11
	replace ID_1 = 2 if CD_GEOCODU == 12
	replace ID_1 = 3 if CD_GEOCODU == 13
	replace ID_1 = 4 if CD_GEOCODU == 14
	replace ID_1 = 5 if CD_GEOCODU == 15
	replace ID_1 = 6 if CD_GEOCODU == 16
	replace ID_1 = 7 if CD_GEOCODU == 17
	replace ID_1 = 8 if CD_GEOCODU == 21
	replace ID_1 = 9 if CD_GEOCODU == 22
	replace ID_1 = 10 if CD_GEOCODU == 23
	replace ID_1 = 11 if CD_GEOCODU == 24
	replace ID_1 = 12 if CD_GEOCODU == 25
	replace ID_1 = 13 if CD_GEOCODU == 26
	replace ID_1 = 14 if CD_GEOCODU == 27
	replace ID_1 = 15 if CD_GEOCODU == 28
	replace ID_1 = 16 if CD_GEOCODU == 29
	replace ID_1 = 17 if CD_GEOCODU == 31
	replace ID_1 = 18 if CD_GEOCODU == 32
	replace ID_1 = 19 if CD_GEOCODU == 33
	replace ID_1 = 20 if CD_GEOCODU == 35
	replace ID_1 = 21 if CD_GEOCODU == 41
	replace ID_1 = 22 if CD_GEOCODU == 42
	replace ID_1 = 23 if CD_GEOCODU == 43
	replace ID_1 = 24 if CD_GEOCODU == 50
	replace ID_1 = 25 if CD_GEOCODU == 51
	replace ID_1 = 26 if CD_GEOCODU == 52
	replace ID_1 = 27 if CD_GEOCODU == 53
	
	table leading1, statistic(sum shpop)
	
	drop if leading1 == 1
	
	save "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/BRA_adm1.dta", replace
	
		
// Dep regressions		
		
forvalues period = 4/4{
use "$user/_OaxacaBlinder_replication/inputs/BRA_SEDLACsmall.dta", clear

keep if period ==	`period'

	keep if cohh == 1 & cohi == 1
	keep if age >= 15
	keep if jefe == 1


gen CD_GEOCODU = real(region_est21)

gen ID_1 = .	

replace ID_1 = 1 if CD_GEOCODU == 11
replace ID_1 = 2 if CD_GEOCODU == 12
replace ID_1 = 3 if CD_GEOCODU == 13
replace ID_1 = 4 if CD_GEOCODU == 14
replace ID_1 = 5 if CD_GEOCODU == 15
replace ID_1 = 6 if CD_GEOCODU == 16
replace ID_1 = 7 if CD_GEOCODU == 17
replace ID_1 = 8 if CD_GEOCODU == 21
replace ID_1 = 9 if CD_GEOCODU == 22
replace ID_1 = 10 if CD_GEOCODU == 23
replace ID_1 = 11 if CD_GEOCODU == 24
replace ID_1 = 12 if CD_GEOCODU == 25
replace ID_1 = 13 if CD_GEOCODU == 26
replace ID_1 = 14 if CD_GEOCODU == 27
replace ID_1 = 15 if CD_GEOCODU == 28
replace ID_1 = 16 if CD_GEOCODU == 29
replace ID_1 = 17 if CD_GEOCODU == 31
replace ID_1 = 18 if CD_GEOCODU == 32
replace ID_1 = 19 if CD_GEOCODU == 33
replace ID_1 = 20 if CD_GEOCODU == 35
replace ID_1 = 21 if CD_GEOCODU == 41
replace ID_1 = 22 if CD_GEOCODU == 42
replace ID_1 = 23 if CD_GEOCODU == 43
replace ID_1 = 24 if CD_GEOCODU == 50
replace ID_1 = 25 if CD_GEOCODU == 51
replace ID_1 = 26 if CD_GEOCODU == 52
replace ID_1 = 27 if CD_GEOCODU == 53


	
	sum ID_1
	local max = r(max)
	
forvalues r = 1/`max'{
		gen reg`r' = .
		replace reg`r' = 1 if ID_1 == `r'
		replace reg`r'  = 0 if leading1 == 1

xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax
						matrix b_`period'_`r' = e(b)
						matrix v_`period'_`r' = e(V)
						matrix N_`period'_`r' = e(N)
							
					preserve

					matsave b_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/BRA/adm1/") dropall replace
					
					restore
					
					preserve

					matsave v_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/BRA/adm1/") dropall replace
					
					restore
				
					preserve

					matsave N_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/BRA/adm1/") dropall replace
					
					restore 	
			
			
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ  i.year [aw=pondera], by(reg`r') vce(robust) weight(1) relax				

capture oaxaca, eform 							

			matrix eform_`period'_`r' = r(table)				
				
				preserve
				
				matsave eform_`period'_`r', p("$user/_OaxacaBlinder_replication/outputs/BRA/adm1/") dropall replace
										
				restore			
			}
}					
	
					
// append  
					
forvalues period = 4/4{	
	forvalues r = 1/27{
		

		*** OBS
		use "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/N_`period'_`r'", clear
			gen period = "`period'"
			gen ID_1 = `r'
			gen df = c1 - 2*23 - 2
			
		save "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/tmp_N_`r'_`period'", replace
		
		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/v_`period'_`r'", clear
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
					
					save "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/tmp_v_`r'_`period'", replace

	
					*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/b_`period'_`r'", clear
					gen period = "`period'"
					gen ID_1 = `r'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients period ID_1
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/tmp_v_`r'_`period'", nogen
					merge 1:1 ID_1 period using "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/tmp_N_`r'_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/tmp_`r'_`period'", replace
				}	
}		
	

** Append period files, gen CI and p values and graph/export to map
 

 
use "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/tmp_1_4", clear
forvalues period = 4/4{		
		forvalues r = 1/27{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/tmp_`r'_`period'"
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

		
merge m:1 ID_1 using "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/BRA_adm1", nogen

gen periodn = real(period)
drop period 
rename periodn period 

*replace b_overall_endowments = b_overall_endowments*100
*replace b_overall_coefficients = b_overall_coefficients*100



save "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/Oaxaca_BRA.dta", replace


use "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/eform_4_1", clear
gen ID_1 = 1
forvalues r = 2/27{
	capture	append using "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/eform_4_`r'"
	replace ID_1 = `r' if ID_1 == .
		}
	
	keep overall_difference overall_explained overall_unexplained _rowname ID_1
	
	reshape wide overall_difference overall_explained overall_unexplained, i(ID_1) j(_rowname) string 
	
	foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}
		
	merge 1:1 ID_1 using "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/Oaxaca_BRA.dta", nogen 

	
	gen diff_end = shend*overall_differenceb
	gen diff_ret = shret*overall_differenceb
	
	gen totdiff = diff_end + diff_ret
	
	
save "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/Oaxaca_BRA_eform.dta", replace

use "$user/_OaxacaBlinder_replication/outputs/BRA/adm1/Oaxaca_BRA_eform.dta", clear


gen y = 0


twoway (bar overall_differenceb ID_1, horizontal barwidth(0.9) color(edkblue) sort) (rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue) sort),  xtitle("") ytitle(Individual Labor Income Gap (%), size(*1.4)) legend(off) ylabel(1 "Rondonia" 2 "Acre" 3 "Amazonas" 4 "Roraima" 5 "Para" 6 "Amapa" 7 "Tocantins" 8 "Maranhao" 9 "Piaui" 10 "Ceara" 11 "Rio Grande do Norte" 12 "Paraiba" 13 "Pernambuco" 14 "Alagoas" 15 "Sergipe" 16 "Bahia" 17 "Minas Gerais" 18 "Espirito Santo" 19 "Rio de Janeiro" 20 "Sao Paulo" 21 "Parana" 22 "Santa Catarina" 23 "Rio Grande do Sul" 24 "Mato Grosso do Sul" 25 "Mato Grosso" 26 "Goias" 27 "Distrito Federal")



sort overall_differenceb

graph twoway (rbar y diff_end ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb ID_1 if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end ID_1 if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y ID_1 if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9)) (rbar overall_differenceb diff_end ID_1 if diff_end < 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (rbar y diff_end ID_1 if diff_end < 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (bar overall_differenceb ID_1, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell ID_1, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(1 2 7) region(lwidth(none)))  xtitle("") xtitle(Individual Labor Income Gap (%), size(*1.2)) ytitle("") ylabel(1 "Rondonia" 2 "Acre" 3 "Amazonas" 4 "Roraima" 5 "Para" 6 "Amapa" 7 "Tocantins" 8 "Maranhao" 9 "Piaui" 10 "Ceara" 11 "Rio Grande do Norte" 12 "Paraiba" 13 "Pernambuco" 14 "Alagoas" 15 "Sergipe" 16 "Bahia" 17 "Minas Gerais" 18 "Espirito Santo" 19 "Rio de Janeiro" 20 "Sao Paulo" 21 "Parana" 22 "Santa Catarina" 23 "Rio Grande do Sul" 24 "Mato Grosso do Sul" 25 "Mato Grosso" 26 "Goias" 27 "Distrito Federal", labsize(*0.9))
	*	graph display, ysize(8) xsize(8)
		
// sorting by overall gap 
sort overall_differenceb
gen sorted = _n		
		
	
graph twoway (rbar y diff_end sorted if diff_end > 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end > 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (bar overall_differenceb sorted if diff_end > 0 & diff_ret > 0, horizontal barwidth(0.9) color(eltblue)) (rbar overall_differenceb diff_end sorted if diff_end > 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9))(rbar y diff_end sorted if diff_end < 0 & diff_ret > 0, horizontal color(eltblue) barwidth(0.9)) (rbar diff_ret y sorted if diff_end < 0 & diff_ret > 0, horizontal color(orange) barwidth(0.9)) (rbar overall_differenceb diff_end sorted if diff_end < 0 & diff_ret < 0, horizontal color(orange) barwidth(0.9)) (rbar y diff_end sorted if diff_end < 0 & diff_ret < 0, horizontal color(eltblue) barwidth(0.9)) (bar overall_differenceb sorted, horizontal barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell sorted, horizontal color(edkblue)), legend(label(1 "Endowments") label(2 "Returns to endowments") label(9 "Income gap") position(12) row(1) order(9 1 2) region(lwidth(none)))  xtitle("") xtitle("Per Capita Labor Income Gap (%)" "Relative to BH, RJ, SP metros", size(*1.2)) ytitle("") ylabel(11 "Rondonia" 17 "Acre" 20 "Amazonas" 13 "Roraima" 24 "Para" 15 "Amapa" 14 "Tocantins" 27 "Maranhao" 26 "Piaui" 25 "Ceara" 16 "Rio Grande do Norte" 19 "Paraiba" 18 "Pernambuco" 22 "Alagoas" 21 "Sergipe" 23 "Bahia" 12 "Minas Gerais" 9 "Espirito Santo" 6 "Rio de Janeiro" 3 "Sao Paulo" 5 "Parana" 2 "Santa Catarina" 4 "Rio Grande do Sul" 7 "Mato Grosso do Sul" 8 "Mato Grosso" 10 "Goias" 1 "Distrito Federal", labsize(*0.9))			

		graph display, ysize(8) xsize(10)
		
