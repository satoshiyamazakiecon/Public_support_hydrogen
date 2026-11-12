# ==============================================================================
# FILE: Fig_WTP_climate_sensitivity.R
#
# PURPOSE:
#   Create a figure of willingness-to-pay differences for attitudes toward
#   climate change under three sensitivity specifications:
#   Certain, All, and Income
#
#   Statistical significance is based on Holm-adjusted p-values,
#   correcting for the four climate-attitude tests within each specification.
#
# DATA INPUT:
#   results_sensitivity_climate_change_[certain,all,income,shift].csv
#   results_sensitivity_cause_human_[certain,all,income,shift].csv
#   results_sensitivity_nega_health_[certain,all,income,shift].csv
#   results_sensitivity_nega_economic_[certain,all,income,shift].csv
#
# OUTPUT:
#   Fig_WTP_climate_sensitivity.png
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

# Climate change occurring
d1_certain <- read_result(
  "climate_change",
  "Climate change occurring",
  "certain"
)

d1_all <- read_result(
  "climate_change",
  "Climate change occurring",
  "all"
)

d1_income <- read_result(
  "climate_change",
  "Climate change occurring",
  "income"
)

d1_shift <- read_result(
  "climate_change",
  "Climate change occurring",
  "shift"
)

# Human activities as main cause
d2_certain <- read_result(
  "cause_human",
  "Human activities as main cause",
  "certain"
)

d2_all <- read_result(
  "cause_human",
  "Human activities as main cause",
  "all"
)

d2_income <- read_result(
  "cause_human",
  "Human activities as main cause",
  "income"
)

d2_shift <- read_result(
  "cause_human",
  "Human activities as main cause",
  "shift"
)

# Climate change harms human health
d3_certain <- read_result(
  "nega_health",
  "Climate change harms human health",
  "certain"
)

d3_all <- read_result(
  "nega_health",
  "Climate change harms human health",
  "all"
)

d3_income <- read_result(
  "nega_health",
  "Climate change harms human health",
  "income"
)

d3_shift <- read_result(
  "nega_health",
  "Climate change harms human health",
  "shift"
)

# Climate change harms the economy
d4_certain <- read_result(
  "nega_economic",
  "Climate change harms the economy",
  "certain"
)

d4_all <- read_result(
  "nega_economic",
  "Climate change harms the economy",
  "all"
)

d4_income <- read_result(
  "nega_economic",
  "Climate change harms the economy",
  "income"
)

d4_shift <- read_result(
  "nega_economic",
  "Climate change harms the economy",
  "shift"
)

# Combine all results
plot_df <- bind_rows(
  d1_certain, d1_all, d1_income, d1_shift,
  d2_certain, d2_all, d2_income, d2_shift,
  d3_certain, d3_all, d3_income, d3_shift,
  d4_certain, d4_all, d4_income, d4_shift  
)

# ------------------------------------------------------------------------------
# 2. HOLM ADJUSTMENT
# ------------------------------------------------------------------------------

# Adjust p-values across the four climate-attitude tests
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
# 3. FORMAT VARIABLES
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

# Position stars just above/right of upper CI
pad <- 0.05 * diff(
  range(
    c(plot_df$lower, plot_df$upper),
    na.rm = TRUE
  )
)

plot_df$star_y <- plot_df$upper + pad

# Wrap statement labels
plot_df$group <- str_wrap(
  plot_df$group,
  width = 20
)

# Preserve desired order
group_levels <- str_wrap(
  c(
    "Climate change occurring",
    "Human activities as main cause",
    "Climate change harms human health",
    "Climate change harms the economy"
  ),
  width = 20
)

plot_df$group <- factor(
  plot_df$group,
  levels = rev(group_levels)
)

# ------------------------------------------------------------------------------
# 4. PLOT DATA
# ------------------------------------------------------------------------------

dodge <- position_dodge(width = 0.65)

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
    size = 4.5,
    vjust = 0,
    color = "black",
    show.legend = FALSE
  ) +
  
  labs(
    x = NULL,
    y = "Mean WTP difference (95% CI)",
    color = NULL,
    shape = NULL
  ) +
  
  theme_minimal(base_size = 13) +
  
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
# 5. SAVE
# ------------------------------------------------------------------------------

ggsave(
  filename = file.path(
    output_R_path,
    "Fig_WTP_climate_sensitivity.png"
  ),
  plot = p,
  width = 7,
  height = 5,
  units = "in",
  dpi = 300
)
