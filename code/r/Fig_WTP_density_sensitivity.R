# ==============================================================================
# FILE: Fig_WTP_density_sensitivity.R
#
# PURPOSE:
#   Create 2 x 2 density plots of respondent-specific conditional median WTP from
#   sensitivity analyses, comparing Green and Blue scenarios,
#   using a common x-axis scale
#
# DATA INPUT:
#   results_sensitivity_WTP_green_certain.csv
#   results_sensitivity_WTP_green_all.csv
#   results_sensitivity_WTP_green_income.csv
#   results_sensitivity_WTP_green_shift.csv
#
# OUTPUT:
#   Fig_WTP_density_sensitivity.png
# ==============================================================================

library(readr)
library(ggplot2)
library(dplyr)
library(patchwork)

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

data_certain <- read_csv(
  file.path(output_STATA_path, "results_sensitivity_WTP_green_certain.csv")
)

data_all <- read_csv(
  file.path(output_STATA_path, "results_sensitivity_WTP_green_all.csv")
)

data_income <- read_csv(
  file.path(output_STATA_path, "results_sensitivity_WTP_green_income.csv")
)

data_shift <- read_csv(
  file.path(output_STATA_path, "results_sensitivity_WTP_green_shift.csv")
)

# check if there are any non-finite WTP values
n_nonfinite_certain <- sum(!is.finite(data_certain$wtp_ind))
n_nonfinite_all     <- sum(!is.finite(data_all$wtp_ind))
n_nonfinite_income  <- sum(!is.finite(data_income$wtp_ind))
n_nonfinite_shift   <- sum(!is.finite(data_shift$wtp_ind))

if (
  n_nonfinite_certain > 0 ||
  n_nonfinite_all > 0 ||
  n_nonfinite_income > 0 ||
  n_nonfinite_shift > 0
) {
  stop(
    paste0(
      "Non-finite WTP values detected: ",
      "Certain = ", n_nonfinite_certain, ", ",
      "All = ", n_nonfinite_all, ", ",
      "Income = ", n_nonfinite_income, ", ",
      "Shift = ", n_nonfinite_shift, "."
    )
  )
}

# ------------------------------------------------------------------------------
# 2. DEFINE COMMON X-AXIS RANGE
# ------------------------------------------------------------------------------

x_range <- range(
  c(
    data_certain$wtp_ind,
    data_all$wtp_ind,
    data_income$wtp_ind,
    data_shift$wtp_ind
  ),
  na.rm = TRUE
)

# Optional: print it
x_range

# ------------------------------------------------------------------------------
# 3. FUNCTION TO CREATE DENSITY PLOT
# ------------------------------------------------------------------------------

make_density_plot <- function(data, title, x_range) {
  
  medians <- data %>%
    group_by(green) %>%
    summarise(
      med = median(wtp_ind, na.rm = TRUE),
      .groups = "drop"
    )
  
  ggplot(data, aes(x = wtp_ind, colour = factor(green))) +
    geom_density(linewidth = 1) +
    
    geom_vline(
      data = medians,
      aes(xintercept = med, colour = factor(green)),
      linetype = "dashed",
      linewidth = 0.8,
      show.legend = FALSE
    ) +
    
    coord_cartesian(xlim = x_range) +
    
    labs(
      title = title,
      x = "WTP (A$/month)",
      y = "Density",
      colour = NULL
    ) +
    
    scale_colour_manual(
      values = c("0" = "#005AB5", "1" = "#00A878"),
      labels = c("0" = "Blue", "1" = "Green")
    ) +
    
    theme_classic(base_size = 14) +
    
    theme(
      plot.title = element_text(
        size = 14,
        face = "bold",
        hjust = 0,
        margin = margin(b = 8)
      ),
      legend.position = "top",
      legend.text = element_text(size = 12),
      axis.title = element_text(size = 14),
      axis.text = element_text(size = 12)
    )
}

# ------------------------------------------------------------------------------
# 4. CREATE PANELS
# ------------------------------------------------------------------------------

p1 <- make_density_plot(
  data_certain,
  "(a) Certain respondents only",
  x_range
) +
  labs(x = NULL)

p2 <- make_density_plot(
  data_all,
  "(b) All respondents",
  x_range
) +
  labs(x = NULL)

p3 <- make_density_plot(
  data_income,
  "(c) Including household income",
  x_range
)

p4 <- make_density_plot(
  data_shift,
  "(d) Shift-only model",
  x_range
)

# ------------------------------------------------------------------------------
# 5. COMBINE PANELS
# ------------------------------------------------------------------------------

p_combined <- (
  p1 /
    p2 /
    p3 /
    p4
) +
  plot_layout(
    ncol = 2,
    guides = "collect"
  ) &
  theme(
    legend.position = "top"
  )

p_combined

# ------------------------------------------------------------------------------
# 6. SAVE FIGURE
# ------------------------------------------------------------------------------

ggsave(
  filename = file.path(output_R_path, "Fig_WTP_density_sensitivity.png"),
  plot = p_combined,
  width = 9,
  height = 6,
  units = "in",
  dpi = 300
)
