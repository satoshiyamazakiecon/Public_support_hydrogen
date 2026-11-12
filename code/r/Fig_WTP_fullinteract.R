# ==============================================================================
# FILE: Fig_WTP_fullinteract.R
#
# PURPOSE:
#   Compare whether WTP differences associated with climate and energy attitudes
#   differ between Green and Blue hydrogen scenarios using the fully interacted
#   model.
#
# DATA INPUT:
#   results_WTP_fullinteract_<attitude>.csv
#
# OUTPUT:
#   Fig_WTP_heterogeneity.png
#   Table_WTP_heterogeneity.csv
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

# Climate attitudes
c1 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_climate_change.csv"
))

c2 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_cause_human.csv"
))

c3 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_nega_health.csv"
))

c4 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_nega_economic.csv"
))

# Energy attitudes
e1 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_renewable_mitigate.csv"
))

e2 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_renewable_economic.csv"
))

e3 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_renewable_employ.csv"
))

e4 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_renewable_noise.csv"
))

e5 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_elec_price.csv"
))

e6 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_elec_shortage.csv"
))

e7 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_energy_develop.csv"
))

e8 <- read.csv(file.path(
  output_STATA_path, "results_WTP_fullinteract_funds.csv"
))

# ------------------------------------------------------------------------------
# 2. LABELS
# ------------------------------------------------------------------------------

climate_groups <- c(
  "Climate change occurring",
  "Human activities as main cause",
  "Climate change harms human health",
  "Climate change harms the economy"
)

energy_groups <- c(
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
# 3. EXTRACT HETEROGENEITY RESULTS
# ------------------------------------------------------------------------------

extract_heterogeneity <- function(files, groups, panel) {
  
  out <- lapply(files, function(x) {
    
    # Extract WTP differences within Green and Blue,
    # and their difference
    row_green <- x[x$quantity == "att_diff_Green", ]
    row_blue  <- x[x$quantity == "att_diff_Blue", ]
    row_het   <- x[x$quantity == "heterogeneity", ]
    
    # Check that each required row is found exactly once
    if (
      nrow(row_green) != 1 ||
      nrow(row_blue) != 1 ||
      nrow(row_het) != 1
    ) {
      stop(
        "Could not identify the required WTP contrast rows in an input file."
      )
    }
    
    data.frame(
      delta_green = row_green$b,
      delta_blue = row_blue$b,
      heterogeneity = row_het$b,
      se = row_het$se,
      lower = row_het$ll,
      upper = row_het$ul,
      pval = row_het$pvalue
    )
  })
  
  out <- do.call(rbind, out)
  
  data.frame(
    group = groups,
    panel = panel,
    delta_green = out$delta_green,
    delta_blue = out$delta_blue,
    mean = out$heterogeneity,
    se = out$se,
    lower = out$lower,
    upper = out$upper,
    pval = out$pval
  )
}

# Climate
climate_df <- extract_heterogeneity(
  list(c1, c2, c3, c4),
  climate_groups,
  "(a) Climate attitudes"
)

# Energy
energy_df <- extract_heterogeneity(
  list(e1, e2, e3, e4, e5, e6, e7, e8),
  energy_groups,
  "(b) Energy attitudes"
)

# ------------------------------------------------------------------------------
# 4. HOLM ADJUSTMENT
# ------------------------------------------------------------------------------

# Adjust separately within the four climate-attitude tests
climate_df$pval_holm <- p.adjust(
  climate_df$pval,
  method = "holm"
)

# Adjust separately within the eight energy-attitude tests
energy_df$pval_holm <- p.adjust(
  energy_df$pval,
  method = "holm"
)

# Combine
plot_df <- rbind(
  climate_df,
  energy_df
)

# ------------------------------------------------------------------------------
# 5. SAVE RESULTS TABLE
# ------------------------------------------------------------------------------

table_df <- data.frame(
  attitude = plot_df$group,
  delta_green = plot_df$delta_green,
  delta_blue = plot_df$delta_blue,
  heterogeneity = plot_df$mean,
  se_heterogeneity = plot_df$se,
  pvalue_raw = plot_df$pval,
  pvalue_holm = plot_df$pval_holm
)

print(table_df)

write.csv(
  table_df,
  file.path(output_R_path, "Table_WTP_heterogeneity.csv"),
  row.names = FALSE
)

# ------------------------------------------------------------------------------
# 6. FORMAT VARIABLES FOR FIGURE
# ------------------------------------------------------------------------------

# Wrap long labels
plot_df$group <- str_wrap(
  plot_df$group,
  width = 28
)

# Preserve desired order
group_order <- str_wrap(
  c(climate_groups, energy_groups),
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

# ------------------------------------------------------------------------------
# 7. PLOT
# ------------------------------------------------------------------------------

# X-axis scale for WTP differences
xlim <- c(-8, 8)
breaks <- seq(-8, 8, by = 4)

p <- ggplot(
  plot_df,
  aes(
    x = group,
    y = mean
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
      ymax = upper
    ),
    width = 0.12
  ) +
  
  geom_point(
    size = 2.8
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
    )
  ) +
  
  theme_minimal(base_size = 12) +
  scale_y_continuous(breaks = breaks) +
  coord_flip(ylim = xlim) +
  
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
    
    panel.spacing.y = unit(
      0.6,
      "lines"
    )
  ) +
  
  coord_flip()

print(p)

# ------------------------------------------------------------------------------
# 8. SAVE FIGURE
# ------------------------------------------------------------------------------

ggsave(
  filename = file.path(
    output_R_path,
    "Fig_WTP_fullinteract.png"
  ),
  plot = p,
  width = 6,
  height = 8,
  units = "in",
  dpi = 300
)
