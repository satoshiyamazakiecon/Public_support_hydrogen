# ==============================================================================
# FILE: Table_summary_balance.R 
#
# PURPOSE:
#   Table 1: Summary statistics for the full sample
#            Mean, SD, Median, Min, Max
#
#   Table 2: Balance table comparing Green and Blue scenarios
#            Green mean, Blue mean, difference, SE, p-value
#            + joint balance test
#
# DATA INPUT:
#   hydro_base_1st.dta
#
# OUTPUT:
#   Table_summary_balance.xlsx
# ==============================================================================

library(haven)
library(dplyr)
library(openxlsx)

# Project root
project_root <- file.path(
  Sys.getenv("USERPROFILE"),
  "GitHub",
  "Australia_Hydrogen_WTP"
)

# Load local file paths 
source(file.path(project_root, "code/r/config.R"))

# ------------------------------------------------------------------------------
# 1. IMPORT DATA
# ------------------------------------------------------------------------------

df <- read_dta(
  file.path(output_STATA_path,
            "hydro_base_1st.dta"))

# ------------------------------------------------------------------------------
# 2. TABLE 1: SUMMARY STATISTICS - FULL SAMPLE
# ------------------------------------------------------------------------------

# Variables to summarise
vars_summary <- c(
  "bill",
  "age",
  "female",
  "uni_path",
  "vet",
  "knowledge",
  "location",
  "green",
  "NSW",
  "VIC",
  "QLD",
  "WA",
  "SA",
  "TAS",
  "ACT",
  "NT"
)

# Function to calculate summary statistics
summary_stats <- function(x) {
  
  x <- x[!is.na(x)]
  
  tibble(
    N      = length(x),
    Mean   = mean(x),
    SD     = sd(x),
    Median = median(x),
    Min    = min(x),
    Max    = max(x)
  )
}

# Calculate statistics
table1 <- bind_rows(
  lapply(
    vars_summary,
    function(v) {
      
      summary_stats(df[[v]]) %>%
        mutate(
          Variable = v,
          .before = 1
        )
    }
  )
)

# Round results
table1 <- table1 %>%
  mutate(
    across(
      where(is.numeric),
      ~ round(.x, 3)
    )
  )

# ------------------------------------------------------------------------------
# 3. TABLE 2: BALANCE - GREEN VS BLUE
# ------------------------------------------------------------------------------

# Respondent characteristics
vars_characteristics <- c(
  "bill",
  "age",
  "female",
  "uni_path",
  "vet",
  "knowledge",
  "location",
  "NSW",
  "VIC",
  "QLD",
  "WA",
  "SA",
  "TAS",
  "ACT",
  "NT"
)

# Climate-change attitudes
vars_climate <- c(
  "climate_change",
  "cause_human",
  "nega_health",
  "nega_economic"
)

# Energy attitudes
vars_energy <- c(
  "elec_shortage",
  "energy_develop",
  "funds",
  "elec_price",
  "renewable_employ",
  "renewable_noise",
  "renewable_economic",
  "renewable_mitigate"
)

# Function for individual balance tests
balance_test <- function(var) {
  
  x_green <- df[[var]][df$green == 1]
  x_blue  <- df[[var]][df$green == 0]
  
  # Remove missing observations
  x_green <- x_green[!is.na(x_green)]
  x_blue  <- x_blue[!is.na(x_blue)]
  
  # Welch unequal-variance t-test
  test <- t.test(
    x_green,
    x_blue,
    var.equal = FALSE
  )
  
  tibble(
    Variable   = var,
    Green_N    = length(x_green),
    Green_mean = mean(x_green),
    Blue_N     = length(x_blue),
    Blue_mean  = mean(x_blue),
    Difference = mean(x_green) - mean(x_blue),
    SE         = unname(test$stderr),
    p_value    = test$p.value
  )
}

# Run individual balance tests
table_characteristics <- bind_rows(
  lapply(
    vars_characteristics,
    balance_test
  )
) %>%
  mutate(
    Section = "Respondent characteristics",
    .before = 1
  )

