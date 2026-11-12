********************************************************************************
* FILE: data_cleaning.do
*
* PURPOSE:  Data cleaning and preparation
*
* Data INPUT: L6503a Hydrogen MAIN Excel Labelled Data 20250226.xlsx
*
* OUTPUT:   hydro_full_1st.dta
*           hydro_full_2nd.dta
*           hydro_full_panel.dta
*           hydro_base_1st.dta
*           hydro_base_panel.dta
*
********************************************************************************

version 19.5
clear all
set more off

cd "`: environment USERPROFILE'\GitHub\Australia_Hydrogen_WTP\"

* Load local file paths (Note: $data and $output must be defined in config.do)
do "code/stata/config.do"

import excel using ///
    "${data}\L6503a Hydrogen MAIN Excel Labelled Data 20250226.xlsx", ///
    firstrow clear

********************************************************************************
* SECTION 0: RENAME VARIABLES
********************************************************************************

* CLIMATE CHANGE ATTITUDE
rename Q22Climatechangingishappen climate_change_cha
rename Q22Humanactivitiesarethem  cause_human_cha
rename Q22Climatechangeadverselya nega_health_cha
rename Q22Climatechangehasnegativ nega_economic_cha

* ENERGY ATTITUDE
rename Q23Electricityshortageswill elec_shortage_cha
rename Q23Thedevelopmentandsupply  energy_develop_cha
rename Q23Thegovernmentshouldallo  funds_cha
rename Q23Electricitypriceswillri  elec_price_cha
rename Q23Renewableenergyproductio renewable_mitigate_cha
rename Q23Theproductionofrenewabl renewable_employ_cha
rename Q23Theconstructionoffacili renewable_noise_cha
rename AU renewable_economic_cha

* EDUCATION
rename Q33Lastlywewouldliketoa education_cha

* INCOME
rename Q37Whatwouldyousaytheapp income_cha

* ELECTRICITY BILL
rename Q12Approximatelyhowmuchdo bill_cha
rename Q12otherPleaseentertheamo bill_open
   
 * CV ANSWER CERTAINTY
rename Q15Pleaseindicatehowcertai certainty_cha

* RESIDENCE STATE
rename State state

* AGE
rename Q31Whatisyourage age     

* GENDER
rename Q32Howdoyoudescribeyourg gender_char             

* KNOWLEDGE ABOUT HYDROGEN
rename Q11Pleaseindicatehowmanyo knowledge

* CV RESPONSES 
rename hQ13amountAdditionalpermon bid_first
rename Q13wouldyoubewillingtopa   ans_first_cha
rename hQ14amountAdditionalpermon bid_second
rename Q14Wouldyoubewillingtopa   ans_second_cha
rename hQ12state project_location       
rename Q16Youanswerednotoboth CVnono_reasons	   
 
********************************************************************************
* SECTION 1: VARIABLE CONSTRUCTION
********************************************************************************

* ------------------------------------------------------------------------------
* Climate Change Attitudes
* ------------------------------------------------------------------------------

* Dummy = 1 if Agree or Strongly Agree
foreach var in climate_change cause_human nega_health nega_economic {
	tab `var'_cha, missing
    gen `var' = (`var'_cha == "Agree" | `var'_cha == "Strongly agree")
	tab `var', missing
}

label var climate_change  "Believes climate change is happening (1=Yes)"
label var cause_human     "Believes humans cause climate change (1=Yes)"
label var nega_health     "Believes climate change harms human health (1=Yes)"
label var nega_economic   "Believes climate change harms economy (1=Yes)"

* Ordinal variable
foreach v of varlist climate_change cause_human nega_health nega_economic {
    gen `v'_ord = .
    replace `v'_ord = 1 if `v'_cha == "Strongly disagree"
    replace `v'_ord = 2 if `v'_cha == "Disagree"
    replace `v'_ord = 3 if `v'_cha == "I don't know"
    replace `v'_ord = 4 if `v'_cha == "Agree"
    replace `v'_ord = 5 if `v'_cha == "Strongly agree"
	drop `v'_cha

    label var `v'_ord "1:Strongly disagree 2:Disagree 3:I don't know 4:Agree 5:Strongly agree"
}

