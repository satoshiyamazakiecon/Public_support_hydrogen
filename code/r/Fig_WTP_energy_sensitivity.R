# ==============================================================================
# FILE: Fig_WTP_energy_sensitivity.R
#
# PURPOSE:
#   Create a figure of willingness-to-pay differences for attitudes toward
#   energy under three sensitivity specifications:
#   Certain, All, and Income
#
#   Statistical significance is based on Holm-adjusted p-values,
#   correcting for the eight energy-attitude tests within each specification.
#
# DATA INPUT:
#   results_sensitivity_elec_shortage_[certain,all,income,shift].csv
#   results_sensitivity_energy_develop_[certain,all,income,shift].csv
#   results_sensitivity_funds_[certain,all,income,shift].csv
#   results_sensitivity_elec_price_[certain,all,income,shift].csv
#   results_sensitivity_renewable_mitigate_[certain,all,income,shift].csv
#   results_sensitivity_renewable_employ_[certain,all,income,shift].csv
#   results_sensitivity_renewable_noise_[certain,all,income,shift].csv
#   results_sensitivity_renewable_economic_[certain,all,income,shift].csv
#
# OUTPUT:
#   Fig_WTP_energy_sensitivity.png
# ==============================================================================

library(ggplot2)
library(dplyr)
library(stringr)

# Project root
project_root <- file.path(
  Sys.getenv("USERPROFILE"),
  "GitHub",
  "Australia_Hydrogen_WTP"
)

# Load local file paths
source(file.path(project_root, "code/r/config.R"))

# ------------------------------------------------------------------------------
# 1. LOAD AND PREPARE DATA
# ------------------------------------------------------------------------------

# Function to read one results file and extract row 3
read_result <- function(file_stub, group_label, specification) {
  
  df <- read.csv(
    file.path(
      output_STATA_path,
      paste0(
        "results_sensitivity_",
        file_stub,
        "_",
        specification,
        ".csv"
      )
    )
  )
  
  data.frame(
    group = group_label,
    specification = specification,
    mean = df[3, "b"],
    lower = df[3, "ll"],
    upper = df[3, "ul"],
    pval = df[3, "pvalue"]
  )
}

# ------------------------------------------------------------------------------
# 2. IMPORT RESULTS
# ------------------------------------------------------------------------------

# Renewable energy mitigates climate change
d1_certain <- read_result(
  "renewable_mitigate",
  "Renewable energy mitigates climate change",
  "certain"
)

d1_all <- read_result(
  "renewable_mitigate",
  "Renewable energy mitigates climate change",
  "all"
)

d1_income <- read_result(
  "renewable_mitigate",
  "Renewable energy mitigates climate change",
  "income"
)

d1_shift <- read_result(
  "renewable_mitigate",
  "Renewable energy mitigates climate change",
  "shift"
)

# Renewable energy benefits the economy
d2_certain <- read_result(
  "renewable_economic",
  "Renewable energy benefits the economy",
  "certain"
)

d2_all <- read_result(
  "renewable_economic",
  "Renewable energy benefits the economy",
  "all"
)

d2_income <- read_result(
  "renewable_economic",
  "Renewable energy benefits the economy",
  "income"
)

d2_shift <- read_result(
  "renewable_economic",
  "Renewable energy benefits the economy",
  "shift"
)

# Renewable energy creates jobs
d3_certain <- read_result(
  "renewable_employ",
  "Renewable energy creates jobs",
  "certain"
)

d3_all <- read_result(
  "renewable_employ",
  "Renewable energy creates jobs",
  "all"
)

d3_income <- read_result(
  "renewable_employ",
  "Renewable energy creates jobs",
  "income"
)

d3_shift <- read_result(
  "renewable_employ",
  "Renewable energy creates jobs",
  "shift"
)

# Renewable energy causes new environmental problems
d4_certain <- read_result(
  "renewable_noise",
  "Renewable energy causes new environmental problems",
  "certain"
)

d4_all <- read_result(
  "renewable_noise",
  "Renewable energy causes new environmental problems",
  "all"
)

d4_income <- read_result(
  "renewable_noise",
  "Renewable energy causes new environmental problems",
  "income"
)

d4_shift <- read_result(
  "renewable_noise",
  "Renewable energy causes new environmental problems",
  "shift"
)

# Renewable energy increases electricity prices
d5_certain <- read_result(
  "elec_price",
  "Renewable energy increases electricity prices",
  "certain"
)

d5_all <- read_result(
  "elec_price",
  "Renewable energy increases electricity prices",
  "all"
)

d5_income <- read_result(
  "elec_price",
  "Renewable energy increases electricity prices",
  "income"
)

d5_shift <- read_result(
  "elec_price",
  "Renewable energy increases electricity prices",
  "shift"
)

# Electricity shortages will occur
d6_certain <- read_result(
  "elec_shortage",
  "Electricity shortages will occur",
  "certain"
)

d6_all <- read_result(
  "elec_shortage",
  "Electricity shortages will occur",
  "all"
)

