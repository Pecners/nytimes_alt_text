library(lubridate)
library(tidyverse)
library(ggtext)
library(glue)
library(MetBrewer)
library(showtext)

all_tweets <- read_rds("data/more_data.rda")

fin <- all_tweets |> 
  filter(type == "photo" & acc != "@bbcbreaking") |> 
  arrange(created_at) |> 
  group_by(acc) |> 
  mutate(group = ifelse(is.na(ext_alt_text), "neg", "pos"),
         cum_yes = cumsum(group == "pos"),
         cum_no = cumsum(group == "neg")) 

accounts <- unique(fin$acc)

c <- met.brewer("Hiroshige")
font_add_google("Vollkorn", "v")
showtext_auto()
showtext_opts(dpi = 300)

walk(accounts, function(a) {
  max_labs <- fin |> 
    filter(created_at == max(created_at) & acc == a) |>
    mutate(ind = row_number()) |> 
    filter(ind == max(ind)) |> 
    pivot_longer(cols = c("cum_yes", "cum_no"), names_to = "group2", values_to = "value") |>
    mutate(lab = case_when(group2 == "cum_yes" ~ glue("{value} With\nalt text"),
                           TRUE ~ glue("{value} Without\nalt text")))
  
  this_a <- fin |> 
    filter(acc == a)
  
  m <- max(c(this_a$cum_yes, this_a$cum_no))
  if (m > 100) {
    l <- round(m/100) * 100
  } else {
    l <- round(m/10) * 10
  }
  

  this_a |> 
    ggplot(aes(created_at, cum_yes)) +
    geom_line(size = 1, color = c[1]) +
    geom_line(aes(y = cum_no), size = 1, color = "grey70") +
    geom_text(data = max_labs, aes(created_at, value, label = lab, color = group2),
              hjust = 0, nudge_x = 60*60*10, lineheight = .9, family = "v",
              size = 4) +
    scale_color_manual(values = c("grey70", c[1])) +
    scale_y_continuous(breaks = c(0, l/2, l),
                       labels = c(0, l/2, glue("{l} tweets"))) +
    scale_x_datetime(breaks = c(min(this_a$created_at), max(this_a$created_at)),
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
    labs(title = glue("Use of alt text by {a}"), x = "", y = "",
         subtitle = glue("In its last 3250 tweets, {a} posted {nrow(this_a)} ",
                         "static images with its tweets; ",
                         "<span style='color:{c[1]}'>**{max(this_a$cum_yes)} ",
                         "provided alt text**</span>."),
         caption = glue("Source: {a} tweets",
                        "<br>Analysis and graphic by Spencer Schien (@MrPecners)"))
  
  ggsave(glue("plots/{a}.png"), bg = "white", h = 5, w = 9)
})






all_tweets |> 
  filter(type == "photo") |> 
  mutate(created_date = format_date(created_at)) |> 
  arrange(created_date) |> 
  group_by(acc, has_alt = is.na(ext_alt_text)) |> 
  count() |> 
  ungroup() |> 
  group_by(acc) |> 
  mutate(perc = n / sum(n))
  