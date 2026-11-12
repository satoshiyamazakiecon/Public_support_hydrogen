# ==============================================================================
# FILE: Fig_WTP_density.R 
#
# PURPOSE: Create a figure of willingness to pay density for double-bounded contingent valuation
# 
# DATA INPUT: 
#   results_WTP_forRespondents.csv
#   results_WTP_greenVSblue.csv
#
# OUTPUT:
#   Fig_WTP_density.png
#   Fig_WTP_density_combined.png
#   Fig_WTP_density_greenVSblue.png
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
# 1. WTP density
# ------------------------------------------------------------------------------

# Import data
data_WTP <- read_csv(
  file.path(output_STATA_path,
            "results_WTP_forRespondents.csv"))

if (any(!is.finite(data_WTP$wtp_baseline))) {
  stop("Non-finite WTP values detected in individual WTP data.")
}

# Some stats
summary_WTP_a <- data_WTP %>%
  summarise(
    n = sum(!is.na(wtp_baseline)),
    mean = mean(wtp_baseline, na.rm = TRUE),
    median = median(wtp_baseline, na.rm = TRUE),
    q25 = quantile(wtp_baseline, 0.25, na.rm = TRUE),
    q75 = quantile(wtp_baseline, 0.75, na.rm = TRUE),
    q90 = quantile(wtp_baseline, 0.90, na.rm = TRUE),
    min = min(wtp_baseline, na.rm = TRUE),
    max = max(wtp_baseline, na.rm = TRUE)
  )
summary_WTP_a

# x-axis scale for WTP density plots
wtp_a_xlim <- c(0, 25)
wtp_a_breaks <- seq(0, 25, by = 5)

stats_wtp <- quantile(data_WTP$wtp_baseline, probs = c(0.05,0.25,0.5, 0.75,0.9,0.95,0.99), na.rm = TRUE)
stats_wtp

# Plot  
p1 <- ggplot(data_WTP, aes(x = wtp_baseline)) +
  geom_density(colour = "darkgrey", linewidth = 0.8) +
  geom_vline(
    xintercept = summary_WTP_a$median,
    linetype = "dashed",
    colour = "black",
    linewidth = 0.7
  ) +
  labs(
    x = "WTP (A$/month)",
    y = "Density"
  ) +
  theme_classic(base_size = 14) +
  scale_x_continuous(breaks = wtp_a_breaks) +
  coord_cartesian(xlim = wtp_a_xlim) +
  theme(
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 13),
    axis.line = element_line(linewidth = 0.6),
    axis.ticks = element_line(linewidth = 0.5)
  )
print(p1)

# save
ggsave(
  filename = file.path(output_R_path, "Fig_WTP_density.png"),
  plot = p1,
  width = 6,
  height = 4,
  units = "in",
  dpi = 300
)

# ------------------------------------------------------------------------------
# 2. WTP relative to monthly electricity bill
# ------------------------------------------------------------------------------

data_WTP_relative <- data_WTP %>%
  mutate(bill = bill * 1000) %>%   # convert from A$'000 to A$
  filter(!is.na(bill), bill > 0) %>%
  mutate(wtp_relative = wtp_baseline / bill * 100)

# Summary stats
summary_WTP_b <- data_WTP_relative %>%
  summarise(
    n = sum(!is.na(wtp_relative)),
    mean = mean(wtp_relative, na.rm = TRUE),
    median = median(wtp_relative, na.rm = TRUE),
    q25 = quantile(wtp_relative, 0.25, na.rm = TRUE),
    q75 = quantile(wtp_relative, 0.75, na.rm = TRUE),
    q90 = quantile(wtp_relative, 0.90, na.rm = TRUE),
    pct_above_10 = mean(wtp_relative > 10, na.rm = TRUE) * 100,
    max = max(wtp_relative, na.rm = TRUE)
  )
summary_WTP_b

# x-axis scale for WTP density plots
wtp_b_xlim <- c(0, 55)
wtp_b_breaks <- seq(0, 55, by = 10)

stats_wtpr <- quantile(data_WTP_relative$wtp_relative, probs = c(0.25, 0.5, 0.75,0.9,0.99), na.rm = TRUE)
stats_wtpr

p2 <- ggplot(data_WTP_relative, aes(x = wtp_relative)) +
  geom_density(colour = "darkgrey", linewidth = 0.8) +
  geom_vline(
    xintercept = summary_WTP_b$median,
    linetype = "dashed",
    colour = "black",
    linewidth = 0.7
  ) +
  labs(
    x = "WTP (% of monthly electricity bill)",
    y = "Density"
  ) +
  theme_classic(base_size = 14) +
  scale_x_continuous(
    breaks = wtp_b_breaks
  ) +
  coord_cartesian(xlim = wtp_b_xlim) +
  theme(
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 13),
    axis.line = element_line(linewidth = 0.6),
    axis.ticks = element_line(linewidth = 0.5)
  )
print(p2)

# ------------------------------------------------------------------------------
# 3. Combine panels
# ------------------------------------------------------------------------------

