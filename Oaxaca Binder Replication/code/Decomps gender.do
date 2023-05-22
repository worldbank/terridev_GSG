global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

// all countries except 
	* Argentina and Uruguay, which do not have rural

global demographics age agesq hhsize casado hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60  //9
global labor i.empstat // 5
global educ  i.edattain i.hh_max_edattain //8
global head i.hh_head_edattain hh_fhead //6 

*sum $demographics $labor $educ $head $utilities ind_labinc_ppp11
  
  // CRI DOM BOL CHL
  
  ** BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY // add country code below to run all countries
  
foreach code in COL { 
use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
sum period, detail
local max = r(max)
local min = r(min)

 
forvalue period = `min'(3)`max'{
forvalue gender = 0/1{
use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohi == 1 & cohh == 1
keep if age >= 15
keep if gender == `gender'
replace lind_labinc_ppp11 = log(ind_labinc_ppp11)

eststo clear

drop if b40d == 0

eststo: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax

		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	

			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
							
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/b40") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/b40") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/b40") dropall replace
					
				restore


qui: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period',  p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/b40") dropall replace
				restore 				

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohi == 1 & cohh == 1
keep if age >= 15
keep if gender == `gender'
replace lind_labinc_ppp11 = log(ind_labinc_ppp11)

keep if urbano == 1

eststo: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax
		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	
		
			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
							
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/urban") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/urban") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/urban") dropall replace
					
				restore				

qui: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period',  p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/urban") dropall replace
				restore 				

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohi == 1 & cohh == 1
keep if age >= 15
keep if gender == `gender'
replace lind_labinc_ppp11 = log(ind_labinc_ppp11)

keep if skilled == 1

eststo: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head $utilities i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax
		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	
		
			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
							
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/skilled") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/skilled") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/skilled") dropall replace
					
				restore

qui: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period',  p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/skilled") dropall replace
				restore 				
				
				
use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear
keep if period == `period'
keep if cohi == 1 & cohh == 1
keep if age >= 15
keep if gender == `gender'
replace lind_labinc_ppp11 = log(ind_labinc_ppp11)

keep if urbano == 0 | leading1 == 1 // rural against leading

eststo: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax
		scal nonb = e(N)
		estadd local controls   = "Yes"
		estadd local Nobs = nonb   // number of observations	
		
			matrix b_`period' = e(b)
			matrix v_`period' = e(V)
			matrix N_`period' = e(N)
							
				preserve

				matsave b_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/rural") dropall replace
					
				restore
					
				preserve

				matsave v_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/rural") dropall replace
					
				restore
				
				preserve

				matsave N_`period', p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/rural") dropall replace
					
				restore

qui: xi: oaxaca lind_labinc_ppp11  $demographics $labor $educ $head  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax				

oaxaca, eform 							

			matrix eform_`period' = r(table)				
				
				preserve
				matsave eform_`period',  p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/rural") dropall replace
				restore 				
				

	esttab, r2 star(* 0.10 ** 0.05 *** 0.01) p(3) b(3) label keep(group_1 group_2 difference explained unexplained)

	
	set more off
	#delimit;
	esttab using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/oaxaca_`code'_`period'.csv",  mlabels(,none) 
	star(* 0.10 ** 0.05 *** 0.01) b(3) se(3) noisily label replace notype varlabels(end("" [0.05em]) nolast) ;
	#delimit cr 
	
set more off
	#delimit;
	esttab using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/oaxaca_`code'_`period'.tex",  mlabels(,none) keep(group_1 group_2 difference explained unexplained)
	star(* 0.10 ** 0.05 *** 0.01) b(3) se(3) r2  noisily bookt label replace notype   
	varlabels(group_1 `"Leading"' group_2 `"Other regions"' difference Difference explained Endowments unexplained Returns, end("" [0.05em]) nolast)
	stats(Nobs controls, fmt(%9.0f %6s) labels(`"Observations"' `"Controls"'))  prehead( `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular}{l*{@span}{l}} `"\multicolumn{@span}{c}{\emph{Dependent variable: Log Income (real, PPP)}}\\ "' \hline `"& \multicolumn{1}{c}{All}&\multicolumn{1}{c}{Bottom 40}&\multicolumn{1}{c}{Urban}&\multicolumn{1}{c}{Rural}\\"'    )
	postfoot(`"\hline\hline"' `"\multicolumn{@span}{l}{\footnotesize Robust standard errors in parentheses}\\"' 
	`"\multicolumn{@span}{l}{\footnotesize @starlegend}\\"' \end{tabular} );
;
	#delimit cr  
	
}	
	}
	
********************************************************

// bring all periods together 
foreach group in  b40 urban rural skilled{
forvalue gender = 0/1{
forvalues period = `min'(3)`max'{	

		
		*** OBS
		use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/N_`period'", clear
			gen period = `period'
			gen df = c1 - 2*28 - 2
			
		save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_N_`period'", replace
				
		*** VARIANCE
		use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/v_`period'", clear

					gen period = `period'
					
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
					
					keep var_ se_ _rowname period 
					reshape wide var_ se_, i(period) j(_rowname) string 
		
					rename *overall_explained *overall_endowments
					rename *overall_unexplained *overall_coefficients
					
					save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_v_`period'", replace
				
				*** COEF	
					use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/b_`period'", clear
					gen period = `period'
					rename overall_explained overall_endowments
					rename overall_unexplained overall_coefficients
					keep  overall_difference overall_endowments overall_coefficients period
					rename (overall_difference overall_endowments overall_coefficients) b_=

					merge 1:1 period using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_v_`period'", nogen
					merge 1:1 period using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_N_`period'", nogen
					save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_`period'", replace
					
} 
}
}

** Append period files, merge for each group, gen CI and p values and graph/ export to map

*foreach code in BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY SLV { 
*sum period, detail
*local max = r(max)
*local min = r(min) 


foreach group in  b40 urban rural skilled{ 
forvalue gender = 0/1{
use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_`min'", clear
	forvalues period = `min'(3)`max'{	
		append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_`period'"
		duplicates drop
		}
save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/tmp_all", replace
} 
}


forvalue gender = 0/1{
use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/urban/tmp_all", clear
	gen group = "urban"
	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/b40/tmp_all"
	replace group = "bottom40" if group == ""
	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/rural/tmp_all"
	replace group = "rural" if group == ""
	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/skilled/tmp_all"
	replace group = "skilled" if group == ""
		
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
		
		gen shend = b_overall_endowments/b_overall_difference if b_overall_difference != .
		gen shret = b_overall_coefficients/b_overall_difference if b_overall_difference != .
		
		save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/allgroupdiff", replace		


		replace group = "2 Bottom 40%" if group == "bottom40"
		replace group = "3 Urban" if group == "urban"
		replace group = "4 Rural" if group == "rural"
		replace group = "5 Skilled" if group == "skilled"


		encode group, gen(gr)

		gen group2 = ""
		replace group2 = "(2) Bottom 40%" if gr == 1
		replace group2 = "(3) Urban" if gr == 2
		replace group2 = "(5) Rural" if gr == 3
		replace group2 = "(4) Skilled" if gr == 4
		
global var b_overall_difference b_overall_endowments b_overall_coefficients 
		foreach var in $var{
		    replace `var' = 100*`var'
		}
		
		global var hi_overall_difference lo_overall_difference 
		foreach var in $var{
		    replace `var' = 100*`var'
		}
	
	
		save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'_allgroupdiff", replace		
}

}