* ------------------------------------------------------------------------------
* Energy Attitudes
* ------------------------------------------------------------------------------

foreach var in elec_shortage energy_develop funds elec_price renewable_mitigate renewable_employ renewable_noise renewable_economic {
	tab `var'_cha, missing
    gen `var' = (`var'_cha == "Agree" | `var'_cha == "Strongly agree")
	tab `var', missing
}

label var elec_shortage       "Perceived risk of electricity shortage (1=Yes)"
label var energy_develop      "Importance of developing cheap and abundant energy (1=Yes)"
label var funds               "Support public funding of clean energy (1=Yes)"
label var elec_price          "Concern about electricity price rises from renewables (1=Yes)"
label var renewable_mitigate  "Renewables mitigate climate change (1=Yes)"
label var renewable_employ    "Renewables create employment (1=Yes)"
label var renewable_noise     "Renewables cause noise problems (1=Yes)"
label var renewable_economic  "Renewables benefit the economy (1=Yes)"

* Ordinal variable
foreach v of varlist elec_shortage energy_develop funds elec_price renewable_mitigate renewable_employ renewable_noise renewable_economic {
    gen `v'_ord = .
    replace `v'_ord = 1 if `v'_cha == "Strongly disagree"
    replace `v'_ord = 2 if `v'_cha == "Disagree"
    replace `v'_ord = 3 if `v'_cha == "I don't know"
    replace `v'_ord = 4 if `v'_cha == "Agree"
    replace `v'_ord = 5 if `v'_cha == "Strongly agree"
	drop `v'_cha

    label var `v'_ord "1:Strongly disagree 2:Disagree 3:I don't know 4:Agree 5:Strongly agree"
}

* ------------------------------------------------------------------------------
* Education 
* ------------------------------------------------------------------------------

tab education_cha, missing
gen education = .
replace education = 1 if education_cha == "Primary School"
replace education = 2 if education_cha == "Secondary School"
replace education = 3 if education_cha == "Certificate – level I or level II"
replace education = 4 if education_cha == "Certificate – level III or level IV"
replace education = 5 if education_cha == "Advanced Certificate, Associate Diploma, Diploma or Advanced Diploma"
replace education = 6 if education_cha == "Associate Degree"
replace education = 7 if education_cha == "Bachelor Degree or Bachelor Degree with Honours"
replace education = 8 if education_cha == "Graduate Certificate or Graduate Diploma"
replace education = 9 if education_cha == "Postgraduate Degree"

drop education_cha
label var education "Education level (1=Primary School … 9=Postgraduate)"

tab education, missing

* Three-category pathway variable
gen pathway = .
replace pathway = 0 if education == 1 | education == 2  // No post-secondary
replace pathway = 1 if inlist(education, 3, 4, 5)       // VET (Cert I-IV, Diploma/Adv Diploma)
replace pathway = 2 if inlist(education, 6, 7, 8, 9)    // University (Assoc Degree through Postgrad)

label define pathway_lbl 0 "No post-secondary" 1 "VET" 2 "University"
label values pathway pathway_lbl
label var pathway "Education pathway: none/VET/university"

tab pathway, missing

gen no_postsec = (pathway == 0)
label var no_postsec "No post-secondary education"

gen vet = (pathway == 1)
label var vet "VET qualification (Cert I-IV, Diploma)"

gen uni_path = (pathway == 2)
label var uni_path "University qualification (Assoc Degree or above)"

* ------------------------------------------------------------------------------
* Household Income
* ------------------------------------------------------------------------------

