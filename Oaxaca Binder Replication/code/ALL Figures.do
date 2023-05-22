global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"
set scheme plottig

// transformation for charts (files are already in the folder if necessary/want to skip this step)

*********************************** eforms 

foreach code in ARG URY{
foreach group in urban skilled b40 {
forvalues period = 1(3)4{	
    
use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/eform_`period'", clear
keep _rowname overall_difference overall_explained overall_unexplained
	gen code = "`code'"
	gen group = "`group'"
	gen period = "`period'"
save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/clean_eform_`period'", replace
 
}
}
}

use "$user/_OaxacaBlinder_replication/outputs/ARG/metro/b40/clean_eform_1", clear
append using "$user/_OaxacaBlinder_replication/outputs/ARG/metro/b40/clean_eform_1"

foreach code in BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY {
foreach group in all rural urban skilled b40 {
forvalues period = 1(3)4{	
    
 use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/eform_`period'", clear
keep _rowname overall_difference overall_explained overall_unexplained
	gen code = "`code'"
	gen group = "`group'"
	gen period = "`period'"
 save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/clean_eform_`period'", replace
 
}
}
}
	
foreach code in BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY {
foreach group in urban rural {
forvalues period = 1(3)4{	
    
 use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40/`group'/eform_`period'", clear
keep _rowname overall_difference overall_explained overall_unexplained
	gen code = "`code'"
	gen group = "`group'"
	gen period = "`period'"
 save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40/`group'/clean_eform_`period'", replace
 
}
}
}	
	
// append all 
use "$user/_OaxacaBlinder_replication/outputs/ARG/metro/urban/clean_eform_1", clear
foreach code in ARG BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY URY {
foreach group in all rural urban skilled b40 {
forvalues period = 1(3)4{	
 capture 	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/`group'/clean_eform_`period'"
}
}
}
	
duplicates drop

tab code	

keep if _rowname == "b" | _rowname == "ll" | _rowname == "ul"
 
gen id = code+period+group
reshape wide overall_difference overall_explained overall_unexplained, i(id) j(_rowname) string 

		gen group2 = ""
		replace group2 = "(1) All" if group == "all"
		replace group2 = "(2) Bottom 40%" if group == "b40"
		replace group2 = "(3) Urban" if group == "urban"
		replace group2 = "(4) Skilled" if group == "skilled"
		replace group2 = "(5) Rural" if group == "rural"

foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}

gen periodr = real(period)
drop period
rename periodr period

recode period (4=2)		

save "$user/_OaxacaBlinder_replication/outputs/figures/countrydecomp", replace

// append b40 

use "$user/_OaxacaBlinder_replication/outputs/BOL/metro/b40/urban/clean_eform_1", clear
foreach code in  BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY  {
foreach group in  rural urban   {
forvalues period = 1(3)4{	
 capture 	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40/`group'/clean_eform_`period'"
}
}
}
	
duplicates drop

tab code	

keep if _rowname == "b" | _rowname == "ll" | _rowname == "ul"

gen id = code+period+group
reshape wide overall_difference overall_explained overall_unexplained, i(id) j(_rowname) string 

		gen group2 = ""
		replace group2 = "(1) B40 Urban" if group == "urban"
		replace group2 = "(2) B40 Rural" if group == "rural"

foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}

gen periodr = real(period)
drop period
rename periodr period

recode period (4=2)		

save "$user/_OaxacaBlinder_replication/outputs/figures/b40_countrydecomp", replace

// country files 
		
foreach code in ARG BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY URY   {
use "$user/_OaxacaBlinder_replication/outputs/countrydecomp", clear
keep if code == "`code'"
save "$user/_OaxacaBlinder_replication/outputs/`code'/incdiffgroup2periods", replace
}

// country files B40
		
foreach code in  BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY    {
use "$user/_OaxacaBlinder_replication/outputs/b40_countrydecomp", clear
keep if code == "`code'"
save "$user/_OaxacaBlinder_replication/outputs/`code'/b40_incdiffgroup2periods", replace
}

// shares 

foreach code in ARG BOL BRA CRI CHL  DOM  COL ECU HND MEX PAN PER PRY URY  {
    
use "$user/_OaxacaBlinder_replication/outputs/`code'/metro_allgroupdiff", clear
recode period (4=2)

merge 1:1 group2 period using "$user/_OaxacaBlinder_replication/outputs/`code'/incdiffgroup2periods"

gen diff_end = shend*overall_differenceb
gen diff_ret = shret*overall_differenceb

save "$user/_OaxacaBlinder_replication/outputs/`code'/allgroupdiff_e.dta", replace
}

