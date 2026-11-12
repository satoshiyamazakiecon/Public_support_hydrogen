# ==============================================================================
# FILE: Fig_attitudes_corr.R
#
# PURPOSE:
#   Calculate Pearson correlations between climate change and energy
#   attitude variables and visualise them in a lower-triangular heatmap.
#
# DATA INPUT:
#   hydro_base_1st.dta
#
# OUTPUT:
#   Fig_attitude_correlations.png
#   Fig_attitude_correlations.pdf
#   Table_attitude_correlations.csv
#   Table_attitude_correlations_N.csv
# ==============================================================================

library(haven)
library(dplyr)
library(tidyr)
library(ggplot2)

project_root <- file.path(
  Sys.getenv("USERPROFILE"),
  "GitHub",
  "Australia_Hydrogen_WTP"
)

source(file.path(project_root, "code/r/config.R"))

# ------------------------------------------------------------
# 1. LOAD DATA
# ------------------------------------------------------------

df <- read_dta(
  file.path(output_STATA_path, "hydro_base_1st.dta")
)

# ------------------------------------------------------------
# 2. DEFINE ATTITUDE VARIABLES AND LABELS
# ------------------------------------------------------------

attitude_labels <- c(
  # Climate change attitudes
  climate_change    = "Climate change occurring",
  cause_human       = "Human activities as main cause",
  nega_health       = "Climate change harms human health",
  nega_economic     = "Climate change harms the economy",
  
  # Energy attitudes
  renewable_mitigate = "Renewable energy mitigates climate change",
  renewable_economic = "Renewable energy benefits the economy",
  renewable_employ   = "Renewable energy creates jobs",
  renewable_noise    = "Renewable energy causes environmental problems",
  elec_price         = "Renewable energy increases electricity prices",
  elec_shortage      = "Electricity shortages will occur",
  energy_develop     = "Cheap and abundant future energy is important",
  funds              = "Government should support low-carbon energy development"
)

vars <- names(attitude_labels)

# Select attitude variables
attitudes <- df %>%
  select(all_of(vars)) %>%
  mutate(across(everything(), as.numeric))

# ------------------------------------------------------------
# 3. CALCULATE PEARSON CORRELATIONS
# ------------------------------------------------------------

cor_matrix <- cor(
  attitudes,
  method = "pearson",
  use = "pairwise.complete.obs"
)

# Create descriptive row and column labels
attitude_codes <- c(
  paste0("C", 1:4),
  paste0("E", 1:8)
)

display_labels <- paste0(
  attitude_codes, ". ", unname(attitude_labels)
)

cor_table <- round(cor_matrix, 3)

rownames(cor_table) <- display_labels
colnames(cor_table) <- display_labels

# Export full correlation table
write.csv(
  cor_table,
  file.path(output_R_path, "Table_attitude_correlations.csv"),
  row.names = TRUE,
  na = ""
)

# ------------------------------------------------------------
# 4. PREPARE DATA FOR LOWER-TRIANGULAR HEATMAP
# ------------------------------------------------------------

plot_data <- as.data.frame(as.table(cor_matrix)) %>%
  rename(
    row_var = Var1,
    col_var = Var2,
    correlation = Freq
  ) %>%
  mutate(
    row_num = match(as.character(row_var), vars),
    col_num = match(as.character(col_var), vars)
  ) %>%
  filter(row_num > col_num)

# ------------------------------------------------------------
# 5. PLOT HEATMAP
# ------------------------------------------------------------

fig <- ggplot(
  plot_data,
  aes(x = col_num, y = row_num)
) +
  geom_tile(
    aes(fill = correlation),
    colour = "white",
    linewidth = 0.5
  ) +
  geom_text(
    aes(
      label = sprintf("%.2f", correlation),
      colour = ifelse(
        abs(correlation) >= 0.65,
        "white",
        "black"
      )
    ),
    size = 3.2,
    na.rm = TRUE
  ) +
  scale_colour_identity() +
  scale_fill_gradient2(
    low = "#3B4CC0",
    mid = "white",
    high = "#B40426",
    midpoint = 0,
    limits = c(-1, 1),
    breaks = c(-1, -0.5, 0, 0.5, 1),
    name = "Correlation",
    na.value = "grey90"
  ) +
  scale_x_continuous(
    breaks = 1:12,
    labels = c(paste0("C", 1:4), paste0("E", 1:8)),
    limits = c(0.5, 12.5),
    expand = c(0, 0),
    position = "top"
  ) +
  scale_y_reverse(
    breaks = 1:12,
    labels = display_labels,
    limits = c(12.5, 0.5),
    expand = c(0, 0)
  ) +
  coord_fixed() +
  labs(
    x = NULL,
    y = NULL,
    caption = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(
      size = 14,   # Top axis labels
      colour = "black"
    ),
    axis.text.y = element_text(
      size = 13,   # Attitude statements on the left
      colour = "black"
    ),
    axis.ticks = element_blank(),
    legend.position = "right",
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 13),
    plot.caption = element_text(
      size = 12,
      hjust = 0
    )
  )

print(fig)

# ------------------------------------------------------------
# 6. SAVE FIGURE
# ------------------------------------------------------------

ggsave(
  file.path(output_R_path, "Fig_attitude_correlations.png"),
  plot = fig,
  width = 12,
  height = 9,
  dpi = 300,
  bg = "white"
)