gen income = .
replace income =  10000 if income_cha == "$1 - $19,999 per year ($1 - $379 per week)"
replace income =  25000 if income_cha == "$20,000 - $29,999 per year ($380 - $579 per week)"
replace income =  35000 if income_cha == "$30,000 - $39,999 per year ($580 - $769 per week)"
replace income =  45000 if income_cha == "$40,000 - $49,999 per year ($770 - $959 per week)"
replace income =  55000 if income_cha == "$50,000 - $59,999 per year ($960 - $1,149 per week)"
replace income =  70000 if income_cha == "$60,000 - $79,999 per year ($1,150 - $1,529 per week)"
replace income =  90000 if income_cha == "$80,000 - $99,999 per year ($1,530 - $1,919 per week)"
replace income =  112500 if income_cha == "$100,000 - $124,999 per year ($1,920 - $2,399 per week)"
replace income =  137500 if income_cha == "$125,000 - $149,999 per year ($2,400 - $2,879 per week)"
replace income =  175000 if income_cha == "$150,000 - $199,999 per year ($2,880 - $3,839 per week)"
replace income =  225000 if income_cha == "$200,000 - $249,999 per year ($3,840 - $4,799 per week)"
replace income =  275000 if income_cha == "$250,000 - $299,999 per year ($4,800 - $5,759 per week)"
replace income =  300000  if income_cha == "$300,000 or more per year ($5,760 or more per week)"

replace income = 1000000 if Q37otherPleaseentertheamo == "$1000000 per year at least"
replace income = 350000  if Q37otherPleaseentertheamo == "$350,000 per year"
replace income = 1000000 if Q37otherPleaseentertheamo == "1000000+ a year"
replace income = 1200000 if Q37otherPleaseentertheamo == "1200000 per annum"
replace income = 300000  if Q37otherPleaseentertheamo == "300,000"
replace income = 300000  if Q37otherPleaseentertheamo == "300,000 + per year"
replace income = 300000  if Q37otherPleaseentertheamo == "300,000 per year"
replace income = 300000  if Q37otherPleaseentertheamo == "3000.000 per year"
replace income = 300000  if Q37otherPleaseentertheamo == "300000"
replace income = 300000  if Q37otherPleaseentertheamo == "300000 per year"
replace income = 300000  if Q37otherPleaseentertheamo == "300000 year"
replace income = 300000  if Q37otherPleaseentertheamo == "300000per year"
replace income = 309000  if Q37otherPleaseentertheamo == "309000"
replace income = 310000  if Q37otherPleaseentertheamo == "310000"
replace income = 320000  if Q37otherPleaseentertheamo == "320000/yr"
replace income = 325000  if Q37otherPleaseentertheamo == "325,000 per annum"
replace income = 330000  if Q37otherPleaseentertheamo == "330,000 per year"
replace income = 330000  if Q37otherPleaseentertheamo == "330000"
replace income = 330000  if Q37otherPleaseentertheamo == "330000 per year"
replace income = 350000  if Q37otherPleaseentertheamo == "350,000 per year (rough estimate)"
replace income = 350000  if Q37otherPleaseentertheamo == "350000"
replace income = 350000  if Q37otherPleaseentertheamo == "350000 per year"
replace income = 350000  if Q37otherPleaseentertheamo == "350000 pr yr"
replace income = 350000  if Q37otherPleaseentertheamo == "350000/year"
replace income = 3500000 if Q37otherPleaseentertheamo == "3500000"
replace income = 350000 if Q37otherPleaseentertheamo == "350k, yearly"
replace income = 375000  if Q37otherPleaseentertheamo == "375000"
replace income = 400000  if Q37otherPleaseentertheamo == "400,000 per year"
replace income = 400000  if Q37otherPleaseentertheamo == "400000"
replace income = 416500  if Q37otherPleaseentertheamo == "416,500 per year"
replace income = 450000  if Q37otherPleaseentertheamo == "450000"
replace income = 500000  if Q37otherPleaseentertheamo == "500,000 pa"
replace income = 5000*52 if Q37otherPleaseentertheamo == "5000+ per week"
replace income = 50000  if Q37otherPleaseentertheamo == "50000/year"
replace income = 500000  if Q37otherPleaseentertheamo == "500000"
replace income = 500000  if Q37otherPleaseentertheamo == "500000 per year"
replace income = 550000  if Q37otherPleaseentertheamo == "550000"
replace income = 5670*52 if Q37otherPleaseentertheamo == "5670"
replace income = 600000  if Q37otherPleaseentertheamo == "600,000"
replace income = 6000*52 if Q37otherPleaseentertheamo == "6000"
replace income = 6000*52 if Q37otherPleaseentertheamo == "6000 per week"
replace income = 6000*52 if Q37otherPleaseentertheamo == "6000 week"
replace income = 600000  if Q37otherPleaseentertheamo == "600000 per year"
replace income = 6200*52 if Q37otherPleaseentertheamo == "6200 per week"
replace income = 700000  if Q37otherPleaseentertheamo == "700,000 per year"
replace income = 7000*52 if Q37otherPleaseentertheamo == "7000"
replace income = 8000*52 if Q37otherPleaseentertheamo == "8000"
replace income = 500000  if Q37otherPleaseentertheamo == "approx. $500,000"
replace income = 300000  if Q37otherPleaseentertheamo == "over 300k per year"
replace income = 10000*52 if Q37otherPleaseentertheamo == "10000"
replace income = 340000  if Q37otherPleaseentertheamo == "340000 per year"
replace income = 400000  if Q37otherPleaseentertheamo == "400,000 Per year"