use "$user/_OaxacaBlinder_replication/outputs/ARG/allgroupdiff_e", clear
foreach code in BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY URY {
append using "$user/_OaxacaBlinder_replication/outputs/`code'/allgroupdiff_e"
}

gen period2 = "First period" if period == 1 
replace period2 = "Last period" if period == 2

save "$user/_OaxacaBlinder_replication/outputs/figures/metro_allgroupdiff_2period_eform.dta", replace

// shares b40 

foreach code in  BOL BRA CRI CHL  DOM  COL ECU HND MEX PAN PER PRY   {
    
use "$user/_OaxacaBlinder_replication/outputs/`code'/metro_b40groupdiff", clear
recode period (4=2)

merge 1:1 group2 period using "$user/_OaxacaBlinder_replication/outputs/`code'/b40_incdiffgroup2periods"

gen diff_end = shend*overall_differenceb
gen diff_ret = shret*overall_differenceb

save "$user/_OaxacaBlinder_replication/outputs/`code'/b40_allgroupdiff_e.dta", replace
}

use "$user/_OaxacaBlinder_replication/outputs/BOL/b40_allgroupdiff_e", clear
foreach code in BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY {
append using "$user/_OaxacaBlinder_replication/outputs/`code'/b40_allgroupdiff_e"
}

gen period2 = "First period" if period == 1 
replace period2 = "Last period" if period == 2

save "$user/_OaxacaBlinder_replication/outputs/figures/b40_metro_allgroupdiff_2period_eform.dta", replace



********************************************************* BY GENDER

*********************************** eforms 

foreach code in ARG URY{
foreach group in urban skilled b40 {
forvalues period = 1(3)4{	
forvalues gender = 0/1{   
use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/eform_`period'", clear
keep _rowname overall_difference overall_explained overall_unexplained
	gen code = "`code'"
	gen group = "`group'"
	gen period = "`period'"
	gen gender = "`gender'"
save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/clean_eform_`period'", replace
 
}
}
}
}

foreach code in BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY  {
foreach group in all rural urban skilled b40 {
forvalues period = 1(3)4{	
    forvalues gender = 0/1{   

capture use "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/eform_`period'", clear
keep _rowname overall_difference overall_explained overall_unexplained
	gen code = "`code'"
	gen group = "`group'"
	gen period = "`period'"
	gen gender = "`gender'"
save "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/clean_eform_`period'", replace
 
 
}
}
}
}
	
// append 
use "$user/_OaxacaBlinder_replication/outputs/ARG/metro/gender0/urban/clean_eform_1", clear
foreach code in ARG BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY  URY {
foreach group in all rural urban skilled b40 {
forvalues period = 1(3)4{	
forvalues gender = 0/1{   

capture	append using "$user/_OaxacaBlinder_replication/outputs/`code'/metro/gender`gender'/`group'/clean_eform_`period'"
}
}
}
}
	
gen periodr = real(period)
drop period
rename periodr period

recode period (4=2)
	
gen genderr = real(gender)
drop gender
rename genderr gender

	duplicates drop

tab code	

keep if _rowname == "b" | _rowname == "ll" | _rowname == "ul"

egen id = group(code period group gender)
reshape wide overall_difference overall_explained overall_unexplained, i(id) j(_rowname) string 

		gen group2 = ""
		replace group2 = "(2) Bottom 40%" if group == "b40"
		replace group2 = "(3) Urban" if group == "urban"
		replace group2 = "(4) Skilled" if group == "skilled"
		replace group2 = "(5) Rural" if group == "rural"

foreach var in overall_differenceb overall_explainedb overall_unexplainedb overall_differencell overall_explainedll overall_unexplainedll overall_differenceul overall_explainedul overall_unexplainedul{
    replace `var' = 100*(`var' - 1)
}
		
save "$user/_OaxacaBlinder_replication/outputs/figures/countrydecomp_gender", replace

foreach code in ARG BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY URY   {
use "$user/_OaxacaBlinder_replication/outputs/countrydecomp_gender", clear
keep if code == "`code'"
save "$user/_OaxacaBlinder_replication/outputs/`code'/incdiffgroup_gender_2periods", replace
}
	
	
*****************************************************************************************************************
// GRAPHS 
	
// regional decomposition chart - eform 

use  "$user/_OaxacaBlinder_replication/outputs/figures/metro_allgroupdiff_2period_eform.dta", clear

