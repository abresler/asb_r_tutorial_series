source('python_to_r/nba/draft_scraper_09_08_2015/code/get_all_draft_data.R')
source('python_to_r/nba/draft_scraper_09_08_2015/code/get_draft_year_data.R')

test1970 <- get_nba_year_draft_data(draft_year = 1970)
test1984 <- get_nba_year_draft_data(draft_year = 1984)
test1999 <- get_nba_year_draft_data(draft_year = 1999)
test2005 <- get_nba_year_draft_data(draft_year = 2005)
test2012 <- get_nba_year_draft_data(draft_year = 2012)
all <- get_all_nba_draft_data()

all_data <- 
  get_all_nba_draft_data(return_message = T)
