# Public support for low-carbon hydrogen: From acceptance to financial commitment

This repository contains the **Stata and R code** and **survey questionnaire** for the paper *“Public support for low-carbon hydrogen: From acceptance to financial commitment.”*

## Repository contents

- `code/stata/` — Data preparation, WTP estimation, and sensitivity analyses.
- `code/r/` — Summary tables and figures.
- `questionnaire/` — Survey questionnaire.

## Stata scripts

Run the numbered scripts in order.

- `1_data_cleaning.do` — Cleans the survey data and prepares the datasets used in the analysis.
- `2_estimation.do` — Estimates the contingent valuation models and calculates conditional median WTP.
- `3_WTP_marginal.do` — Calculates marginal effects of respondent characteristics on conditional median WTP.
- `4_WTP_hetero.do` — Compares WTP across hydrogen scenarios and climate and energy attitude groups.
- `5_WTP_fullinteract.do` — Tests whether attitude-related WTP differences vary between green and blue hydrogen.
- `6_sensitivity_WTP.do` — Tests the sensitivity of estimated WTP to alternative samples and model specifications.
- `7_sensitivity_MWTP.do` — Tests the sensitivity of marginal WTP effects to alternative specifications.
- `8_sensitivity_greenblue.do` — Tests the robustness of green–blue WTP comparisons.
- `9_sensitivity_climate.do` — Tests the robustness of WTP differences associated with climate attitudes.
- `10_sensitivity_energy.do` — Tests the robustness of WTP differences associated with energy attitudes.
- `11_sensitivity_fullinteract.do` — Tests the robustness of green–blue differences in attitude-related WTP.
- `12_table_CV_response.do` — Summarises yes/no response patterns by initial bid amount.

The helper files `wtp_interact.do` and `wtp_fullinteract.do` estimate WTP contrasts for two groups and for fully interacted hydrogen-scenario × attitude models, respectively.

## R scripts

Run these after the relevant Stata outputs have been generated.

- `Table_summary_balance.R` — Produces respondent summary statistics and green–blue balance tests.
- `Fig_climate_energy.R` — Plots survey responses to climate-change and energy-attitude questions.
- `Fig_attitudes_corr.R` — Calculates attitude correlations and plots a correlation heatmap.
- `Fig_WTP_density.R` — Plots respondent-specific WTP distributions, including green–blue comparisons and WTP relative to electricity bills.
- `Fig_WTP_climate.R` — Plots climate-attitude WTP differences and exports a results table.
- `Fig_WTP_energy.R` — Plots energy-attitude WTP differences and exports a results table.
- `Fig_WTP_fullinteract.R` — Plots differences in attitude-related WTP contrasts between green and blue hydrogen and exports a results table.
- `Fig_WTP_density_sensitivity.R` — Plots green–blue WTP distributions under alternative specifications.
- `Fig_WTP_climate_sensitivity.R` — Plots climate-attitude WTP differences under alternative specifications.
- `Fig_WTP_energy_sensitivity.R` — Plots energy-attitude WTP differences under alternative specifications.
- `Fig_WTP_fullinteract_sensitivity.R` — Plots sensitivity results for green–blue differences in attitude-related WTP.

## Requirements and setup

The analyses use **Stata 19.5** (including the user-written `estout` package) and **R**. Set the local input and output paths in `code/stata/config.do` and `code/r/config.R`, and update the project working directory in the scripts as needed. The R scripts use `haven`, `dplyr`, `tidyr`, `ggplot2`, `stringr`, `forcats`, `patchwork`, `readr`, `openxlsx`, and `here`.

The machine-specific configuration files code/stata/config.do and code/r/config.R are not included in this repository. To run the scripts, create these files locally and define:
- In config.do: the Stata globals $data (raw survey-data directory) and $output (Stata outputs and analysis datasets).
- In config.R: output_STATA_path (directory containing Stata outputs) and output_R_path (directory for R outputs).

## Data availability

The survey data used in this study are not publicly available because they contain confidential information and are subject to restrictions on data sharing. The data may be available from the corresponding author upon reasonable request, subject to applicable ethical and data-access requirements.