keep if group2 == "(1) All" 

encode period2, gen(p)

gen y = 0
 
graph twoway (rbar y diff_end period if diff_end > 0 & diff_ret < 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end > 0 & diff_ret < 0, color(orange) barwidth(0.9))(rbar y diff_end period if diff_end < 0 & diff_ret > 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end < 0 & diff_ret > 0, color(orange) barwidth(0.9))(bar overall_differenceb period if diff_end > 0 & diff_ret > 0, barwidth(0.9) color(eltblue))(rbar overall_differenceb diff_end period if diff_end > 0 & diff_ret > 0, color(orange) barwidth(0.9)) (bar overall_differenceb period, barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell period, color(edkblue)), by(code, note("") row(1) iscale(*1.6))  legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2) region(lwidth(none))) xlabel(1 "First period" 2 "Last period", angle(45) labsize(*1.2)) xtitle("") ytitle(Per Capita Labor Income Gap (%), size(*1.4))
		graph display, ysize(5) xsize(16)
				
************************

use  "$user/_OaxacaBlinder_replication/outputs/figures/metro_allgroupdiff_2period_eform.dta", clear

keep if group2 == "(2) Bottom 40%" 

encode period2, gen(p)

gen y = 0
 
graph twoway (rbar y diff_end period if diff_end > 0 & diff_ret < 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end > 0 & diff_ret < 0, color(orange) barwidth(0.9))(rbar y diff_end period if diff_end < 0 & diff_ret > 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end < 0 & diff_ret > 0, color(orange) barwidth(0.9))(bar overall_differenceb period if diff_end > 0 & diff_ret > 0, barwidth(0.9) color(eltblue))(rbar overall_differenceb diff_end period if diff_end > 0 & diff_ret > 0, color(orange) barwidth(0.9)) (bar overall_differenceb period if diff_end < 0 & diff_ret < 0, barwidth(0.9) color(eltblue))(rbar  diff_end overall_differenceb period if diff_end < 0 & diff_ret < 0, color(orange) barwidth(0.9)) (bar overall_differenceb period, barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell period, color(edkblue)), by(code, note("") row(1) iscale(*1.6))  legend(label(1 "Endowments") label(2 "Returns to endowments") label(9 "Income gap") position(12) row(1) order(9 1 2 ) region(lwidth(none))) xlabel(1 "First period" 2 "Last period", angle(45) labsize(*1.2)) xtitle("") ytitle(Per Capita Labor Income Gap (%), size(*1.4))
		graph display, ysize(5) xsize(16)
			
use  "$user/_OaxacaBlinder_replication/outputs/figures/metro_allgroupdiff_2period_eform.dta", clear

keep if group2 == "(4) Skilled" 

encode period2, gen(p)

gen y = 0
 
graph twoway (rbar y diff_end period if diff_end > 0 & diff_ret < 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end > 0 & diff_ret < 0, color(orange) barwidth(0.9))(rbar y diff_end period if diff_end < 0 & diff_ret > 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end < 0 & diff_ret > 0, color(orange) barwidth(0.9))(bar overall_differenceb period if diff_end > 0 & diff_ret > 0, barwidth(0.9) color(eltblue))(rbar overall_differenceb diff_end period if diff_end > 0 & diff_ret > 0, color(orange) barwidth(0.9)) (bar overall_differenceb period if diff_end < 0 & diff_ret < 0, barwidth(0.9) color(eltblue))(rbar  diff_end overall_differenceb period if diff_end < 0 & diff_ret < 0, color(orange) barwidth(0.9)) (bar overall_differenceb period, barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell period, color(edkblue)), by(code, note("") row(1) iscale(*1.6))  legend(label(1 "Endowments") label(2 "Returns to endowments") label(9 "Income gap") position(12) row(1) order(9 1 2 ) region(lwidth(none))) xlabel(1 "First period" 2 "Last period", angle(45) labsize(*1.2)) xtitle("") ytitle(Per Capita Labor Income Gap (%), size(*1.4))
		graph display, ysize(5) xsize(16)
				
use  "$user/_OaxacaBlinder_replication/outputs/figures/metro_allgroupdiff_2period_eform.dta", clear

keep if group2 == "(5) Rural" 

encode period2, gen(p)

gen y = 0
 
