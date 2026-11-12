capture program drop wtp_fullinteract
program define wtp_fullinteract

    syntax [if], ///
        depvar(varname) ///
        bid(varname) ///
        green(varname) ///
        attitude(varname) ///
        controls(varlist) ///
        id(varname) ///
        [sensitivity(string)]

    marksample touse
    markout `touse' `depvar' `bid' `green' `attitude' `controls' `id'

    display "Dependent variable: `depvar'"
    display "Bid variable:       `bid'"
    display "Green indicator:    `green'"
    display "Attitude variable:  `attitude'"

    *-----------------------------------------------------------
    * 1. Run fully interacted model
    *-----------------------------------------------------------
    xtprobit `depvar' ///
        ib0.`green'##ib0.`attitude'##c.`bid' ///
        `controls' if `touse', ///
        re vce(cluster `id')

    *-----------------------------------------------------------
    * 2. Compute means of controls in the estimation sample
    *-----------------------------------------------------------
    foreach v of varlist `controls' {
        quietly summarize `v' if e(sample)
        scalar mean_`v' = r(mean)
    }

    *-----------------------------------------------------------
    * 3. Build common linear index XB (constant + controls only)
    *-----------------------------------------------------------
	local XB "_b[_cons]"
    foreach v of varlist `controls' {
        if !inlist("`v'", "step2", "anchor") {
			local XB "`XB' + _b[`v']*mean_`v'"
		}
    }

    *-----------------------------------------------------------
    * 4. Define the four WTP expressions
    *
    *    B0: Blue,  attitude = 0
    *    B1: Blue,  attitude = 1
    *    G0: Green, attitude = 0
    *    G1: Green, attitude = 1
    *-----------------------------------------------------------

    local WTP_B0 "exp(-(`XB') / (_b[`bid']))"
    local WTP_B1 "exp(-(`XB' + _b[1.`attitude']) / (_b[`bid'] + _b[1.`attitude'#c.`bid']))"
    local WTP_G0 "exp(-(`XB' + _b[1.`green']) / (_b[`bid'] + _b[1.`green'#c.`bid']))"
    local WTP_G1 "exp(-(`XB' + _b[1.`green'] + _b[1.`attitude'] + _b[1.`green'#1.`attitude']) / (_b[`bid'] + _b[1.`green'#c.`bid'] + _b[1.`attitude'#c.`bid'] + _b[1.`green'#1.`attitude'#c.`bid']))"

    *-----------------------------------------------------------
    * 5. Calculate WTP levels 
    *-----------------------------------------------------------
 
    nlcom ///
        (WTP_B0: `WTP_B0') ///
        (WTP_B1: `WTP_B1') ///
        (WTP_G0: `WTP_G0') ///
        (WTP_G1: `WTP_G1'), post 
	
    *-----------------------------------------------------------
    * 6. Store WTP levels and contrasts
    *
    *    att_diff_Blue  = WTP(B,1) - WTP(B,0)
    *    att_diff_Green = WTP(G,1) - WTP(G,0)
    *
    *    green_diff_A0  = WTP(G,0) - WTP(B,0)
    *    green_diff_A1  = WTP(G,1) - WTP(B,1)
    *
    *    heterogeneity =
    *        [WTP(G,1) - WTP(G,0)]
    *      - [WTP(B,1) - WTP(B,0)]
    *-----------------------------------------------------------

    tempname results
    matrix `results' = J(9, 6, .)

    local row = 1

    * WTP levels
    foreach q in WTP_B0 WTP_B1 WTP_G0 WTP_G1 {

        quietly lincom `q'

        matrix `results'[`row',1] = r(estimate)
        matrix `results'[`row',2] = r(se)
        matrix `results'[`row',3] = r(estimate) / r(se)
        matrix `results'[`row',4] = r(p)
        matrix `results'[`row',5] = r(lb)
        matrix `results'[`row',6] = r(ub)

        local ++row
    }

    * Attitude difference within Blue
    quietly lincom WTP_B1 - WTP_B0

    matrix `results'[`row',1] = r(estimate)
    matrix `results'[`row',2] = r(se)
    matrix `results'[`row',3] = r(estimate) / r(se)
    matrix `results'[`row',4] = r(p)
    matrix `results'[`row',5] = r(lb)
    matrix `results'[`row',6] = r(ub)

    local ++row

    * Attitude difference within Green
    quietly lincom WTP_G1 - WTP_G0

    matrix `results'[`row',1] = r(estimate)
    matrix `results'[`row',2] = r(se)
    matrix `results'[`row',3] = r(estimate) / r(se)
    matrix `results'[`row',4] = r(p)
    matrix `results'[`row',5] = r(lb)
    matrix `results'[`row',6] = r(ub)

    local ++row

    * Green - Blue difference, attitude = 0
    quietly lincom WTP_G0 - WTP_B0

    matrix `results'[`row',1] = r(estimate)
    matrix `results'[`row',2] = r(se)
    matrix `results'[`row',3] = r(estimate) / r(se)
    matrix `results'[`row',4] = r(p)
    matrix `results'[`row',5] = r(lb)
    matrix `results'[`row',6] = r(ub)

    local ++row

    * Green - Blue difference, attitude = 1
    quietly lincom WTP_G1 - WTP_B1

    matrix `results'[`row',1] = r(estimate)
    matrix `results'[`row',2] = r(se)
    matrix `results'[`row',3] = r(estimate) / r(se)
    matrix `results'[`row',4] = r(p)
    matrix `results'[`row',5] = r(lb)
    matrix `results'[`row',6] = r(ub)

    local ++row

    * Difference in attitude-related WTP differences
    quietly lincom ///
        (WTP_G1 - WTP_G0) - ///
        (WTP_B1 - WTP_B0)

    matrix `results'[`row',1] = r(estimate)
    matrix `results'[`row',2] = r(se)
    matrix `results'[`row',3] = r(estimate) / r(se)
    matrix `results'[`row',4] = r(p)
    matrix `results'[`row',5] = r(lb)
    matrix `results'[`row',6] = r(ub)

    * Add row and column names
    matrix rownames `results' = ///
        WTP_B0 ///
        WTP_B1 ///
        WTP_G0 ///
        WTP_G1 ///
        att_diff_Blue ///
        att_diff_Green ///
        green_diff_A0 ///
        green_diff_A1 ///
        heterogeneity

    matrix colnames `results' = ///
        b se z pvalue ll ul

    *-----------------------------------------------------------
    * 7. Export results to CSV
    *-----------------------------------------------------------
    preserve
        clear

        svmat `results', names(col)

        gen quantity = ""

        local names : rownames `results'
        local i = 1

        foreach n of local names {
            replace quantity = "`n'" in `i'
            local ++i
        }

        order quantity

        if "`sensitivity'" != "" {
            export delimited using ///
                "${output}\results_sensitivity_fullinteract_`attitude'_`sensitivity'.csv", ///
                replace
        }
        else {
            export delimited using ///
                "${output}\results_WTP_fullinteract_`attitude'.csv", ///
                replace
        }

    restore

end
