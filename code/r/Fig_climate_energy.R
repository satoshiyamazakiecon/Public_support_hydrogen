# ==============================================================================
# FILE: Fig_climate_energy.R 
#
# PURPOSE: Create a figure of opinions about climate change and energy
# 
# DATA INPUT: 
#   hydro_base_1st.dta
#
# OUTPUT:
#   Fig_climate_energy.png
# ==============================================================================

library(haven)
library(dplyr)
library(tidyr)
library(ggplot2)
library(forcats)
library(stringr)
library(patchwork)
library(here)

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

df <- read_dta(
  file.path(output_STATA_path,
            "hydro_base_1st.dta"))

vars_climate <- c("climate_change_ord", 
                  "cause_human_ord",
                  "nega_health_ord",
                  "nega_economic_ord")

vars_energy <- c("renewable_mitigate_ord",
                 "renewable_economic_ord",
                 "renewable_employ_ord",
                 "renewable_noise_ord",
                 "elec_price_ord",
                 "elec_shortage_ord",
                 "energy_develop_ord",
                 "funds_ord")

labels_climate <- c(
  climate_change_ord = "Climate change occurring",
  cause_human_ord    = "Human activities as main cause",
  nega_health_ord    = "Climate change harms human health",
  nega_economic_ord  = "Climate change harms the economy"
) %>% str_wrap(width = 60)

labels_energy <- c(
  renewable_mitigate_ord = "Renewable energy mitigates climate change",
  renewable_economic_ord = "Renewable energy benefits the economy",
  renewable_employ_ord   = "Renewable energy creates jobs",
  renewable_noise_ord    = "Renewable energy causes new environmental problems",
  elec_price_ord         = "Renewable energy increases electricity prices",
  elec_shortage_ord      = "Electricity shortages will occur",
  energy_develop_ord     = "Cheap and abundant future energy is important",
  funds_ord              = "Government should support low-carbon energy development"
) %>% str_wrap(width = 60)

level_labels <- c("Strongly disagree", "Disagree",
                  "I don't know", "Agree", "Strongly agree")

# ------------------------------------------------------------------------------
# 2. PREPARE DATA
# ------------------------------------------------------------------------------

plot_climate <- df %>%
  select(all_of(vars_climate)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  filter(!is.na(value)) %>%
  mutate(
    value    = factor(value, levels = 1:5, labels = level_labels, ordered = TRUE),
    variable = recode(variable, !!!labels_climate),
    variable = fct_rev(factor(variable, levels = labels_climate)) 
  )

plot_energy <- df %>%
  select(all_of(vars_energy)) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  filter(!is.na(value)) %>%
  mutate(
    value    = factor(value, levels = 1:5, labels = level_labels, ordered = TRUE),
    variable = recode(variable, !!!labels_energy),
    variable = fct_rev(factor(variable, levels = labels_energy)) 
  )

pct_climate <- plot_climate %>%
  count(variable, value) %>%
  group_by(variable) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ungroup()

pct_energy <- plot_energy %>%
  count(variable, value) %>%
  group_by(variable) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ungroup()

diverge_climate <- pct_climate %>%
  mutate(
    pct_signed = case_when(
      value %in% c("Strongly disagree", "Disagree") ~ -pct,
      value == "I don't know"                       ~ pct / 2,  # split neutral, half each side
      TRUE                                          ~ pct
    )
  )

diverge_energy <- pct_energy %>%
  mutate(
    pct_signed = case_when(
      value %in% c("Strongly disagree", "Disagree") ~ -pct,
      value == "I don't know"                       ~ pct / 2,  # split neutral, half each side
      TRUE                                          ~ pct
    )
  )

neg_climate <- diverge_climate %>%
  filter(value %in% c("Strongly disagree", "Disagree", "I don't know")) %>%
  mutate(
    pct_signed = if_else(value == "I don't know", -pct_signed, pct_signed),
    value = factor(value, levels = c("Strongly disagree", "Disagree", "I don't know"))
  )

pos_climate <- diverge_climate %>%
  filter(value %in% c("I don't know", "Agree", "Strongly agree")) %>%
  mutate(
    value = factor(value, levels = c("Strongly agree", "Agree", "I don't know"))
  )

neg_energy <- diverge_energy %>%
  filter(value %in% c("Strongly disagree", "Disagree", "I don't know")) %>%
  mutate(
    pct_signed = if_else(value == "I don't know", -pct_signed, pct_signed),
    value = factor(value, levels = c("Strongly disagree", "Disagree", "I don't know"))
  )

pos_energy <- diverge_energy %>%
  filter(value %in% c("I don't know", "Agree", "Strongly agree")) %>%
  mutate(
    value = factor(value, levels = c("Strongly agree", "Agree", "I don't know"))
  )

# ------------------------------------------------------------------------------
# 3. Diverging stacked bar chart
# ------------------------------------------------------------------------------

likert_colors <- c(
  "Strongly disagree"  = "#b2182b",
  "Disagree"           = "#ef8a62",
  "I don't know"       = "#d9d9d9",
  "Agree"              = "#67a9cf",
  "Strongly agree"     = "#2166ac"
)

p_climate <- ggplot() +
  geom_col(data = neg_climate, aes(x = variable, y = pct_signed, fill = value), width = 0.65) +
  geom_col(data = pos_climate, aes(x = variable, y = pct_signed, fill = value), width = 0.65) +
  coord_flip() +
  scale_fill_manual(values = likert_colors, breaks = level_labels, name = NULL) +
  scale_y_continuous(labels = function(x) paste0(abs(x), "%")) +
  labs(x = NULL, y = "% of respondents") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        panel.grid.major.y = element_blank())