graph twoway (rbar y diff_end period if diff_end > 0 & diff_ret < 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end > 0 & diff_ret < 0, color(orange) barwidth(0.9))(rbar y diff_end period if diff_end < 0 & diff_ret > 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end < 0 & diff_ret > 0, color(orange) barwidth(0.9))(bar overall_differenceb period if diff_end > 0 & diff_ret > 0, barwidth(0.9) color(eltblue))(rbar overall_differenceb diff_end period if diff_end > 0 & diff_ret > 0, color(orange) barwidth(0.9)) (bar overall_differenceb period, barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell period, color(edkblue)), by(code, note("") row(1) iscale(*1.6))  legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2 ) region(lwidth(none))) xlabel(1 "First period" 2 "Last period", angle(45) labsize(*1.2)) xtitle("") ytitle(Per Capita Labor Income Gap (%), size(*1.4))
		graph display, ysize(5) xsize(16)
				
use  "$user/_OaxacaBlinder_replication/outputs/figures/metro_allgroupdiff_2period_eform.dta", clear

keep if group2 == "(3) Urban" 

encode period2, gen(p)

gen y = 0
 
graph twoway (rbar y diff_end period if diff_end > 0 & diff_ret < 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end > 0 & diff_ret < 0, color(orange) barwidth(0.9))(rbar y diff_end period if diff_end < 0 & diff_ret > 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end < 0 & diff_ret > 0, color(orange) barwidth(0.9))(bar overall_differenceb period if diff_end > 0 & diff_ret > 0, barwidth(0.9) color(eltblue))(rbar overall_differenceb diff_end period if diff_end > 0 & diff_ret > 0, color(orange) barwidth(0.9)) (bar overall_differenceb period, barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell period, color(edkblue)), by(code, note("") row(1) iscale(*1.6))  legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2) region(lwidth(none))) xlabel(1 "First period" 2 "Last period", angle(45) labsize(*1.2)) xtitle("") ytitle(Per Capita Labor Income Gap (%), size(*1.4))
		graph display, ysize(5) xsize(16)
						
								
********************************************************
// B40 urban vs rural 

use  "$user/_OaxacaBlinder_replication/outputs/figures/b40_metro_allgroupdiff_2period_eform.dta", clear

keep if group2 == "(1) B40 Urban" 

encode period2, gen(p)

twoway (bar overall_differenceb p, barwidth(0.9) color(edkblue))(rcap overall_differenceul overall_differencell p, color(edkblue)), by(code, note("") row(1) legend(off) iscale(*1.6)) xlabel(1 "First period" 2 "Last period", angle(45)) xtitle("") ytitle(Per capita Labor Income Gap (%), size(*1.4)) ylabel(0(10)40) 

		graph display, ysize(5) xsize(16)
	
gen y = 0
 
graph twoway (rbar y diff_end period if diff_end > 0 & diff_ret < 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end > 0 & diff_ret < 0, color(orange) barwidth(0.9))(rbar y diff_end period if diff_end < 0 & diff_ret > 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end < 0 & diff_ret > 0, color(orange) barwidth(0.9))(bar overall_differenceb period if diff_end > 0 & diff_ret > 0, barwidth(0.9) color(eltblue))(rbar overall_differenceb diff_end period if diff_end > 0 & diff_ret > 0, color(orange) barwidth(0.9)) (bar overall_differenceb period, barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell period, color(edkblue)), by(code, note("") row(1) iscale(*1.6))  legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2) region(lwidth(none))) xlabel(1 "First period" 2 "Last period", angle(45) labsize(*1.2)) xtitle("") ytitle(Per Capita Labor Income Gap (%), size(*1.4))
		graph display, ysize(5) xsize(16)
		
use  "$user/_OaxacaBlinder_replication/outputs/figures/b40_metro_allgroupdiff_2period_eform.dta", clear

keep if group2 == "(2) B40 Rural" 

encode period2, gen(p)
	
gen y = 0
 
graph twoway (rbar y diff_end period if diff_end > 0 & diff_ret < 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end > 0 & diff_ret < 0, color(orange) barwidth(0.9))(rbar y diff_end period if diff_end < 0 & diff_ret > 0, color(eltblue) barwidth(0.9)) (rbar diff_ret y period if diff_end < 0 & diff_ret > 0, color(orange) barwidth(0.9))(bar overall_differenceb period if diff_end > 0 & diff_ret > 0, barwidth(0.9) color(eltblue))(rbar overall_differenceb diff_end period if diff_end > 0 & diff_ret > 0, color(orange) barwidth(0.9)) (bar overall_differenceb period, barwidth(0.9) fcolor(none) lcolor(edkblue))(rcap overall_differenceul overall_differencell period, color(edkblue)), by(code, note("") row(1) iscale(*1.6))  legend(label(1 "Endowments") label(2 "Returns to endowments") label(7 "Income gap") position(12) row(1) order(7 1 2) region(lwidth(none))) xlabel(1 "First period" 2 "Last period", angle(45) labsize(*1.2)) xtitle("") ytitle(Per Capita Labor Income Gap (%), size(*1.4))
		graph display, ysize(5) xsize(16)
		
								
