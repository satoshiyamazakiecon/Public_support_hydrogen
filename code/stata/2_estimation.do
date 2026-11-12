*******************************************************************************
* FILE: estimation.do
*
* PURPOSE: Estimate various CV models and WTPs
*
* Data INPUT: hydro_base_1st.dta
*             hydro_base_panel.dta
*
* OUTPUT:   results_single.csv
*           results_panel.csv
*           results_WTP_atMean.csv
*           results_WTP_forRespondents.csv
*
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths (Note: $data and $output must be defined in config.do)
do "code/stata/config.do"

********************************************************************************
* SECTION 1: MODEL ESTIMATION
********************************************************************************

local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

* ------------------------------------------------------------------------------
* Single Bounded Model
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_base_1st.dta", clear

* check multicolliniarity
corr bill age female uni_path vet knowledge location 
qui reg ans_all bill age female uni_path vet knowledge location 
vif 

* model estimation
eststo clear
eststo:probit ans_all lbid_all `controls', vce(robust)

esttab using "${output}\results_single.csv", b(a3) se(a3) scalars(ll aic) star(* 0.10 ** 0.05 *** 0.01) replace 

* ------------------------------------------------------------------------------
* Double Bounded Model
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_base_panel.dta", clear
xtset responseid step2

* model estimation
eststo clear
* random effect probit
eststo: xtprobit ans_all lbid_all `controls', re vce(cluster responseid)
* shift
eststo: xtprobit ans_all lbid_all step2 `controls', re vce(cluster responseid)
* anchoring
eststo: xtprobit ans_all lbid_all anchor `controls', re vce(cluster responseid)
* shift-anchoring
eststo: xtprobit ans_all lbid_all step2 anchor `controls', re vce(cluster responseid)
estat vce, correlation

esttab using "${output}\results_panel.csv", b(a3) se(a3) scalars(ll aic rho) star(* 0.10 ** 0.05 *** 0.01) replace

* Check the correlation between log bids
preserve

keep responseid step1 lbid_all
reshape wide lbid_all, i(responseid) j(step1)

pwcorr lbid_all1 lbid_all0, sig

restore

********************************************************************************
* SECTION 2:WTP ESTIMATION AT MEAN 
********************************************************************************

* define a table to store WTP
tempfile wtpresults
tempname posth
postfile `posth' ///
    str20 model ///
    double wtp lb ub ///
    using `wtpresults', replace

* ------------------------------------------------------------------------------
* Single Bounded Model
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_base_1st.dta", clear

qui probit ans_all lbid_all `controls', vce(robust)

foreach var in `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
	}

nlcom (WTP_SINGLE: exp( ///
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
    ("Single") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])
clear

* ------------------------------------------------------------------------------
* Double Bounded Model
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_base_panel.dta", clear
xtset responseid step2

* random effect probit
qui xtprobit ans_all lbid_all `controls', re vce(cluster responseid)

foreach var in `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_RE: exp( ///
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
    ("Double") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])

* shift
qui xtprobit ans_all lbid_all step2 `controls', re vce(cluster responseid)

foreach var in step2 anchor `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_SHIFT: exp( ///
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
    ("Shift") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])

* anchoring
qui xtprobit ans_all lbid_all anchor `controls', re vce(cluster responseid)

foreach var in step2 anchor `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_ANC: exp( ///
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
    ("Anchoring") ///
    (T[1,1]) ///
    (T[5,1]) ///
    (T[6,1])
	
* shift-anchoring
qui xtprobit ans_all lbid_all step2 anchor `controls', re vce(cluster responseid)

foreach var in step2 anchor `controls' {
    qui summ `var' if e(sample)
    scalar mean_`var' = r(mean)
}

nlcom (WTP_BOTH: exp( ///
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
    ("Both") ///
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
export delimited using "${output}\results_WTP_atMean.csv", replace

********************************************************************************
* SECTION 3:WTP ESTIMATION FOR EACH RESPONDENT (Shift-Anchoring Model)
********************************************************************************

* import data
use "${output}\hydro_base_panel.dta", clear
xtset responseid step2

local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

* model estimation
qui xtprobit ans_all lbid_all step2 anchor `controls', re vce(cluster responseid)
quadchk
keep if e(sample)

* Remove bid and follow-up response effects
predict double xb, xb
gen double xb_baseline = xb ///
    - _b[lbid_all]*lbid_all ///
    - _b[step2]*step2 ///
    - _b[anchor]*anchor

* Baseline conditional median WTP
gen double wtp_baseline = exp(-xb_baseline/_b[lbid_all])

* Check consistency across the two responses
bysort responseid (step2): ///
    assert abs(wtp_baseline - wtp_baseline[1]) < 1e-8

* Keep one observation per respondent
bysort responseid (step2): keep if _n == 1

* Summary
summarize wtp_baseline, detail

* save
keep responseid bill wtp_baseline
export delimited using "${output}\results_WTP_forRespondents.csv", replace
