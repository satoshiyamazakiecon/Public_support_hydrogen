*******************************************************************************
* FILE: WTP_hetero.do
*
* PURPOSE: Effects of attitudes toward climate change, energy and hydrogen production methods 
*
* Data INPUT: hydro_base_panel.dta
*
* OUTPUT:   results_WTP_green.csv
*           results_WTP_greenVSblue.csv
*           results_WTP_climate_change.csv
*           results_WTP_cause_human.csv
*           results_WTP_nega_health.csv
*           results_WTP_nega_economic.csv
*           results_WTP_elec_shortage.csv
*           results_WTP_energy_develop.csv
*           results_WTP_funds.csv
*           results_WTP_elec_price.csv
*           results_WTP_renewable_mitigate.csv
*           results_WTP_renewable_employ.csv
*           results_WTP_renewable_noise.csv
*           results_WTP_renewable_economic.csv
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

********************************************************************************
* 1. GREEN VS BLUE
********************************************************************************

* import data
use "${output}\hydro_base_panel.dta", clear
xtset responseid step2

* define controls
local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

* WTP at mean	
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(green) ///
    controls(step2 anchor `controls') ///
    id(responseid)

* Individual WTP model estimation
qui xtprobit ans_all c.lbid_all##i.green step2 anchor `controls', re vce(cluster responseid)
keep if e(sample)

* Joint Wald test: Green vs Blue
test (1.green = 0) (1.green#c.lbid_all = 0)

predict double xb, xb
gen double xb_baseline = xb ///
    - _b[lbid_all]*lbid_all ///
    - _b[1.green#c.lbid_all]*green*lbid_all ///
    - _b[step2]*step2 ///
    - _b[anchor]*anchor

gen double beta_bid_ind = _b[lbid_all] + _b[1.green#c.lbid_all]*green
gen double wtp_ind = exp(-xb_baseline/beta_bid_ind)

bysort responseid (step2): ///
    assert abs(wtp_ind - wtp_ind[1]) < 1e-8
	
bysort responseid (step2): keep if _n == 1

* save
keep responseid wtp_ind green bill
export delimited using "${output}\results_WTP_greenVSblue.csv", replace
	
********************************************************************************
* 2. ATTITUDE TOWARD CLIMATE CHANGE
********************************************************************************

* import data
use "${output}\hydro_base_panel.dta", clear
xtset responseid step2

* define controls
local controls "bill age female uni_path vet knowledge location VIC QLD WA SA TAS ACT NT"

* CLIMATE CHANGE HAPPENING
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(climate_change) ///
    controls(step2 anchor `controls') ///
    id(responseid)

* CLIMATE CHANGE HUMAN CAUSE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(cause_human) ///
    controls(step2 anchor `controls') ///
    id(responseid)
	
* CLIMATE CHANGE IMPACT ON HEALTH
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_health) ///
    controls(step2 anchor `controls') ///
    id(responseid)
	
* CLIMATE CHANGE IMPACT ON ECONOMY
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(nega_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid)	

********************************************************************************
* 3. ATTITUDE TOWARD ENERGY
********************************************************************************

* ELECTRICITY SHORTAGE
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_shortage) ///
    controls(step2 anchor `controls') ///
    id(responseid)
	
* ENERGY DEVELOPMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(energy_develop) ///
    controls(step2 anchor `controls') ///
    id(responseid)
	
* GOVERNMENT FUNDS 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(funds) ///
    controls(step2 anchor `controls') ///
    id(responseid)
	
* ELECTRICITY PRICES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(elec_price) ///
    controls(step2 anchor `controls') ///
    id(responseid)

* RENEWABLE ENERGY AND CLIMATE CHANGE MITIGATION 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_mitigate) ///
    controls(step2 anchor `controls') ///
    id(responseid)

* RENEWABLE ENERGY AND EMPLOYMENT 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_employ) ///
    controls(step2 anchor `controls') ///
    id(responseid)

* RENEWABLE ENERGY AND ENVIRONMENTAL PROBLEM 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_noise) ///
    controls(step2 anchor `controls') ///
    id(responseid)
	
* RENEWABLE ENERGY AND ECONOMIES 
wtp_interact, ///
    depvar(ans_all) ///
    bid(lbid_all) ///
    treat(renewable_economic) ///
    controls(step2 anchor `controls') ///
    id(responseid)


	