**************************************************************************************
** BY GENDER

** URBAN
	
use "$user/_OaxacaBlinder_replication/outputs/figures/countrydecomp_gender", clear

gen p1 = period - 0.2
gen p2 = period + 0.2 

keep if group2 == "(3) Urban" 

graph twoway (bar overall_differenceb p1 if gender == 0, color(cranberry) barwidth(0.35) base(0)) (rcap overall_differencell overall_differenceul p1 if gender == 0, color(edkblue))(bar overall_differenceb p2 if gender == 1, color(eltblue) barwidth(0.35)) (rcap overall_differencell overall_differenceul p2 if gender == 1, color(edkblue)), by(code, note("") iscale(*1.6) row(1)) xlabel( 1 "First period" 2 "Last period", labsize(*1.2) angle(45)) xtitle("") ytitle(Individual Labor Income Gap (%)) legend(label(1 "Women") label(3 "Men") pos(6) order(1 3) row(1) size(*1.4)) 
	graph display, ysize(5) xsize(15)
	
** RURAL
	
use "$user/_OaxacaBlinder_replication/outputs/figures/countrydecomp_gender", clear
	
gen p1 = period - 0.2
gen p2 = period + 0.2 

keep if group2 == "(5) Rural" 


graph twoway (bar overall_differenceb p1 if gender == 0, color(cranberry) barwidth(0.35) base(0)) (rcap overall_differencell overall_differenceul p1 if gender == 0, color(edkblue))(bar overall_differenceb p2 if gender == 1, color(eltblue) barwidth(0.35)) (rcap overall_differencell overall_differenceul p2 if gender == 1, color(edkblue)), by(code, note("") iscale(*1.6) row(1)) xlabel( 1 "First period" 2 "Last period", labsize(*1.2) angle(45)) xtitle("") ytitle(Individual Labor Income Gap (%)) legend(label(1 "Women") label(3 "Men") pos(6) order(1 3) row(1) size(*1.4)) 
	graph display, ysize(5) xsize(15)

** BOTTOM 40%
	
use "$user/_OaxacaBlinder_replication/outputs/figures/countrydecomp_gender", clear
	
gen p1 = period - 0.2
gen p2 = period + 0.2 

keep if group2 == "(2) Bottom 40%"

graph twoway (bar overall_differenceb p1 if gender == 0, color(cranberry) barwidth(0.35) base(0)) (rcap overall_differencell overall_differenceul p1 if gender == 0, color(edkblue))(bar overall_differenceb p2 if gender == 1, color(eltblue) barwidth(0.35)) (rcap overall_differencell overall_differenceul p2 if gender == 1, color(edkblue)), by(code, note("") iscale(*1.6) row(1)) xlabel( 1 "First period" 2 "Last period", labsize(*1.2) angle(45)) xtitle("") ytitle(Individual Labor Income Gap (%)) legend(label(1 "Women") label(3 "Men") pos(6) order(1 3) row(1) size(*1.4)) 
	graph display, ysize(5) xsize(15)
	
** SKILLED

use "$user/_OaxacaBlinder_replication/outputs/figures/countrydecomp_gender", clear
	
gen p1 = period - 0.2
gen p2 = period + 0.2 

keep if group2 == "(4) Skilled"

graph twoway (bar overall_differenceb p1 if gender == 0, color(cranberry) barwidth(0.35) base(0)) (rcap overall_differencell overall_differenceul p1 if gender == 0, color(edkblue))(bar overall_differenceb p2 if gender == 1, color(eltblue) barwidth(0.35)) (rcap overall_differencell overall_differenceul p2 if gender == 1, color(edkblue)), by(code, note("") iscale(*1.6) row(1)) xlabel( 1 "First period" 2 "Last period", labsize(*1.2) angle(45)) xtitle("") ytitle(Individual Labor Income Gap (%)) legend(label(1 "Women") label(3 "Men") pos(6) order(1 3) row(1) size(*1.4)) 
	graph display, ysize(5) xsize(15)
	
