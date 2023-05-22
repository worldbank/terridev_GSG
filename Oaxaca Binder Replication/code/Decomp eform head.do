global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

// all countries except ARG and URY, which does not have rural

global demographics gender age agesq casado hhsize hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60   //10
global labor i.relab  // 5
global educ  i.edattain i.hh_max_edattain  //8

// BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY // add country code below to run all countries

foreach code in COL { 
    		
use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear

sum period, detail
*local period = r(max)

local max = r(max)
local min = r(min)

*dis `min' 
*dis `max'

forvalues period = `min'(3)`max'{
use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear

keep if period == `period'
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

eststo clear

qui: eststo: xi: oaxaca lhh_labinc_pc_ppp11 $demographics $labor $educ  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax detail(demographics: $demographics, education : $educ, labor: $labor, year: i.year) 


		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	
		
			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
			
			
			matrix decomp_detail_`period' = r(table)
						
			preserve
			matsave decomp_detail_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/all") dropall replace
			restore 

			
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/all") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/all") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/all") dropall replace
					
				restore
				
				
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/all") dropall replace
				restore 
				
use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

drop b40*
			** replace b40 accounting only for hh head 
			
			forvalue year=2000/2019{
			_pctile hh_labinc_pc_ppp11 [aweight=pondera] if year == `year', p(40) 
			return list
			gen b40_`year' = r(r1)
			}
			
			gen b40 = .
			forvalue year=2000/2019{
			replace b40 = b40_`year' if year == `year'
			}
			
			drop b40_*
			
			gen b40d = 0
			replace b40d = 1 if hh_labinc_pc_ppp11 < b40

keep if b40d == 1

eststo: xi: oaxaca lhh_labinc_pc_ppp11 $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax detail(demographics: $demographics, education : $educ) 


		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	

			matrix decomp_detail_`period' = r(table)

			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
		
		preserve
		matsave decomp_detail_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40") dropall replace
		restore 

				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40") dropall replace
					
				restore

				
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40") dropall replace
				restore 


use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1


keep if urbano == 1 

eststo: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax
		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	
		
			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
							
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/urban") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/urban") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/urban") dropall replace
					
				restore				
				
				
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/urban") dropall replace
				restore 
				
use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohh == 1 & cohi == 1
keep if age >= 1
keep if jefe == 1


replace skilled = 0   // correct  master file for household head  
replace skilled = 1 if hh_max_edattain == 4

keep if skilled == 1

eststo: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax

		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	
		
			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
							
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/skilled") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/skilled") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/skilled") dropall replace
					
				restore
				
				
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/skilled") dropall replace
				restore 
				

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

keep if urbano == 0 | leading1 == 1 // rural against leading

eststo: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax
		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	
		
			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
							
			
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/rural") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/rural") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/rural") dropall replace
					
				restore
				
				
qui: xi: oaxaca lhh_labinc_pc_ppp11  $demographics $labor $educ   i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/rural") dropall replace
				restore 	
				
	esttab, r2 star(* 0.10 ** 0.05 *** 0.01) p(3) b(3) label keep(group_1 group_2 difference explained unexplained)

	
	set more off
	#delimit;
	esttab using "$user/_OaxacaBlinder_replication/outputs/csv tables/oaxaca_`code'_`period'_h.csv",  mlabels(,none) keep(group_1 group_2 difference explained unexplained)
	star(* 0.10 ** 0.05 *** 0.01) b(3) se(3) noisily label replace notype 	varlabels(group_1 `"Leading"' group_2 `"Other regions"' difference Difference explained Endowments unexplained Returns,  nolast)
	stats(Nobs controls, fmt(%9.0f %6s) labels(`"Observations"' `"Controls"'));
	#delimit cr 
	
/*	
set more off
	#delimit;
	esttab using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/oaxaca_`code'_`period'_h.tex",  mlabels(,none) keep(group_1 group_2 difference explained unexplained)
	star(* 0.10 ** 0.05 *** 0.01) b(3) se(3) r2  noisily bookt label replace notype   
	varlabels(group_1 `"Leading"' group_2 `"Other regions"' difference Difference explained Endowments unexplained Returns, end("" [0.05em]) nolast)
	stats(Nobs controls, fmt(%9.0f %6s) labels(`"Observations"' `"Controls"'))  prehead( `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular}{l*{@span}{l}} `"\multicolumn{@span}{c}{\emph{Dependent variable: Log Income (real, PPP)}}\\ "' \hline `"& \multicolumn{1}{c}{All}&\multicolumn{1}{c}{Bottom 40}&\multicolumn{1}{c}{Urban}&\multicolumn{1}{c}{Rural}\\"'    )
	postfoot(`"\hline\hline"' `"\multicolumn{@span}{l}{\footnotesize Robust standard errors in parentheses}\\"' 
	`"\multicolumn{@span}{l}{\footnotesize @starlegend}\\"' \end{tabular} ); 

	#delimit cr  */
	
}	
}


********************************************************

//BOL DOM  BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY

foreach code in COL { 

		foreach group in all b40 urban rural skilled {
		
		forvalues period = 1(3)4{	
    
			*** eform 
			
			use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/eform_`period'", clear
				keep _rowname overall_difference overall_explained overall_unexplained
				
				keep if _rowname == "b" | _rowname == "ll" | _rowname == "ul"

					foreach var in overall_difference overall_explained overall_explained{
						replace `var' = 100*(`var' - 1)
					}
					
			save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/clean_eform_`period'", replace

		*** OBS
		use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/N_`period'", clear
			gen period = `period'
			gen df = c1 - 2*23 - 2
			
		save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_N_`period'", replace
				
		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/v_`period'", clear

					gen period = `period'
					
					gen line = _n
					keep if line <= 5 

					gen var_ = .

					replace var_ = overall_group_1 if line == 1
					replace var_ = overall_group_2 if line == 2

					replace var_ = overall_difference if line == 3
					replace var_ = overall_explained if line == 4
					replace var_ = overall_unexplained if line == 5
					
					gen se_ = sqrt(var)
					
					replace _rowname = "overall_group_1" if _rowname == "overall:group_1"
					replace _rowname = "overall_group_2" if _rowname == "overall:group_2"

					
					replace _rowname = "overall_difference" if _rowname == "overall:difference"
					replace _rowname = "overall_explained" if _rowname == "overall:explained"
					replace _rowname = "overall_unexplained" if _rowname == "overall:unexplained"
					
					keep var_ se_ _rowname period 
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_v_`period'", replace
				
				*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/b_`period'", clear
					gen period = `period'
					
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients overall_group_1 overall_group_2 period
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 period using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_v_`period'", nogen
					merge 1:1 period using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_N_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_`period'", replace
}
}

** Append period files, merge for each group, gen CI and p values and graph/ export to map

foreach group in all b40 urban rural skilled { 
use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_1", clear
forvalues period = 1(3)4{	
		append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_`period'"
		duplicates drop
		}
save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/tmp_all", replace
} 
		

	
** append eforms for period and group 

