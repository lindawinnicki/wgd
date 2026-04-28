rm(list = ls())
library(tidyverse)
library(ggplot2)
library(wesanderson)

df_exi <- read.csv("Results/SYN_params/Calco/MinGene/10/Segprofile.csv")
df_aur <- read.csv("Results/SYN_params/Auri/MinGene/10/Segprofile.csv")
df_cal <- read.csv("Results/SYN_params/Exig/MinGene/10/Segprofile.csv")
df_aur$species <- "auri"
df_cal$species <- "calco"
df_exi$species <- "exid"
df_all <- bind_rows(df_aur, df_cal, df_exi)


df_long <- df_all %>%
  pivot_longer(
    cols = ends_with(".fasta"),
    names_to = "genomes",
    values_to = "depth"
  ) %>%
  filter(!is.na(depth))

df_counts <- df_long %>% count(species, depth)

max_depth <- max(df_counts$depth)

pdf(file = "Scripts/Plots/syndepth_plot.pdf", 6, 5)
ggplot(df_counts, aes(x = factor(depth), y = n, fill = species)) +
  geom_col(
    position = position_dodge2(width = 0.8
      , preserve = "single")
  ) +
  scale_x_discrete(drop = FALSE,
    labels = c("1:1", "2:2", "3:3")
  ) +
  scale_fill_manual(
  values = wes_palette("FantasticFox1", n = 3)
  , labels = c("Auricularia subglabra"
  , "Calocera cornea"
  , "Exidia globulosa")
  ) +
  labs(x = "Syntenic Depth"
  , y = "# of Multiplicons"
  , title = "Intra-Specific Collinear Ratio of Multiplicons"
  ) +
  theme(
    text = element_text(family = "Palatino", size = 8)
    , legend.text = element_text(face = "italic", size = 9)
    , legend.title = element_blank()
    , plot.title = element_text(face = "bold", hjust = 0.5, size = 10)
    , axis.text.x = element_text(face = "bold", size = 10)
    , axis.text.y = element_text(face = "bold", size = 9)
)

dev.off()