replace income = income/1000                       // thousand dollars

drop income_cha
label var income "Household annual income in AUD1000"

tab income, missing

* ------------------------------------------------------------------------------
* Monthly Electricity Bill
* ------------------------------------------------------------------------------

gen bill = .
replace bill =  0   if bill_cha == "$0 per month"
replace bill =  25  if bill_cha == "$1 to $49 per month"
replace bill =  75  if bill_cha == "$50 to $99 per month"
replace bill =  125 if bill_cha == "$100 to $149 per month"
replace bill =  175 if bill_cha == "$150 to $199 per month"
replace bill =  225 if bill_cha == "$200 to $249 per month"
replace bill =  275 if bill_cha == "$250 to $299 per month"
replace bill =  325 if bill_cha == "$300 to $349 per month"
replace bill =  375 if bill_cha == "$350 to $399 per month"
replace bill =  425 if bill_cha == "$400 to $449 per month"
replace bill =  475 if bill_cha == "$450 to $499 per month"
replace bill =  bill_open if bill_cha == "More than $500 per month"

drop bill_cha bill_open
replace bill   = bill/1000                         // thousand dollars
label var bill "Household monthly electricity bill in AUD1000"

tab bill, missing

* ------------------------------------------------------------------------------
* WTP Response Certainty (ordered categorical, 1–4)
* ------------------------------------------------------------------------------

tab certainty_cha, missing
gen certainty = .
replace certainty = 1 if certainty_cha == "Absolutely certain"
replace certainty = 2 if certainty_cha == "Somewhat certain"
replace certainty = 3 if certainty_cha == "Not very certain"
replace certainty = 4 if certainty_cha == "Not certain at all"

drop certainty_cha
label var certainty "Certainty about WTP response (1=Absolutely certain … 4=Not certain at all)"

tab certainty, missing

* ------------------------------------------------------------------------------
* Demographics
* ------------------------------------------------------------------------------

tab gender_char, missing
gen female = (gender_char == "Female")
label var female "Female respondent (1=Yes)" 
drop gender_char

tab state, missing
quietly tab state,  gen(state_)
rename state_1  ACT
rename state_2  NSW
rename state_3  NT
rename state_4  QLD
rename state_5  SA
rename state_6  TAS
rename state_7  VIC
rename state_8  WA

tab age, missing
tab female, missing
sum ACT-WA 

* ------------------------------------------------------------------------------
* CV-related variables
* ------------------------------------------------------------------------------

tab ans_first_cha, missing
tab ans_second_cha, missing
gen ans_first  = (ans_first_cha == "Yes, I would be willing to pay extra $^f('hQ13amount')^ per month")
gen ans_second = (ans_second_cha == "Yes, I would be willing to pay extra $^f('hQ14amount')^ per month")

drop ans_first_cha ans_second_cha
tab ans_first, missing
tab ans_second, missing

