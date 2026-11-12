*******************************************************************************
* FILE: sensitivity_climate.do
*
* PURPOSE: Sensitivity analysis (attitudes toward climate change)
*
* Data INPUT: hydro_full_panel.dta
*
* OUTPUT:   results_sensitivity_climate_change_[certain,all,income,shift].csv
*           results_sensitivity_cause_human_[certain,all,income,shift].csv
*           results_sensitivity_nega_health_[certain,all,income,shift].csv
*           results_sensitivity_nega_economic_[certain,all,income,shift].csv
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

* CLIMATE CHANGE HAPPENING
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(climate_change) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* CLIMATE CHANGE HUMAN CAUSE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(cause_human) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_health) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)	

* ------------------------------------------------------------------------------
* INCLUDE ALL RESPONSES
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

keep if !missing(bill)	

* CLIMATE CHANGE HAPPENING
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(climate_change) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* CLIMATE CHANGE HUMAN CAUSE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(cause_human) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_health) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* ------------------------------------------------------------------------------
* INCLUDE INCOME
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

keep if !inlist(certainty, 4) & !missing(bill) & !missing(income)	

* CLIMATE CHANGE HAPPENING
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(climate_change) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* CLIMATE CHANGE HUMAN CAUSE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(cause_human) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_health) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_economic) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* ------------------------------------------------------------------------------
* SHIFT-ONLY MODEL
* ------------------------------------------------------------------------------

* import data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

keep if !inlist(certainty, 4) & !missing(bill)

* CLIMATE CHANGE HAPPENING
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(climate_change) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* CLIMATE CHANGE HUMAN CAUSE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(cause_human) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_health) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_economic) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)	
	