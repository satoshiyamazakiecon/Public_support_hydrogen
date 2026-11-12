*******************************************************************************
* FILE: WTP_marginal.do
*
* PURPOSE: Estimation of marginal effects 
*
* Data INPUT: hydro_base_panel.dta
*
* OUTPUT:   results_marginal_WTP.csv
*            
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths (Note: $data and $output must be defined in config.do)
do "code/stata/config.do"

* import data
use "${output}\hydro_base_panel.dta", clear
xtset responseid step2

* define controls
local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

* regression
eststo clear
qui xtprobit ans_all lbid_all step2 anchor `controls', re vce(cluster responseid)
estimates store model

 * calculate the sample means
foreach var in `controls' {
    qui summ `var' if e(sample)
    scalar m_`var' = r(mean)
}

* define covariates
local xb "_b[_cons] + _b[bill]*m_bill + _b[age]*m_age + _b[female]*m_female + _b[uni_path]*m_uni_path + _b[vet]*m_vet + _b[knowledge]*m_knowledge + _b[location]*m_location + _b[VIC]*m_VIC + _b[QLD]*m_QLD + _b[WA]*m_WA + _b[SA]*m_SA + _b[TAS]*m_TAS + _b[ACT]*m_ACT + _b[NT]*m_NT"

* continuous variables
estimates restore model

nlcom (mwtp_bill:      -(_b[bill]/_b[lbid_all])*exp(-(`xb')/_b[lbid_all])) ///
      (mwtp_age:       -(_b[age]/_b[lbid_all])*exp(-(`xb')/_b[lbid_all])) ///
	  (mwtp_knowledge: -(_b[knowledge]/_b[lbid_all])*exp(-(`xb')/_b[lbid_all])), ///
	  post
	  
eststo continuous	  
	  
* discrete variables
local xb_female   "(`xb') - _b[female]*m_female"
local xb_edu0     "(`xb') - _b[uni_path]*m_uni_path - _b[vet]*m_vet"
local xb_location "(`xb') - _b[location]*m_location"

estimates restore model

nlcom ///
    (dwtp_female: ///
        exp(-((`xb_female') + _b[female])/_b[lbid_all]) ///
        - exp(-(`xb_female')/_b[lbid_all])) ///
    (dwtp_uni_path: ///
        exp(-((`xb_edu0') + _b[uni_path])/_b[lbid_all]) ///
        - exp(-(`xb_edu0')/_b[lbid_all])) ///
    (dwtp_vet: ///
        exp(-((`xb_edu0') + _b[vet])/_b[lbid_all]) ///
        - exp(-(`xb_edu0')/_b[lbid_all])) ///
    (dwtp_location: ///
        exp(-((`xb_location') + _b[location])/_b[lbid_all]) ///
        - exp(-(`xb_location')/_b[lbid_all])), ///
	post
	
eststo discrete

* state dummies
local xb_NSW "_b[_cons] + _b[bill]*m_bill + _b[age]*m_age + _b[female]*m_female + _b[uni_path]*m_uni_path + _b[vet]*m_vet + _b[knowledge]*m_knowledge + _b[location]*m_location"
	
estimates restore model

nlcom ///
    (dwtp_VIC: ///
        exp(-((`xb_NSW') + _b[VIC])/_b[lbid_all]) ///
        - exp(-(`xb_NSW')/_b[lbid_all])) ///
    (dwtp_QLD: ///
        exp(-((`xb_NSW') + _b[QLD])/_b[lbid_all]) ///
        - exp(-(`xb_NSW')/_b[lbid_all])) ///
    (dwtp_WA: ///
        exp(-((`xb_NSW') + _b[WA])/_b[lbid_all]) ///
        - exp(-(`xb_NSW')/_b[lbid_all])) ///
    (dwtp_SA: ///
        exp(-((`xb_NSW') + _b[SA])/_b[lbid_all]) ///
        - exp(-(`xb_NSW')/_b[lbid_all])) ///
    (dwtp_TAS: ///
        exp(-((`xb_NSW') + _b[TAS])/_b[lbid_all]) ///
        - exp(-(`xb_NSW')/_b[lbid_all])) ///
    (dwtp_ACT: ///
        exp(-((`xb_NSW') + _b[ACT])/_b[lbid_all]) ///
        - exp(-(`xb_NSW')/_b[lbid_all])) ///
    (dwtp_NT: ///
        exp(-((`xb_NSW') + _b[NT])/_b[lbid_all]) ///
        - exp(-(`xb_NSW')/_b[lbid_all])), ///
	post
	
eststo states  

* save
esttab continuous discrete states using "${output}\results_marginal_WTP.csv", ///
    replace ///
    cells("b(star fmt(3)) se(par fmt(3))") ///
    csv ///
    nonumbers ///
    nomtitles ///
	star(* 0.10 ** 0.05 *** 0.01) 

