global user "C:\Users\wb486315\OneDrive - WBG/Inequality/LAC"

global demographics gender age agesq casado hhsize hh_size_02  hh_size_311  hh_size_1217  hh_size_1859  hh_size_60   //15
global labor i.relab // 5
global educ  i.edattain i.hh_max_edattain //8

// BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY  // add country code below to run all countries

// ALL 
foreach code in COL  { 

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

xi: oaxaca lhh_labinc_pc_ppp11 $demographics $labor $educ i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax detail(demographics: $demographics,  education : $educ, labor: $labor, year: i.year) 

matrix decomp_detail = r(table)

preserve
matsave decomp_detail, p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/all") dropall replace
restore 

}

** Only ARG and URY are in the paper

foreach code in ARG BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY  URY    { 

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

keep if urbano == 1

xi: oaxaca lhh_labinc_pc_ppp11 $demographics $labor $educ  i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax detail(demographics: $demographics,  education : $educ, labor: $labor, year: i.year) 

matrix decomp_detail = r(table)

preserve
matsave decomp_detail, p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/urban") dropall replace
restore 

}

** not in the paper 

foreach code in ARG BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY  URY   { 

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

drop b40*

forvalue year = 2000/2019 {
	_pctile hh_labinc_pc_ppp11 [aweight=pondera] if cohi ==1 & year == `year', p(40) 
	return list
	gen b40_`year' = r(r1)
	}
	
	gen b40 = .
	forvalue year = 2000/2019{
	replace b40 = b40_`year' if year == `year'
	}
	
	drop b40_*
	
	gen b40d = 0
	replace b40d = 1 if hh_labinc_pc_ppp11 < b40

drop if b40d == 0

xi: oaxaca lhh_labinc_pc_ppp11 $demographics $labor $educ i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax detail

matrix decomp_detail = r(table)

preserve
matsave decomp_detail, p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/b40") dropall replace
restore 

}

foreach code in ARG BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY  URY   { 

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

drop if skilled == 0

xi: oaxaca lhh_labinc_pc_ppp11 $demographics $labor $educ i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax detail(demographics: $demographics,  education : $educ, labor: $labor, year: i.year) 

matrix decomp_detail = r(table)

preserve
matsave decomp_detail, p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/skilled") dropall replace
restore 

}


foreach code in  BOL BRA CRI DOM CHL COL ECU HND MEX PAN PER PRY     { 

use "$user/_OaxacaBlinder_replication/inputs/`code'_SEDLACsmall.dta", clear

keep if period == 4
keep if cohh == 1 & cohi == 1
keep if age >= 15
keep if jefe == 1

keep if urbano == 0 | leading1 == 1 // rural against leading

xi: oaxaca lhh_labinc_pc_ppp11 $demographics $labor $educ i.year [aw=pondera], by(noleading1) vce(robust) weight(1) relax detail(demographics: $demographics,  education : $educ, labor: $labor, year: i.year) 

matrix decomp_detail = r(table)

preserve
matsave decomp_detail, p("$user/_OaxacaBlinder_replication/outputs/`code'/metro/rural") dropall replace
restore 

}



