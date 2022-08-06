library(rtweet)
library(lubridate)

nytimes_tweets <- get_timeline(user = "@nytimes", n = 10000, retryonratelimit = TRUE)

nytweets_limited <- nytimes_tweets |>
  mutate(created_at = ymd_hms(created_at, tz = "America/New_York")) %>%
  filter(date(created_at) > date(min(created_at)) &
           date(created_at) < date(max(created_at)))
# For some reason, get_timeline isn't properly returning alt text,
# but lookup_tweets is returning correct alt text

image_alt_status <- map_df(1:nrow(nytweets_limited), function(i) {
  pic <- nytweets_limited$entities[[i]]$media |>
    pull(id)
  
  vid <- str_detect(nytweets_limited$entities[[i]]$media$expanded_url,
                    "video")
  
  if (!is.na(pic) & !vid) {
    tmp <- lookup_tweets(nytweets_limited[i, "id_str"])
    med <- tmp$entities[[1]]$media
    map_df(1:nrow(med), function(j) {
      df <- tibble(
        i_ind = i,
        med_ind = j,
        created_at = nytweets_limited[[i, "created_at"]],
        id_str = nytweets_limited[[i, "id_str"]],
        has_alt = ifelse(!is.na(med[[j, "ext_alt_text"]]),
                         TRUE, FALSE),
        t_source = tmp$source
      )
    })
  }
})

df <- image_alt_status |>
  arrange(created_at) |>
  mutate(group = case_when(is.na(has_alt) ~ "none",
                           has_alt ~ "pos",
                           TRUE ~ "neg"),
         cum_yes = cumsum(group == "pos"),
         cum_no = cumsum(group == "neg"))

all_data <- list(df = df,
                 image_alt_status = image_alt_status,
                 nytweets_limited = nytweets_limited,
                 nytimes_tweets = nytimes_tweets)

saveRDS(all_data, "data/all_data.rda")





