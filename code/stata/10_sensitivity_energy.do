*******************************************************************************
* FILE: sensitivity_energy.do
*
* PURPOSE: Sensitivity analysis (attitudes toward energy)
*
* Data INPUT: hydro_full_panel.dta
*
* OUTPUT:   results_sensitivity_elec_shortage_[certain,all,income,shift].csv
*           results_sensitivity_energy_develop_[certain,all,income,shift].csv
*           results_sensitivity_funds_[certain,all,income,shift].csv
*           results_sensitivity_elec_price_[certain,all,income,shift].csv
*           results_sensitivity_renewable_mitigate_[certain,all,income,shift].csv
*           results_sensitivity_renewable_employ_[certain,all,income,shift].csv
*           results_sensitivity_renewable_noise_[certain,all,income,shift].csv
*           results_sensitivity_renewable_economic_[certain,all,income,shift].csv
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

* ELECTRICITY SHORTAGE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_shortage) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* ENERGY DEVELOPMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(energy_develop) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* GOVERNMENT FUNDS 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(funds) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* ELECTRICITY PRICES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_price) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_mitigate) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_employ) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_noise) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(certain)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_economic) ///
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

* ELECTRICITY SHORTAGE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_shortage) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* ENERGY DEVELOPMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(energy_develop) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* GOVERNMENT FUNDS 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(funds) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* ELECTRICITY PRICES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_price) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_mitigate) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_employ) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_noise) ///
    controls(step2 anchor `controls') ///
    id(responseid) ///
    sensitivity(all)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_economic) ///
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

* ELECTRICITY SHORTAGE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_shortage) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* ENERGY DEVELOPMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(energy_develop) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* GOVERNMENT FUNDS 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(funds) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* ELECTRICITY PRICES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_price) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_mitigate) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_employ) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_noise) ///
    controls(step2 anchor `controls' income) ///
    id(responseid) ///
    sensitivity(income)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_economic) ///
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

* ELECTRICITY SHORTAGE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_shortage) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* ENERGY DEVELOPMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(energy_develop) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* GOVERNMENT FUNDS 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(funds) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* ELECTRICITY PRICES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_price) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_mitigate) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_employ) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_noise) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_economic) ///
    controls(step2 `controls') ///
    id(responseid) ///
    sensitivity(shift)
	