# ==============================================================================
# FILE: Fig_WTP_fullinteract_sensitivity.R
#
# PURPOSE:
#   Sensitivity analysis for the fully interacted Green/Blue x attitude models.
#
# DATA INPUT:
#   results_sensitivity_fullinteract_<attitude>_[certain,all,income,shift].csv
#
# OUTPUT:
#   Fig_WTP_fullinteract_sensitivity.png
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
# 1. DEFINE ATTITUDES AND SPECIFICATIONS
# ------------------------------------------------------------------------------

attitudes <- data.frame(
  file_stub = c(
    "climate_change",
    "cause_human",
    "nega_health",
    "nega_economic",
    "renewable_mitigate",
    "renewable_economic",
    "renewable_employ",
    "renewable_noise",
    "elec_price",
    "elec_shortage",
    "energy_develop",
    "funds"
  ),
  group = c(
    "Climate change occurring",
    "Human activities as main cause",
    "Climate change harms human health",
    "Climate change harms the economy",
    "Renewable energy mitigates climate change",
    "Renewable energy benefits the economy",
    "Renewable energy creates jobs",
    "Renewable energy causes new environmental problems",
    "Renewable energy increases electricity prices",
    "Electricity shortages will occur",
    "Cheap and abundant future energy is important",
    "Government should support low-carbon energy development"
  ),
  panel = c(
    rep("(a) Climate attitudes", 4),
    rep("(b) Energy attitudes", 8)
  ),
  stringsAsFactors = FALSE
)

specifications <- c("certain", "all", "income", "shift")

# ------------------------------------------------------------------------------
# 2. LOAD HETEROGENEITY RESULTS
# ------------------------------------------------------------------------------

read_heterogeneity <- function(file_stub, group, panel, specification) {

  df <- read.csv(
    file.path(
      output_STATA_path,
      paste0(
        "results_sensitivity_fullinteract_",
        file_stub,
        "_",
        specification,
        ".csv"
      )
    )
  )

  row_het <- df[df$quantity == "heterogeneity", ]

  if (nrow(row_het) != 1) {
    stop(
      paste0(
        "Could not identify exactly one heterogeneity row in: ",
        file_stub,
        " (",
        specification,
        ")"
      )
    )
  }

  data.frame(
    group = group,
    panel = panel,
    specification = specification,
    mean = row_het$b,
    se = row_het$se,
    lower = row_het$ll,
    upper = row_het$ul,
    pval = row_het$pvalue
  )
}

results <- list()

k <- 1

for (s in specifications) {

  for (i in seq_len(nrow(attitudes))) {

    results[[k]] <- read_heterogeneity(
      file_stub = attitudes$file_stub[i],
      group = attitudes$group[i],
      panel = attitudes$panel[i],
      specification = s
    )

    k <- k + 1
  }
}

plot_df <- bind_rows(results)

# ------------------------------------------------------------------------------
# 3. HOLM ADJUSTMENT
# ------------------------------------------------------------------------------

# Adjust separately for:
#   - four climate-attitude tests
#   - eight energy-attitude tests
# within each sensitivity specification

plot_df <- plot_df %>%
  group_by(panel, specification) %>%
  mutate(
    pval_holm = p.adjust(
      pval,
      method = "holm"
    )
  ) %>%
  ungroup()

# Assign significance stars using Holm-adjusted p-values
plot_df$stars <- cut(
  plot_df$pval_holm,
  breaks = c(-Inf, 0.01, 0.05, 0.10, Inf),
  labels = c("***", "**", "*", "")
)

# ------------------------------------------------------------------------------
# 4. FORMAT VARIABLES
# ------------------------------------------------------------------------------

plot_df$specification <- factor(
  plot_df$specification,
  levels = c("certain", "all", "income", "shift"),
  labels = c("Certain", "All", "Income", "Shift")
)

group_order <- str_wrap(
  attitudes$group,
  width = 28
)

plot_df$group <- str_wrap(
  plot_df$group,
  width = 28
)

plot_df$group <- factor(
  plot_df$group,
  levels = rev(group_order)
)

plot_df$panel <- factor(
  plot_df$panel,
  levels = c(
    "(a) Climate attitudes",
    "(b) Energy attitudes"
  )
)

# Position significance stars just beyond the upper confidence interval
pad <- 0.05 * diff(
  range(
    c(plot_df$lower, plot_df$upper),
    na.rm = TRUE
  )
)

plot_df$star_y <- plot_df$upper + pad

# ------------------------------------------------------------------------------
# 5. PLOT
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
    colour = "gray50"
  ) +

  geom_errorbar(
    aes(
      ymin = lower,
      ymax = upper,
      group = specification
    ),
    width = 0.12,
    position = dodge
  ) +

  geom_point(
    aes(group = specification),
    size = 2.8,
    position = dodge
  ) +

  geom_text(
    aes(
      y = star_y,
      label = stars,
      group = specification
    ),
    position = dodge,
    size = 4,
    vjust = 0,
    colour = "black",
    show.legend = FALSE
  ) +

  facet_grid(
    panel ~ .,
    scales = "free_y",
    space = "free_y"
  ) +

  labs(
    x = NULL,
    y = expression(
      paste(
        "Difference in WTP differences, ",
        Delta[A]^Green,
        " - ",
        Delta[A]^Blue,
        " (95% CI)"
      )
    ),
    shape = NULL
  ) +

  theme_minimal(base_size = 12) +

  theme(
    panel.background = element_rect(
      fill = "grey94",
      colour = NA
    ),
    axis.text.y = element_text(
      colour = "black",
      size = 10
    ),
    axis.title.y = element_text(
      colour = "black"
    ),
    strip.text.y = element_text(
      face = "bold",
      size = 11
    ),
    panel.spacing.y = grid::unit(
      0.6,
      "lines"
    ),
    legend.position = "bottom"
  ) +

  coord_flip()

print(p)

# ------------------------------------------------------------------------------
# 6. SAVE FIGURE
# ------------------------------------------------------------------------------

ggsave(
  filename = file.path(
    output_R_path,
    "Fig_WTP_fullinteract_sensitivity.png"
  ),
  plot = p,
  width = 6,
  height = 8,
  units = "in",
  dpi = 300
)
