# ==============================================================================
# FILE: Fig_WTP_energy.R
#
# PURPOSE:
#   1. Create a figure of willingness-to-pay differences for attitudes toward
#      energy
#   2. Create a table reporting group-specific WTP, WTP differences,
#      standard errors, and Holm-adjusted p-values
#
# DATA INPUT:
#   results_WTP_elec_shortage.csv
#   results_WTP_energy_develop.csv
#   results_WTP_funds.csv
#   results_WTP_elec_price.csv
#   results_WTP_renewable_mitigate.csv
#   results_WTP_renewable_employ.csv
#   results_WTP_renewable_noise.csv
#   results_WTP_renewable_economic.csv
#
# OUTPUT:
#   Fig_WTP_energy.png
#   Table_WTP_energy.csv
# ==============================================================================

library(ggplot2)
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
# 1. LOAD DATA
# ------------------------------------------------------------------------------

d1 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_renewable_mitigate.csv")
)

d2 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_renewable_economic.csv")
)

d3 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_renewable_employ.csv")
)

d4 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_renewable_noise.csv")
)

d5 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_elec_price.csv")
)

d6 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_elec_shortage.csv")
)

d7 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_energy_develop.csv")
)

d8 <- read.csv(
  file.path(output_STATA_path,
            "results_WTP_funds.csv")
)

results_list <- list(d1, d2, d3, d4, d5, d6, d7, d8)

attitude_labels <- c(
  "Renewable energy mitigates climate change",
  "Renewable energy benefits the economy",
  "Renewable energy creates jobs",
  "Renewable energy causes new environmental problems",
  "Renewable energy increases electricity prices",
  "Electricity shortages will occur",
  "Cheap and abundant future energy is important",
  "Government should support low-carbon energy development"
)

# ------------------------------------------------------------------------------
# 2. PREPARE RESULTS
# ------------------------------------------------------------------------------

wtp_group1 <- sapply(results_list, function(x) x[1, "b"])
wtp_group2 <- sapply(results_list, function(x) x[2, "b"])

wtp_diff <- sapply(results_list, function(x) x[3, "b"])
se_diff  <- sapply(results_list, function(x) x[3, "se"])
lower    <- sapply(results_list, function(x) x[3, "ll"])
upper    <- sapply(results_list, function(x) x[3, "ul"])
pvals    <- sapply(results_list, function(x) x[3, "pvalue"])

# Holm adjustment across the eight energy-attitude tests
pvals_holm <- p.adjust(pvals, method = "holm")

# ------------------------------------------------------------------------------
# 3. CREATE RESULTS TABLE
# ------------------------------------------------------------------------------

table_df <- data.frame(
  attitude = attitude_labels,
  wtp_group1 = wtp_group1,
  wtp_group2 = wtp_group2,
  wtp_difference = wtp_diff,
  se_difference = se_diff,
  pvalue_raw = pvals,
  pvalue_holm = pvals_holm
)

print(table_df)

write.csv(
  table_df,
  file.path(output_R_path, "Table_WTP_energy.csv"),
  row.names = FALSE
)

# ------------------------------------------------------------------------------
# 4. PREPARE DATA FOR FIGURE
# ------------------------------------------------------------------------------

plot_df <- data.frame(
  group = attitude_labels,
  mean = wtp_diff,
  lower = lower,
  upper = upper
)

plot_df$group <- str_wrap(plot_df$group, width = 20)
plot_df$group <- factor(
  plot_df$group,
  levels = rev(plot_df$group)
)

# ------------------------------------------------------------------------------
# 5. PLOT DATA
# ------------------------------------------------------------------------------

# X-axis scale for WTP differences
xlim <- c(-2, 8)
breaks <- seq(-2, 8, by = 2)

p <- ggplot(plot_df, aes(x = group, y = mean)) +
  geom_hline(
    yintercept = 0,
    linetype = "dashed",
    color = "gray50"
  ) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(ymin = lower, ymax = upper),
    width = 0.15
  ) +
  labs(
    x = NULL,
    y = "Mean WTP difference (95% CI)"
  ) +
  theme_minimal(base_size = 12) +
  scale_y_continuous(breaks = breaks) +
  coord_flip(ylim = xlim) +
  theme(
    axis.text.y = element_text(color = "black"),
    axis.title.y = element_text(color = "black")
  ) +
  coord_flip()

print(p)

# ------------------------------------------------------------------------------
# 6. SAVE FIGURE
# ------------------------------------------------------------------------------

ggsave(
  filename = file.path(output_R_path, "Fig_WTP_energy.png"),
  plot = p,
  width = 6,
  height = 5,
  units = "in",
  dpi = 300
)
