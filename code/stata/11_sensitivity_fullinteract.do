*******************************************************************************
* FILE: sensitivity_fullinteract.do
*
* PURPOSE: Sensitivity analysis (fully interacted modl)
*
* Data INPUT: hydro_full_panel.dta
*
* OUTPUT:   results_sensitivity_fullinteract_elec_shortage_[certain,all,income,shift].csv
*           results_sensitivity_fullinteract_energy_develop_[certain,all,income,shift].csv
*           results_sensitivity_fullinteract_funds_[certain,all,income,shift].csv
*           results_sensitivity_fullinteract_elec_price_[certain,all,income,shift].csv
*           results_sensitivity_fullinteract_renewable_mitigate_[certain,all,income,shift].csv
*           results_sensitivity_fullinteract_renewable_employ_[certain,all,income,shift].csv
*           results_sensitivity_fullinteract_renewable_noise_[certain,all,income,shift].csv
*           results_sensitivity_fullinteract_renewable_economic_[certain,all,income,shift].csv
*            
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths (Note: $data and $output must be defined in config.do)
do "code/stata/config.do"

* call program
include "code/stata/wtp_fullinteract.do"

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
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(climate_change) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* CLIMATE CHANGE HUMAN CAUSE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(cause_human) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_health) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* ELECTRICITY SHORTAGE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_shortage) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* ENERGY DEVELOPMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(energy_develop) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* GOVERNMENT FUNDS 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(funds) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* ELECTRICITY PRICES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_price) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_mitigate) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_employ) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_noise) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_economic) ///
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
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(climate_change) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* CLIMATE CHANGE HUMAN CAUSE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(cause_human) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_health) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* ELECTRICITY SHORTAGE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_shortage) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* ENERGY DEVELOPMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(energy_develop) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* GOVERNMENT FUNDS 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(funds) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* ELECTRICITY PRICES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_price) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_mitigate) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_employ) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_noise) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_economic) ///
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
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(climate_change) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* CLIMATE CHANGE HUMAN CAUSE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(cause_human) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_health) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_economic) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* ELECTRICITY SHORTAGE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_shortage) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* ENERGY DEVELOPMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(energy_develop) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* GOVERNMENT FUNDS 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(funds) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* ELECTRICITY PRICES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_price) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_mitigate) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_employ) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_noise) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_economic) ///
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
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(climate_change) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* CLIMATE CHANGE HUMAN CAUSE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(cause_human) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_health) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_economic) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* ELECTRICITY SHORTAGE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_shortage) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* ENERGY DEVELOPMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(energy_develop) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* GOVERNMENT FUNDS 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(funds) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* ELECTRICITY PRICES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_price) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_mitigate) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_employ) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_noise) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_economic) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	