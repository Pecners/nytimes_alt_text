library(tidyverse)
library(rtweet)
library(lubridate)
library(glue)
library(jsonify)
library(jsonlite)

accounts <- sprintf("@%s",
                    c("nasa",
                      "cnn",
                      "natgeo",
                      "washingtonpost",
                      "wired",
                      "lemondefr",
                      "wsj"))


tweets <- map(accounts, function(x) {
  cat(glue("{x}"), "\n")
  get_timeline(user = x, n = 3250, retryonratelimit = TRUE, parse = FALSE,
               include_ext_alt_text = "true")
})

cleaned <- map2_df(tweets, accounts, function(x, y) {
  cat(glue("{y}"), "\n")
  acc <- y
  tmp <- x[[1]]
  map_df(tmp, function(z) {
    tmp1 <- z$extended_entities$media
    created_at <- z$created_at
    map2_df(tmp1, created_at, function(i, j) {
      if (!is.null(i)) {
        i |> 
          mutate(acc = acc,
                 cre_at = j)
      }
    })
  })
})

format_date <- function(x, format = "%a %b %d %T %z %Y") {
  locale <- Sys.getlocale("LC_TIME")
  on.exit(Sys.setlocale("LC_TIME", locale), add = TRUE)
  Sys.setlocale("LC_TIME", "C") 
  as.POSIXct(x, format = format)
}

only_data <- cleaned |> 
  select(created_at = cre_at,
         acc,
         id_str,
         expanded_url,
         type,
         ext_alt_text) |> 
  mutate(created_at = format_date(created_at))


saveRDS(only_data, "data/more_data.rda")