table_climate <- bind_rows(
  lapply(
    vars_climate,
    balance_test
  )
) %>%
  mutate(
    Section = "Climate-change attitudes",
    .before = 1
  )

table_energy <- bind_rows(
  lapply(
    vars_energy,
    balance_test
  )
) %>%
  mutate(
    Section = "Energy attitudes",
    .before = 1
  )

# Combine all balance results
table2 <- bind_rows(
  table_characteristics,
  table_climate,
  table_energy
)

# Add significance stars
table2 <- table2 %>%
  mutate(
    Stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE           ~ ""
    )
  )

# Round numerical results
table2 <- table2 %>%
  mutate(
    across(
      c(Green_mean, Blue_mean, Difference, SE, p_value),
      ~ round(.x, 3)
    )
  )

# ------------------------------------------------------------------------------
# 4. JOINT BALANCE TESTS
# ------------------------------------------------------------------------------

# Function for joint balance test
joint_balance_test <- function(vars, test_name) {
  
  formula_joint <- as.formula(
    paste(
      "green ~",
      paste(vars, collapse = " + ")
    )
  )
  
  model <- lm(
    formula_joint,
    data = df
  )
  
  fstat <- summary(model)$fstatistic
  
  F_value <- unname(fstat["value"])
  df1     <- unname(fstat["numdf"])
  df2     <- unname(fstat["dendf"])
  
  p_value <- pf(
    F_value,
    df1,
    df2,
    lower.tail = FALSE
  )
  
  tibble(
    Test        = test_name,
    F_statistic = F_value,
    p_value     = p_value,
    N           = nobs(model)
  )
}

# Joint test: respondent characteristics
joint_characteristics <- joint_balance_test(
  vars_characteristics,
  "Respondent characteristics"
)

# Joint test: climate-change attitudes
joint_climate <- joint_balance_test(
  vars_climate,
  "Climate-change attitudes"
)

# Joint test: energy attitudes
joint_energy <- joint_balance_test(
  vars_energy,
  "Energy attitudes"
)

# Combine joint tests
joint_tests <- bind_rows(
  joint_characteristics,
  joint_climate,
  joint_energy
) %>%
  mutate(
    F_statistic = round(F_statistic, 3),
    p_value     = round(p_value, 3)
  )

# ------------------------------------------------------------------------------
# 5. EXPORT TABLES TO EXCEL
# ------------------------------------------------------------------------------

wb <- createWorkbook()

# Table 1
addWorksheet(
  wb,
  "Table 1 - Summary"
)

writeData(
  wb,
  sheet = "Table 1 - Summary",
  x = table1,
  startRow = 1
)

# Table 2
addWorksheet(
  wb,
  "Table 2 - Balance"
)

writeData(
  wb,
  sheet = "Table 2 - Balance",
  x = table2,
  startRow = 1
)

# Add joint balance test below main table
joint_start <- nrow(table2) + 4

writeData(
  wb,
  sheet = "Table 2 - Balance",
  x = "Joint balance test",
  startRow = joint_start,
  startCol = 1
)

writeData(
  wb,
  sheet = "Table 2 - Balance",
  x = joint_tests,
  startRow = joint_start + 1,
  startCol = 1
)

# Add notes
note_row <- joint_start + nrow(joint_tests) + 3

writeData(
  wb,
  sheet = "Table 2 - Balance",
  x = paste(
    "Notes: Difference = Green mean - Blue mean.",
    "SE and p-values for individual variables are based on Welch",
    "unequal-variance t-tests.",
    "Joint tests test the null hypothesis that all variables within",
    "each group are jointly unrelated to scenario assignment.",
    "*** p<0.01, ** p<0.05, * p<0.10."
  ),
  startRow = note_row,
  startCol = 1
)

# Save workbook
saveWorkbook(
  wb,
  file.path(output_R_path, "Table_summary_balance.xlsx"),
  overwrite = TRUE
)
