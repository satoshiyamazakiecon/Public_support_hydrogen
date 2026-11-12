*******************************************************************************
* FILE: sensitivity_greenblue.do
*
* PURPOSE: Sensitivity analysis (WTP for green and blue H scenarios)
*
* Data INPUT: hydro_full_panel.dta
*
* OUTPUT:   results_sensitivity_green_[certain,all,income, shift].csv
*           results_sensitivity_WTP_green__[certain,all,income, shift].csv
*            
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths (Note: $data and $output must be defined in config.do)
do "code/stata/config.do"

* call program
include "code/stata/wtp_interact.do"

* define controls
local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

* ------------------------------------------------------------------------------
* EXCLUDE UNCERTAIN RESPONSES
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

keep if !inlist(certainty, 3, 4) & !missing(bill)

* Conditional median WTP at sample mean covariates
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(green) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* Respondent-specific conditional median WTP 
qui xtprobit ans_all c.lbid_all##i.green step2 anchor `controls', re vce(cluster responseid)
keep if e(sample)

predict double xb, xb
gen double xb_nobid = xb ///
    - _b[lbid_all]*lbid_all ///
    - _b[1.green#c.lbid_all]*green*lbid_all ///
	- _b[step2]*step2 ///
	- _b[anchor]*anchor
	
bysort responseid: egen double  xb_ind = mean(xb_nobid)
gen double beta_bid_ind = _b[lbid_all] + _b[1.green#c.lbid_all]*green
gen double wtp_ind = exp(-xb_ind/beta_bid_ind)

bysort responseid: keep if _n == 1

* save
keep responseid wtp_ind green
export delimited using "${output}\results_sensitivity_WTP_green_certain.csv", replace
	
* ------------------------------------------------------------------------------
* INCLUDE ALL RESPONSES
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

keep if !missing(bill)	

* Conditional median WTP at sample mean covariates	
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(green) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* Respondent-specific conditional median WTP  
qui xtprobit ans_all c.lbid_all##i.green step2 anchor `controls', re vce(cluster responseid)
keep if e(sample)

predict double xb, xb
gen double xb_nobid = xb ///
    - _b[lbid_all]*lbid_all ///
    - _b[1.green#c.lbid_all]*green*lbid_all ///
	- _b[step2]*step2 ///
	- _b[anchor]*anchor
	
bysort responseid: egen double  xb_ind = mean(xb_nobid)
gen double beta_bid_ind = _b[lbid_all] + _b[1.green#c.lbid_all]*green
gen double wtp_ind = exp(-xb_ind/beta_bid_ind)

bysort responseid: keep if _n == 1

* save
keep responseid wtp_ind green
export delimited using "${output}\results_sensitivity_WTP_green_all.csv", replace
	
* ------------------------------------------------------------------------------
* INCLUDE INCOME
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

keep if !inlist(certainty, 4) & !missing(bill)	& !missing(income)

* Conditional median WTP at sample mean covariates	
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(green) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* Respondent-specific conditional median WTP 
qui xtprobit ans_all c.lbid_all##i.green step2 anchor `controls' income, re vce(cluster responseid)
keep if e(sample)

predict double xb, xb
gen double xb_nobid = xb ///
    - _b[lbid_all]*lbid_all ///
    - _b[1.green#c.lbid_all]*green*lbid_all ///
	- _b[step2]*step2 ///
	- _b[anchor]*anchor
	
bysort responseid: egen double  xb_ind = mean(xb_nobid)
gen double beta_bid_ind = _b[lbid_all] + _b[1.green#c.lbid_all]*green
gen double wtp_ind = exp(-xb_ind/beta_bid_ind)

bysort responseid: keep if _n == 1

* save
keep responseid wtp_ind green
export delimited using "${output}\results_sensitivity_WTP_green_income.csv", replace

* ------------------------------------------------------------------------------
* SHIFT-ONLY MODEL
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

keep if !inlist(certainty, 4) & !missing(bill)

* Conditional median WTP at sample mean covariates
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(green) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* Respondent-specific conditional median WTP 
qui xtprobit ans_all c.lbid_all##i.green step2 `controls', re vce(cluster responseid)
keep if e(sample)

predict double xb, xb
gen double xb_nobid = xb ///
    - _b[lbid_all]*lbid_all ///
    - _b[1.green#c.lbid_all]*green*lbid_all ///
	- _b[step2]*step2
	
bysort responseid: egen double  xb_ind = mean(xb_nobid)
gen double beta_bid_ind = _b[lbid_all] + _b[1.green#c.lbid_all]*green
gen double wtp_ind = exp(-xb_ind/beta_bid_ind)

bysort responseid: keep if _n == 1

* save
keep responseid wtp_ind green
export delimited using "${output}\results_sensitivity_WTP_green_shift.csv", replace
	