tab bid_first, missing
tab bid_second, missing
destring bid_first, replace
destring bid_second, replace
tab bid_first, missing
tab bid_second, missing

* ------------------------------------------------------------------------------
* Location
* ------------------------------------------------------------------------------

tab project_location, missing
gen location = (state == project_location)
label var location "Respondent lives in project state (1=Yes)"

tab location, missing

* ------------------------------------------------------------------------------
* Other variables
* ------------------------------------------------------------------------------

tab SurveyType,missing
gen green = (SurveyType == "GREEN")
gen blue  = (SurveyType == "BLUE")
label var green     "Assigned to green hydrogen scenario (1=Yes)"
label var blue      "Assigned to blue hydrogen scenario (1=Yes)"
drop SurveyType 
tab green, missing
tab blue, missing

tab knowledge, missing
label var knowledge "Number of correct responses to hydrogen-related questions"

* ------------------------------------------------------------------------------
* Delete irrelevant variables
* ------------------------------------------------------------------------------

drop Phase hQ31sum1Agesummary1-ABSLocation ABSRemotenessArea Consent Q21CoalfiredpowerPleases-Q42Ifyouhaveanycommentsa

* ------------------------------------------------------------------------------
* Save temporary dataset
* ------------------------------------------------------------------------------

save "${output}\hydro_temp.dta", replace        

********************************************************************************
* SECTION 2: CREATE STEP-SPECIFIC DATASETS
*            (Double-bounded CV format: Step 1 = first bid, Step 2 = second bid)
********************************************************************************

* Step 1 dataset (first bid)
use "${output}\hydro_temp.dta", clear
drop bid_second ans_second
gen step1 = 1
gen step2 = 0
gen bid_all  = bid_first
gen lbid_all = log(bid_all)
gen ans_all  = ans_first
drop bid_first ans_first
save "${output}\hydro_full_1st.dta", replace

* Step 2 dataset (second bid)
use "${output}\hydro_temp.dta", clear
drop bid_first ans_first
gen step1 = 0
gen step2 = 1
gen bid_all  = bid_second
gen lbid_all = log(bid_all)
gen ans_all  = ans_second
drop bid_second ans_second
save "${output}\hydro_full_2nd.dta", replace

********************************************************************************
* SECTION 3: CREATE FULL PANEL DATASET (long format)
********************************************************************************

use "${output}\hydro_full_1st.dta", clear
append using "${output}\hydro_full_2nd.dta"

gen step1_bid = step1 * bid_all
gen step2_bid = step2 * bid_all
label var step1_bid "Bid amount × Step 1 indicator"
label var step2_bid "Bid amount × Step 2 indicator"

* create anchoring effect term
bysort responseid: egen initial_bid = max(step1_bid)
generate anchor = 0
replace anchor = log(initial_bid) if step2 == 1
drop initial_bid

save "${output}\hydro_full_panel.dta", replace

********************************************************************************
* SECTION 4: CREATE DATASET FOR BASELINE RESULTS
********************************************************************************

* ------------------------------------------------------------------------------
* For Single-Bounded Model
* ------------------------------------------------------------------------------

use "${output}\hydro_full_1st.dta", clear

// Check missing values
misstable sum ans_all bid_all lbid_all bill age female uni_path vet knowledge green location NSW VIC QLD WA SA TAS ACT NT

// Remove obs with missing values
drop if missing(bill)
 
 // Remove those who said their CV response is not certain at all
drop if certainty == 4  

save "${output}\hydro_base_1st.dta", replace    

* ------------------------------------------------------------------------------
* For Double-Bounded Model
* ------------------------------------------------------------------------------

use "${output}\hydro_full_panel.dta", clear

// Check missing values
misstable sum ans_all bid_all lbid_all bill age female uni_path vet knowledge green location NSW VIC QLD WA SA TAS ACT NT

// Remove obs with missing values
drop if missing(bill)
 
 // Remove those who said their CV response is not certain at all
drop if certainty == 4  

save "${output}\hydro_base_panel.dta", replace    
