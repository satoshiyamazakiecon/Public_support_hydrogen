capture program drop wtp_interact
program define wtp_interact

    syntax [if], ///
	    depvar(varname) ///
        bid(varname) ///
        treat(varname) ///
        controls(varlist) ///
        id(varname) ///
		[sensitivity(string)]
		
	marksample touse

    display "Dependent variable: `depvar'"
    display "Bid variable:       `bid'"
    display "Treatment variable: `treat'"
		
	*-----------------------------------------------------------
    * 1. Run model
    *-----------------------------------------------------------
    xtprobit `depvar' ///
        c.`bid'##i.`treat' ///
        `controls' if `touse', ///
        re vce(cluster `id')
		
	testparm i.`treat'
	testparm i.`treat'#c.`bid'
	testparm i.`treat' i.`treat'#c.`bid'
	
	*-----------------------------------------------------------
    * 2. Compute means of controls
    *-----------------------------------------------------------
    foreach v of varlist `controls' {
        quietly summarize `v' if e(sample)
        scalar mean_`v' = r(mean)
    }
	
    *-----------------------------------------------------------
    * 3. Build the common linear index XB (controls only)
    *-----------------------------------------------------------
    local XB "_b[_cons]"
    foreach v of varlist `controls' {
        if !inlist("`v'", "step2", "anchor") {
			local XB "`XB' + _b[`v']*mean_`v'"
		}
    }
	
	*-----------------------------------------------------------
    * 4. Define WTP expressions
    *
    *    WTP_0: treatment = 0
    *    WTP_1: treatment = 1
    *-----------------------------------------------------------
    local WTP_0 "exp(-(`XB') / (_b[`bid']))"
    local WTP_1 "exp(-(`XB' + _b[1.`treat']) / (_b[`bid'] + _b[1.`treat'#c.`bid']))"
	
	*-----------------------------------------------------------
    * 5. Calculate WTP levels and difference using nlcom
    *-----------------------------------------------------------
    nlcom ///
        (WTP_1: `WTP_1') ///
        (WTP_0: `WTP_0') ///
        (diff: (`WTP_1') - (`WTP_0'))
	   
	 *-----------------------------------------------------------
     * 6. Export nlcom results to CSV
     *-----------------------------------------------------------
     
	 matrix b = r(table)

     * Transpose so rows = quantities, columns = stats
     matrix b = b'

     * Preserve current data, build a small results dataset, export, restore
     preserve
         clear
         svmat b, names(col)
         gen quantity = ""
         local names : rownames b
         local i = 1
         foreach n of local names {
            replace quantity = "`n'" in `i'
            local ++i
         }
         order quantity 
		 
		if "`sensitivity'" != "" {
            export delimited using ///
                "${output}\results_sensitivity_`treat'_`sensitivity'.csv", replace
        } 
		else {
            export delimited using ///
                "${output}\results_WTP_`treat'.csv", replace
        }
         
restore
        
end