use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/all/clean_eform_1", clear
		gen group = "all" 
		gen period = "1" 

foreach group in all b40 urban rural skilled { 
forvalues period = 1(3)4{	

		append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/clean_eform_`period'"
		replace group = "`group'" if group == ""
		replace period = "`period'" if period == ""
		}
		}
	
		egen id = group(group period)
		
	duplicates drop
	
	reshape wide overall_difference overall_explained overall_unexplained, i(id) j(_rowname) string 
	
		gen group2 = ""
		replace group2 = "(1) All" if group == "all"
		replace group2 = "(2) Bottom 40%" if group == "b40"
		replace group2 = "(3) Urban" if group == "urban"
		replace group2 = "(4) Skilled" if group == "skilled"
		replace group2 = "(5) Rural" if group == "rural"

save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/eform_all", replace
		
		

use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/all/tmp_all", clear
	gen group = "all"
	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40/tmp_all"
	replace group = "bottom40" if group == ""
	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/urban/tmp_all"
	replace group = "urban" if group == ""
	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/rural/tmp_all"		
	replace group = "rural" if group == ""
	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/skilled/tmp_all"
	replace group = "skilled" if group == ""
		
		foreach var in overall_difference overall_endowments overall_coefficients{
			gen lo_`var' = b_`var'-1.96*se_`var'
			gen hi_`var' = b_`var'+1.96*se_`var'
			gen t_`var' = b_`var'/se_`var'
			gen p_`var' = 2*ttail(df,abs(t_`var'))
		}
		
		sum p_overall_difference
		gen shend = b_overall_endowments/b_overall_difference 
		gen shret = b_overall_coefficients/b_overall_difference 
		
		** keep only the diff who are significant
/*		
		replace b_overall_endowments = . if p_overall_endowments > .05 | p_overall_difference > .05
		replace b_overall_coefficients = . if p_overall_coefficients > .05 | p_overall_difference > .05
		 
		replace b_overall_difference = . if p_overall_difference > .05
	
	
		gen shend = b_overall_endowments/b_overall_difference //if b_overall_difference != .
		gen shret = b_overall_coefficients/b_overall_difference //if b_overall_difference != .
	*/	
	
		save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/allgroupdiff", replace		

				
		use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/allgroupdiff", clear		
		replace group = "1 All" if group == "all"
		replace group = "2 Bottom 40%" if group == "bottom40"
		replace group = "3 Urban" if group == "urban"
		replace group = "4 Rural" if group == "rural"
		replace group = "5 Skilled" if group == "skilled"

		encode group, gen(gr)

		gen group2 = ""
		replace group2 = "(1) All" if gr == 1
		replace group2 = "(2) Bottom 40%" if gr == 2
		replace group2 = "(3) Urban" if gr == 3
		replace group2 = "(5) Rural" if gr == 4
		replace group2 = "(4) Skilled" if gr == 5

		
global var b_overall_difference b_overall_endowments b_overall_coefficients 
		foreach var in $var{
		    replace `var' = 100*`var'
		}
		
		global var hi_overall_difference lo_overall_difference 
		foreach var in $var{
		    replace `var' = 100*`var'
		}
	
save "$user/_OaxacaBlinder_replication/outputs/`code'/metro_allgroupdiff", replace		

}

		
		
	