p_combined <- p1 / p2 +
  plot_annotation(tag_levels = "a") &
  theme(
    plot.tag = element_text(size = 15, face = "bold")
  )

p_combined

# Save
ggsave(
  filename = file.path(output_R_path, "Fig_WTP_density_combined.png"),
  plot = p_combined,
  width = 6,
  height = 8,
  units = "in",
  dpi = 300
)

# ------------------------------------------------------------------------------
# 4. GREEN VS BLUE PLOT
# ------------------------------------------------------------------------------

# Import data
data_WTP_green <- read_csv(
  file.path(output_STATA_path,
            "results_WTP_greenVSblue.csv")
)

if (any(!is.finite(data_WTP_green$wtp_ind))) {
  stop("Non-finite WTP values detected in Green/Blue WTP data.")
}

# Compute medians per group
summary_WTP_green <- data_WTP_green %>%
  group_by(green) %>%
  summarise(
    n = sum(!is.na(wtp_ind)),
    mean = mean(wtp_ind, na.rm = TRUE),
    median = median(wtp_ind, na.rm = TRUE),
    q25 = quantile(wtp_ind, 0.25, na.rm = TRUE),
    q75 = quantile(wtp_ind, 0.75, na.rm = TRUE),
    annual_WTP = median * 12,
    five_year_WTP = median * 12 * 5,
    .groups = "drop"
  )
summary_WTP_green

summary_WTP_relative <- data_WTP_green %>%
  filter(!is.na(bill), bill > 0) %>%
  mutate(
    wtp_relative = wtp_ind / (bill * 1000) * 100
  ) %>%
  group_by(green) %>%
  summarise(
    n = sum(!is.na(wtp_relative)),
    mean = mean(wtp_relative, na.rm = TRUE),
    median = median(wtp_relative, na.rm = TRUE),
    q25 = quantile(wtp_relative, 0.25, na.rm = TRUE),
    q75 = quantile(wtp_relative, 0.75, na.rm = TRUE),
    .groups = "drop"
  )
summary_WTP_relative

# Plot
p3 <- ggplot(
  data_WTP_green,
  aes(x = wtp_ind, colour = factor(green))
) +
  geom_density(linewidth = 1) +
  geom_vline(
    data = summary_WTP_green,
    aes(
      xintercept = median,
      colour = factor(green)
    ),
    linetype = "dashed",
    linewidth = 0.8,
    show.legend = FALSE
  ) +
  labs(
    x = "WTP (A$/month)",
    y = "Density",
    colour = NULL
  ) +
  scale_colour_manual(
    values = c("0" = "#005AB5", "1" = "#00A878"),
    labels = c("0" = "Blue", "1" = "Green")
  ) +
  theme_classic(base_size = 14) +
  scale_x_continuous(breaks = wtp_a_breaks) +
  coord_cartesian(xlim = wtp_a_xlim) +
  theme(
    legend.position = "top",
    legend.text = element_text(size = 12),
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12)
  )
print(p3)

# Import green-blue WTP difference and its confidence interval
results_WTP_green <- read_csv(
  file.path(output_STATA_path,
            "results_WTP_green.csv")
)

# Extract the green-blue difference
green_diff <- results_WTP_green %>%
  filter(quantity == "diff")
green_diff

# Plot
p4 <- ggplot(green_diff, aes(x = b, y = 1)) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed",
    colour = "grey55"
  ) +
  geom_segment(
    aes(x = ll, xend = ul, y = 1, yend = 1),
    linewidth = 0.9,
    colour = "black"
  ) +
  geom_segment(
    aes(x = ll, xend = ll, y = 0.94, yend = 1.06),
    linewidth = 0.9,
    colour = "black"
  ) +
  geom_segment(
    aes(x = ul, xend = ul, y = 0.94, yend = 1.06),
    linewidth = 0.9,
    colour = "black"
  ) +
  geom_point(
    size = 3,
    colour = "black"
  ) +
  scale_x_continuous(
    breaks = scales::breaks_pretty(n = 7)
  ) +
  scale_y_continuous(
    breaks = 1,
    labels = NULL,
    limits = c(0.7, 1.3)
  ) +
  labs(
    x = "Difference in conditional median WTP (A$/month)",
    y = NULL
  ) +
  theme_classic(base_size = 14) +
  theme(
    axis.title = element_text(size = 14),
    axis.text = element_text(size = 12),
    axis.line.y = element_blank(),
    axis.ticks.y = element_blank()
  )
print(p4)

# Combine the two plots
p_fig2 <- p3 / p4 +
  plot_layout(heights = c(2.1, 0.8)) +
  plot_annotation(tag_levels = "a") &
  theme(
    plot.tag = element_text(size = 15, face = "bold")
  )

print(p_fig2)

# save
ggsave(
  filename = file.path(output_R_path, "Fig_WTP_density_greenVSblue.png"),
  plot = p_fig2,
  width = 6,
  height = 7,
  units = "in",
  dpi = 300
)
