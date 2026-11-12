********************************************************************************
* FILE: table_CV_response.do
*
* PURPOSE:  Create a table summarise CV responses by bid amount
*
* Data INPUT: hydro_base_panel
*
* OUTPUT:   Table_CVresponse.xlsx
*
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths (Note: $data and $output must be defined in config.do)
do "code/stata/config.do"

* Import data
use "${output}\hydro_base_panel.dta", clear

* Split into Q1 and Q2 halves, identified by which bid is non-zero
preserve
    keep if step1_bid != 0                   // Q1 rows
    rename ans_all   ans1
    rename step1_bid bid1
    keep responseid ans1 bid1
	save "${output}\q1_temp.dta", replace
restore

preserve
    keep if step2_bid != 0                   // Q2 rows
    rename ans_all   ans2
    rename step2_bid bid2
    keep responseid ans2 bid2
	save "${output}\q2_temp.dta", replace
restore

* Merge into one wide dataset
use "${output}\q1_temp.dta", clear
merge 1:1 responseid using "${output}\q2_temp.dta"

* Check (_merge should be 3 (matched) for every observation)
tab _merge
drop _merge

* Define the four response categories
gen response = .
replace response = 1 if ans1==1 & ans2==1     // Yes-Yes
replace response = 2 if ans1==1 & ans2==0     // Yes-No
replace response = 3 if ans1==0 & ans2==1     // No-Yes
replace response = 4 if ans1==0 & ans2==0     // No-No

label define resp_lbl 1 "Yes-Yes" 2 "Yes-No" 3 "No-Yes" 4 "No-No"
label values response resp_lbl

* Response table by starting bid (bid1)
* N and row % of each response category, for each starting bid level
tab bid1 response, row

tab bid1 response

* Export the table to Excel ----
preserve
    collapse (count) n=responseid, by(bid1 response)
    reshape wide n, i(bid1) j(response)
    rename n1 n_YesYes
    rename n2 n_YesNo
    rename n3 n_NoYes
    rename n4 n_NoNo
    egen total = rowtotal(n_YesYes n_YesNo n_NoYes n_NoNo)
    export excel bid1 n_YesYes n_YesNo n_NoYes n_NoNo total ///
        using "${output}\Table_CVresponse.xlsx", firstrow(variables) replace
restore