d6_income <- read_result(
  "elec_shortage",
  "Electricity shortages will occur",
  "income"
)

d6_shift <- read_result(
  "elec_shortage",
  "Electricity shortages will occur",
  "shift"
)

# Cheap and abundant future energy is important
d7_certain <- read_result(
  "energy_develop",
  "Cheap and abundant future energy is important",
  "certain"
)

d7_all <- read_result(
  "energy_develop",
  "Cheap and abundant future energy is important",
  "all"
)

d7_income <- read_result(
  "energy_develop",
  "Cheap and abundant future energy is important",
  "income"
)

d7_shift <- read_result(
  "energy_develop",
  "Cheap and abundant future energy is important",
  "shift"
)

# Government should support low-carbon energy development
d8_certain <- read_result(
  "funds",
  "Government should support low-carbon energy development",
  "certain"
)

d8_all <- read_result(
  "funds",
  "Government should support low-carbon energy development",
  "all"
)

d8_income <- read_result(
  "funds",
  "Government should support low-carbon energy development",
  "income"
)

d8_shift <- read_result(
  "funds",
  "Government should support low-carbon energy development",
  "shift"
)

# Combine all results
plot_df <- bind_rows(
  d1_certain, d1_all, d1_income, d1_shift,
  d2_certain, d2_all, d2_income, d2_shift,
  d3_certain, d3_all, d3_income, d3_shift,
  d4_certain, d4_all, d4_income, d4_shift,
  d5_certain, d5_all, d5_income, d5_shift,
  d6_certain, d6_all, d6_income, d6_shift,
  d7_certain, d7_all, d7_income, d7_shift,
  d8_certain, d8_all, d8_income, d8_shift 
)

# ------------------------------------------------------------------------------
# 3. HOLM ADJUSTMENT
# ------------------------------------------------------------------------------

# Adjust p-values across the eight energy-attitude tests
# separately within each sensitivity specification
plot_df <- plot_df %>%
  group_by(specification) %>%
  mutate(
    pval_holm = p.adjust(
      pval,
      method = "holm"
    )
  ) %>%
  ungroup()

# ------------------------------------------------------------------------------
# 4. FORMAT VARIABLES
# ------------------------------------------------------------------------------

# Labels for sensitivity specifications
plot_df$specification <- factor(
  plot_df$specification,
  levels = c("certain", "all", "income", "shift"),
  labels = c("Certain", "All", "Income", "Shift")
)

# Assign significance stars based on Holm-adjusted p-values
plot_df$stars <- cut(
  plot_df$pval_holm,
  breaks = c(-Inf, 0.01, 0.05, 0.1, Inf),
  labels = c("***", "**", "*", "")
)

# Position stars just beyond the upper confidence interval
pad <- 0.10
plot_df$star_y <- plot_df$upper + pad

# Statement order
group_levels <- c(
  "Renewable energy mitigates climate change",
  "Renewable energy benefits the economy",
  "Renewable energy creates jobs",
  "Renewable energy causes new environmental problems",
  "Renewable energy increases electricity prices",
  "Electricity shortages will occur",
  "Cheap and abundant future energy is important",
  "Government should support low-carbon energy development"
)

# Wrap statement labels
plot_df$group <- str_wrap(
  plot_df$group,
  width = 20
)

group_levels <- str_wrap(
  group_levels,
  width = 20
)

plot_df$group <- factor(
  plot_df$group,
  levels = rev(group_levels)
)

# ------------------------------------------------------------------------------
# 5. PLOT DATA
# ------------------------------------------------------------------------------

dodge <- position_dodge(width = 0.85)

p <- ggplot(
  plot_df,
  aes(
    x = group,
    y = mean,
    shape = specification
  )
) +
  
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = "gray50"
  ) +
  
  geom_errorbar(
    aes(
      ymin = lower,
      ymax = upper
    ),
    width = 0.15,
    position = dodge
  ) +
  
  geom_point(
    size = 3,
    position = dodge
  ) +
  
  geom_text(
    aes(
      y = star_y,
      label = stars,
      group = specification
    ),
    position = dodge,
    size = 3.5,
    hjust = 0,
    vjust = 0.5,
    color = "black",
    show.legend = FALSE
  ) +
  
  labs(
    x = NULL,
    y = "Mean WTP difference (95% CI)",
    color = NULL,
    shape = NULL
  ) +
  
  theme_minimal(base_size = 12) +
  
  theme(
    axis.text.y = element_text(
      color = "black"
    ),
    axis.title.y = element_text(
      color = "black"
    ),
    legend.position = "bottom"
  ) +
  
  coord_flip()

print(p)

# ------------------------------------------------------------------------------
# 6. SAVE
# ------------------------------------------------------------------------------

ggsave(
  filename = file.path(
    output_R_path,
    "Fig_WTP_energy_sensitivity.png"
  ),
  plot = p,
  width = 7,
  height = 6,
  units = "in",
  dpi = 300
)
