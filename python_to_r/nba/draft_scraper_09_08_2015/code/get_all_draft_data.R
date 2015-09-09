

get_all_nba_draft_data <- function(year_start = NA, year_end = NA,
                                   include_baa = T, return_message = T) {
  source('python_to_r/nba/draft_scraper_09_08_2015/code/get_draft_year_data.R')
  
  if (include_baa == T) {
    year.first_draft <-
      1947
  } else{
    year.first_draft <- 
      1950
  }
  
  if (year_start %>% is.na) {
    year_start <-
      year.first_draft
  }
  
  current_month <-
    Sys.Date() %>%
    month %>%
    as.numeric
  
  if (current_month > 6) {
    year.most_recent_draft <-
      Sys.Date() %>%
      year %>%
      as.numeric()
  } else{
    year.most_recent_draft <-
      Sys.Date() %>%
      year %>%
      as.numeric() - 1
  }
  
  if (year_end %>% is.na) {
    year_end <- 
      year.most_recent_draft
  }
  
  draft_years <- 
    year_start:year_end
  
  all_data <- 
    data_frame()
  
  for (year in draft_years){
    data <- 
      get_nba_year_draft_data(draft_year = year, return_message = F)
    
    all_data %<>%
      bind_rows(data)
  }
  
  if (return_message == T) {
    players <-
      all_data %>% nrow
    
    random_player <-
      all_data %>%
      dplyr::filter(totals.pts > 0) %>%
      arrange(desc(totals.pts)) %>%
      mutate(rank.total_points = 1:nrow(.)) %>%
      dplyr::filter(!is.na(id.bref.player)) %>%
      slice(1:1000) %>% 
      sample_n(1)
    
    "Congratulations you pulled in data for " %>%
      paste0(
        players,
        ' players from the ',
        year_start,
        ' to ',
        year_end,
        ' drafts\nHave you heard of the #',
        random_player$id.pick,
        ' pick in the ',
        random_player$year.draft,
        ' Draft, ',
        random_player$player,
        '?\nHe played ',
        random_player$totals.years_played,
        ' seasons & ranks #',
        random_player$rank.total_points,
        ' all time in total points scored during your selected draft eras!'
      ) %>%
      message
  }
  return(all_data)
}