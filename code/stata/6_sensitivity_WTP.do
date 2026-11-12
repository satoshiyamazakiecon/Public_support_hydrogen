*******************************************************************************
* FILE: sensitivity_WTP.do
*
* PURPOSE: Sensitivity analysis (WTP) 
*
* Data INPUT: hydro_full_panel.dta
*
* OUTPUT:   results_sensitivity_regression.csv
*           results_sensitivity_WTP_atMean.csv
*
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths 
do "code/stata/config.do"

* Import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

* define a table to store WTP
tempfile wtpresults
tempname posth
postfile `posth' ///
    str20 model ///
    double wtp lb ub ///
    using `wtpresults', replace
	
* ------------------------------------------------------------------------------
* EXCLUDE UNCERTAIN RESPONSES
* ------------------------------------------------------------------------------
	
eststo: xtprobit ans_all lbid_all step2 anchor `controls' if !inlist(certainty, 3, 4) & !missing(bill), re vce(cluster responseid)

foreach var in `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_unc: exp( ///
    - ( ///
        _b[_cons] + ///
		_b[bill]*mean_bill + ///
        _b[age]*mean_age + ///
        _b[female]*mean_female + ///
        _b[uni_path]*mean_uni_path + ///
        _b[vet]*mean_vet + ///
        _b[knowledge]*mean_knowledge + ///
		_b[location]*mean_location + /// 
        _b[VIC]*mean_VIC + ///
        _b[QLD]*mean_QLD + ///
        _b[WA]*mean_WA + ///
        _b[SA]*mean_SA + ///
        _b[TAS]*mean_TAS + ///
        _b[ACT]*mean_ACT + ///
        _b[NT]*mean_NT ///
      ) / _b[lbid_all] ///
    ) ///
)
matrix T = r(table)
scalar wtp = T[1,1]
scalar lb  = T[5,1]
scalar ub  = T[6,1]

post `posth' ///
    ("No uncertain") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])
	
* ------------------------------------------------------------------------------
* INCLUDE ALL RESPONSES
* ------------------------------------------------------------------------------
	
eststo: xtprobit ans_all lbid_all step2 anchor `controls' if !missing(bill), re vce(cluster responseid)

foreach var in `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_all: exp( ///
    - ( ///
        _b[_cons] + ///
		_b[bill]*mean_bill + ///
        _b[age]*mean_age + ///
        _b[female]*mean_female + ///
        _b[uni_path]*mean_uni_path + ///
        _b[vet]*mean_vet + ///
        _b[knowledge]*mean_knowledge + ///
		_b[location]*mean_location + /// 
        _b[VIC]*mean_VIC + ///
        _b[QLD]*mean_QLD + ///
        _b[WA]*mean_WA + ///
        _b[SA]*mean_SA + ///
        _b[TAS]*mean_TAS + ///
        _b[ACT]*mean_ACT + ///
        _b[NT]*mean_NT ///
      ) / _b[lbid_all] ///
    ) ///
)
matrix T = r(table)
scalar wtp = T[1,1]
scalar lb  = T[5,1]
scalar ub  = T[6,1]

post `posth' ///
    ("All") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])
	
* ------------------------------------------------------------------------------
* INCLUDE INCOME
* ------------------------------------------------------------------------------
	
eststo: xtprobit ans_all lbid_all step2 anchor `controls' income if certainty !=4 & !missing(bill) & !missing(income), re vce(cluster responseid)

foreach var in income `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_inc: exp( ///
    - ( ///
        _b[_cons] + ///
		_b[bill]*mean_bill + ///
        _b[age]*mean_age + ///
        _b[female]*mean_female + ///
        _b[uni_path]*mean_uni_path + ///
        _b[vet]*mean_vet + ///
        _b[knowledge]*mean_knowledge + ///
		_b[location]*mean_location + /// 
        _b[VIC]*mean_VIC + ///
        _b[QLD]*mean_QLD + ///
        _b[WA]*mean_WA + ///
        _b[SA]*mean_SA + ///
        _b[TAS]*mean_TAS + ///
        _b[ACT]*mean_ACT + ///
        _b[NT]*mean_NT + ///
		_b[income]*mean_income ///
      ) / _b[lbid_all] ///
    ) ///
)
matrix T = r(table)
scalar wtp = T[1,1]
scalar lb  = T[5,1]
scalar ub  = T[6,1]

post `posth' ///
    ("Income") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])

* ------------------------------------------------------------------------------
* SHIFT-ONLY MODEL
* ------------------------------------------------------------------------------
	
eststo: xtprobit ans_all lbid_all step2 `controls' if certainty !=4 & !missing(bill), re vce(cluster responseid)

foreach var in `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_shift: exp( ///
    - ( ///
        _b[_cons] + ///
		_b[bill]*mean_bill + ///
        _b[age]*mean_age + ///
        _b[female]*mean_female + ///
        _b[uni_path]*mean_uni_path + ///
        _b[vet]*mean_vet + ///
        _b[knowledge]*mean_knowledge + ///
		_b[location]*mean_location + /// 
        _b[VIC]*mean_VIC + ///
        _b[QLD]*mean_QLD + ///
        _b[WA]*mean_WA + ///
        _b[SA]*mean_SA + ///
        _b[TAS]*mean_TAS + ///
        _b[ACT]*mean_ACT + ///
        _b[NT]*mean_NT  ///
      ) / _b[lbid_all] ///
    ) ///
)
matrix T = r(table)
scalar wtp = T[1,1]
scalar lb  = T[5,1]
scalar ub  = T[6,1]

post `posth' ///
    ("Shift-only") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])	
	
postclose `posth'

use `wtpresults', clear
gen WTP_CI = string(wtp,"%9.2f") + ///
    " (" + string(lb,"%9.2f") + ///
    ", " + string(ub,"%9.2f") + ")"

list, noobs

* save
keep model WTP_CI
export delimited using "${output}\results_sensitivity_WTP_atMean.csv", replace

esttab using "${output}\results_sensitivity_regression.csv", b(a3) se(a3) scalars(ll aic) star(* 0.10 ** 0.05 *** 0.01) replace 

