*******************************************************************************
* FILE: sensitivity_MWTP.do
*
* PURPOSE: Sensitivity analysis (marginal effects on baseline conditional median WTP)
*
* Data INPUT: hydro_full_panel.dta
*
* OUTPUT:   results_marginal_WTP_sensitivity_continuous.csv
*           results_marginal_WTP_sensitivity_discrete.csv
*           results_marginal_WTP_sensitivity_states.csv
*
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths 
do "code/stata/config.do"

* Load data
use "${output}\hydro_full_panel.dta", clear
xtset responseid step2

* Controls
local core   "bill age female uni_path vet knowledge location"
local states "VIC QLD WA SA TAS ACT NT"
local controls "`core' `states'"

*******************************************************************************
* PROGRAM TO CALCULATE MARGINAL EFFECTS ON BASELINE CONDITIONAL MEDIAN WTP
*******************************************************************************

capture program drop marginal_wtp

program define marginal_wtp

    args scenario condition controls followup_model

    * Default to shift-anchoring; optionally estimate the shift-only model.
    if "`followup_model'" == "" {
        local followup_model "shift_anchor"
    }

    if "`followup_model'" == "shift_only" {
        local followup_terms "step2"
    }
    else if "`followup_model'" == "shift_anchor" {
        local followup_terms "step2 anchor"
    }
    else {
        display as error "Unknown follow-up model: `followup_model'"
        exit 198
    }

    * -------------------------------------------------------------------------
    * Estimate model (follow-up terms remain in the regression)
    * -------------------------------------------------------------------------

    qui xtprobit ans_all lbid_all `followup_terms' `controls' ///
        if `condition', ///
        re vce(cluster responseid)

    estimates store model_`scenario'

    * -------------------------------------------------------------------------
    * Calculate means using estimation sample
    * -------------------------------------------------------------------------

    foreach var of varlist `controls' {
        qui summ `var' if e(sample)
        scalar m_`var' = r(mean)
    }

    * -------------------------------------------------------------------------
    * Construct baseline Xb at sample means (step2 = 0; anchor = 0)
    * -------------------------------------------------------------------------

    local xb "_b[_cons]"

    foreach var of local controls {
        local xb "`xb' + _b[`var']*m_`var'"
    }

    * -------------------------------------------------------------------------
    * Continuous variables
    * -------------------------------------------------------------------------

    estimates restore model_`scenario'

    if strpos(" `controls' ", " income ") > 0 {

    nlcom ///
        (mwtp_bill: ///
            -(_b[bill]/_b[lbid_all]) * exp(-(`xb')/_b[lbid_all])) ///
        (mwtp_age: ///
            -(_b[age]/_b[lbid_all]) * exp(-(`xb')/_b[lbid_all])) ///
        (mwtp_knowledge: ///
            -(_b[knowledge]/_b[lbid_all]) * exp(-(`xb')/_b[lbid_all])) ///
        (mwtp_income: ///
            -(_b[income]/_b[lbid_all]) * exp(-(`xb')/_b[lbid_all])), ///
        post
    }

    else {

    nlcom ///
        (mwtp_bill: ///
            -(_b[bill]/_b[lbid_all]) * exp(-(`xb')/_b[lbid_all])) ///
        (mwtp_age: ///
            -(_b[age]/_b[lbid_all]) * exp(-(`xb')/_b[lbid_all])) ///
        (mwtp_knowledge: ///
            -(_b[knowledge]/_b[lbid_all]) * exp(-(`xb')/_b[lbid_all])), ///
        post
    }

    estimates store continuous_`scenario'

    * -------------------------------------------------------------------------
    * Discrete variables
    * -------------------------------------------------------------------------

    local xb_female   "(`xb') - _b[female]*m_female"
    local xb_edu0     "(`xb') - _b[uni_path]*m_uni_path - _b[vet]*m_vet"
    local xb_location "(`xb') - _b[location]*m_location"

    estimates restore model_`scenario'

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

    estimates store discrete_`scenario'

    * -------------------------------------------------------------------------
    * State effects relative to NSW
    * -------------------------------------------------------------------------

    estimates restore model_`scenario'

    * Baseline Xb for NSW: all state dummies = 0; follow-up effects = 0
    local xb_NSW "_b[_cons]"

    foreach var of local controls {

        if !inlist("`var'", ///
            "VIC","QLD","WA","SA","TAS","ACT","NT") {

            local xb_NSW "`xb_NSW' + _b[`var']*m_`var'"
        }
    }

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

    estimates store states_`scenario'

end

*******************************************************************************
* CALCULATE MARGINAL WTP
*******************************************************************************

* Exclude all uncertain responses
marginal_wtp certain ///
    "!inlist(certainty,3,4) & !missing(bill)" ///
    "`controls'"

* Include all respondents
marginal_wtp all ///
    "!missing(bill)" ///
    "`controls'"

* Include income
local controls_income "`controls' income"
marginal_wtp income ///
    "certainty != 4 & !missing(bill)" ///
    "`controls_income'"

* Shift-only model: same sample and controls as the preferred model,
* excluding the anchoring term from the estimation specification.
marginal_wtp shift_only ///
    "certainty != 4 & !missing(bill)" ///
    "`controls'" ///
    "shift_only"

*******************************************************************************
* SAVE
*******************************************************************************

esttab continuous_certain ///
       continuous_all ///
       continuous_income ///
       continuous_shift_only ///
       using "${output}\results_marginal_WTP_sensitivity_continuous.csv", ///
       replace ///
       cells("b(star fmt(3)) se(par fmt(3))") ///
       csv ///
       mtitles("Certain only" "All respondents" "Income control" "Shift-only") ///
       star(* 0.10 ** 0.05 *** 0.01)
	   
esttab discrete_certain ///
       discrete_all ///
       discrete_income ///
       discrete_shift_only ///
       using "${output}\results_marginal_WTP_sensitivity_discrete.csv", ///
       replace ///
       cells("b(star fmt(3)) se(par fmt(3))") ///
       csv ///
       mtitles("Certain only" "All respondents" "Income control" "Shift-only") ///
       star(* 0.10 ** 0.05 *** 0.01)

esttab states_certain ///
       states_all ///
       states_income ///
       states_shift_only ///
       using "${output}\results_marginal_WTP_sensitivity_states.csv", ///
       replace ///
       cells("b(star fmt(3)) se(par fmt(3))") ///
       csv ///
       mtitles("Certain only" "All respondents" "Income control" "Shift-only") ///
       star(* 0.10 ** 0.05 *** 0.01)