print(p_climate)

p_energy <- ggplot() +
  geom_col(data = neg_energy, aes(x = variable, y = pct_signed, fill = value), width = 0.65) +
  geom_col(data = pos_energy, aes(x = variable, y = pct_signed, fill = value), width = 0.65) +
  coord_flip() +
  scale_fill_manual(values = likert_colors, breaks = level_labels, name = NULL) +
  scale_y_continuous(labels = function(x) paste0(abs(x), "%")) +
  labs(x = NULL, y = "% of respondents") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom",
        panel.grid.major.y = element_blank())

print(p_energy)

# ------------------------------------------------------------------------------
# 4. Combine plots
# ------------------------------------------------------------------------------

max_pos_climate <- pos_climate %>% group_by(variable) %>% summarise(tot = sum(pct_signed)) %>% pull(tot)
max_neg_climate <- neg_climate %>% group_by(variable) %>% summarise(tot = sum(pct_signed)) %>% pull(tot)
max_pos_energy  <- pos_energy  %>% group_by(variable) %>% summarise(tot = sum(pct_signed)) %>% pull(tot)
max_neg_energy  <- neg_energy  %>% group_by(variable) %>% summarise(tot = sum(pct_signed)) %>% pull(tot)

max_extent <- max(abs(c(max_pos_climate, max_neg_climate, max_pos_energy, max_neg_energy)))
axis_limit <- ceiling(max_extent / 10) * 10

shared_scale <- scale_y_continuous(
  limits = c(-axis_limit, axis_limit),
  labels = function(x) paste0(abs(x), "%")
)

p_climate <- p_climate + shared_scale + labs(title = "(a) Climate change") +
  theme(plot.title = element_text(face = "bold", hjust = 0))

p_energy <- p_energy + shared_scale + labs(title = "(b) Energy") +
  theme(plot.title = element_text(face = "bold", hjust = 0))

combined_plot <- p_climate / p_energy +
  plot_layout(guides = "collect") &
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 11),
    legend.title = element_text(size = 11),
    legend.key.size = unit(0.5, "cm"),
    axis.text.y = element_text(size = 12),
    axis.text.x = element_text(size = 10),
    axis.title.x = element_text(size = 12),
    plot.margin = margin(5, 5, 15, 5)
  ) &
  guides(fill = guide_legend(nrow = 1, byrow = TRUE))

print(combined_plot)

# ------------------------------------------------------------------------------
# 5. SAVE
# ------------------------------------------------------------------------------

ggsave(
  filename = file.path(output_R_path, "Fig_climate_energy.png"),
  plot = combined_plot,
  width = 10,
  height = 9.5,
  units = "in",
  dpi = 300
)
