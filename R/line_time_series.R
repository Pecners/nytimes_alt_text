library(tidyverse)
library(MetBrewer)
library(showtext)
library(ggtext)
library(glue)

df <- read_rds("data/all_data.rda")$df
nytimes_tweets <- read_rds("data/all_data.rda")$nytimes_tweets
image_alt_status <- read_rds("data/all_data.rda")$image_alt_status


c <- met.brewer("Hiroshige")
font_add_google("Vollkorn", "v")
showtext_auto()
showtext_opts(dpi = 300)

max_labs <- df |> 
  filter(created_at == max(created_at)) |>
  pivot_longer(cols = c("cum_yes", "cum_no"), names_to = "group2", values_to = "value") |>
  mutate(lab = case_when(group2 == "cum_yes" ~ glue("{value} With\nalt text"),
                         TRUE ~ glue("{value} Without\nalt text")))

df |>
  ggplot(aes(created_at, cum_yes)) +
  geom_line(size = 1, color = c[9]) +
  geom_line(aes(y = cum_no), size = 1, color = c[2]) +
  geom_text(data = max_labs, aes(created_at, value, label = lab, color = group2),
            hjust = 0, nudge_x = 60*60*10, lineheight = .9, family = "v",
            size = 4) +
  scale_color_manual(values = c(c[2], c[9])) +
  scale_y_continuous(breaks = c(0, 100, 200),
                     labels = c(0, 100, "200 tweets")) +
  scale_x_datetime(breaks = c(min(df$created_at), max(df$created_at)),
                   date_labels = "%b %d, %Y") +
  theme_minimal() +
  theme(text = element_text(family = "v"),
        legend.position = "none",
        panel.background = element_rect(color = "transparent"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x = element_text(hjust = c(0, 1)),
        plot.margin = margin(t = 10, r = 75),
        plot.title.position = "plot",
        plot.title = element_textbox(margin = margin(l = 10, b = 10), size = 25),
        plot.subtitle = element_textbox(width = unit(8, "in"), size = 14,
                                        margin = margin(l = 10, b = 40),
                                        lineheight = 1.5, color = "grey30"),
        plot.caption.position = "plot",
        plot.caption = element_textbox(width = unit(8, "in"), hjust = 0, 
                                       margin = margin(l = 10, b = 5, t = 10),
                                       lineheight = 1.3, color = "grey60")) +
  coord_cartesian(expand = FALSE, clip = "off") +
  labs(title = "Inconsistent accessibility of NYTimes tweets", x = "", y = "",
       subtitle = glue("The NYTimes frequently fails to include alt text with images. ",
                       "For example, between July 6th and August 4th, ",
                       "the main NYTimes Twitter account (@nytimes) posted ",
                       "413 static images with its tweets. Less than half ",
                       "provided alt text."),
       caption = glue("Source: @nytimes tweets from midnight on July 6, 2022 to 11:59 pm ",
                      "on August 4, 2022 (all times EDT)",
                      "<br>Analysis and graphic by Spencer Schien (@MrPecners)"))
  

ggsave(filename = "plots/time_series.png", bg = "white", h = 5, w = 9)
