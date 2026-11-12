*******************************************************************************
* FILE: WTP_fullinteract.do
*
* PURPOSE: Estimate the fully interacted model and test differences in 
*          attitude-related WTP between the green and blue hydrogen scenarios
*
* Data INPUT: hydro_base_panel.dta
*
* OUTPUT:   results_WTP_fullinteract_climate_change.csv
*           results_WTP_fullinteract_cause_human.csv
*           results_WTP_fullinteract_nega_health.csv
*           results_WTP_fullinteract_nega_economic.csv
*           results_WTP_fullinteract_elec_shortage.csv
*           results_WTP_fullinteract_energy_develop.csv
*           results_WTP_fullinteract_funds.csv
*           results_WTP_fullinteract_elec_price.csv
*           results_WTP_fullinteract_renewable_mitigate.csv
*           results_WTP_fullinteract_renewable_employ.csv
*           results_WTP_fullinteract_renewable_noise.csv
*           results_WTP_fullinteract_renewable_economic.csv
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

* call program
include "code/stata/wtp_fullinteract.do"

* define controls
local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

********************************************************************************
* 1. CLIMATE CHANGE
********************************************************************************

* CLIMATE CHANGE HAPPENING
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(climate_change) ///
    controls(step2 anchor `controls') ///
    id(responseid) 

* CLIMATE CHANGE HUMAN CAUSE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(cause_human) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_health) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(nega_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	
********************************************************************************
* 2. ENERGY
********************************************************************************	

* ELECTRICITY SHORTAGE
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_shortage) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	
* ENERGY DEVELOPMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(energy_develop) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
		
* GOVERNMENT FUNDS 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(funds) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
		
* ELECTRICITY PRICES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(elec_price) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	
* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_mitigate) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	
* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_employ) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	
* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_noise) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
		
* RENEWABLE ENERGY AND ECONOMIES 
wtp_fullinteract, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
	green(green) ///
    attitude(renewable_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid) 
	