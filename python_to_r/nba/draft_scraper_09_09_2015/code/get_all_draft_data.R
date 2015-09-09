packages <- 
  c(
    'devtools', # install.packages(devtools)
    'dplyr', # devtools::install_github('hadley/dplyr') 
    'magrittr', # devtools::install_github('smbache/magrittr')
    'rvest', # devtools::install_github('hadley/rvest')
    'data.table', # install.packages(data.table)
    'lubridate', # devtools::install_github(hadley/lubridate)
    'DataCombine', #devtools::install_github('christophergandrud/DataCombine')
    'stringr', # devtools::install_github('hadley/stringr')
    'readr', # devtools::install_github('hadley/readr')
    'formattable', #devtools::install_github('renkun-ken/formattable')
    'tidyr' # devtools::install_github('hadley/tidyr')
  )

lapply(packages, library, character.only = T)


get_all_nba_draft_data <- function(year_start = NA, year_end = NA,
                                   include_baa = T, return_message = T) {
  get_nba_year_draft_data <-
    function(draft_year = 1983,
             return_message = T) {
      options(warn = -1)
      #Make Smart Draft Years
      
      year.first_draft <-
        1947
      
      current_month <-
        Sys.Date() %>%
        month %>%
        as.numeric
      
      if (current_month > 6) {
        year.most_recent_draft <-
          Sys.Date() %>%
          year %>%
          as.numeric()
      } else {
        year.most_recent_draft <-
          Sys.Date() %>%
          year %>%
          as.numeric() - 1
      }
      
      if (!draft_year %in% year.first_draft:year.most_recent_draft) {
        stop.message <-
          "Not a valid draft year boss!!  Drafts can only be between " %>%
          paste0(year.first_draft, ' and ', year.most_recent_draft)
        stop(stop.message)
      }
      
      if (draft_year < 1950) {
        base <-
          'http://www.basketball-reference.com/draft/BAA_'
        
        id.league <-
          'BAA'
      } else {
        base <-
          'http://www.basketball-reference.com/draft/NBA_'
        
        id.league <-
          'NBA'
      }
      
      url.draft_year <-
        base %>%
        paste0(draft_year, '.html')
      
      page <- #get the html from the page into R
        url.draft_year %>%
        read_html
      
      raw_data <-
        page %>%
        html_nodes('#stats') %>% #remember this is the #node from earlier where the table lies
        html_table(header = F, fill = F) %>% #this function reads the table 
        data.frame %>% #its not a data.frame I need to turn it into one
        tbl_df # I am going to convert it into a special type of data.frame using tbl_df
      
      headers <- #Get the parent header rows so we can append them into the column names
        raw_data %>% 
        slice(1) %>% #if you look at the data they are in the 1st row
        unlist %>% #returns a list we dont want that
        as.character %>% #be safe and turn them into character vectors
        tolower %>% #lower case is my preference
        str_replace('\\ ', '_') # column names SHOULD NOT contain spaces, use the snake!!
      
      #Time to get the column items
      
      columns <-
        raw_data %>%
        slice(2) %>% #it's in the second row
        tolower %>% #remember from #earlier
        str_replace('%', '_pct') %>% # % should also never be a column header
        str_replace('/', '_per_') # / should ALSO never be a column #header
      
      name.df <- #lets create a dataframe to replace make our names
        data_frame(header = headers, column = columns) %>%
        mutate(
          header = ifelse(header == '', NA, header), #no headers for blank items
          header = ifelse(header %like% 'round|territorial_picks', NA, header) #also don't want to see these
        ) %>%
        FillDown('header') %>% #fills down until the next round
        mutate(name.column = ifelse(header %>% is.na, column, paste(header, column, sep = '.')))
      
      names(raw_data) <- #change the names to our new clean names!
        name.df$name.column
      
      ## Magically figure out which round the player was taken in
      
      round_rows <- #find out the row number where we get indication of the round
        'Round' %>% #that is the word we need to look for 
        grep(raw_data$player) # we want to return the row numbers in the 4th column where we find that word
      
      round_df <- #create data frame where the rounds start
        data_frame(round = paste0('Round ', 1:length(round_rows)), #the number of times we see the word indicates how many rounds that year had
                   id.row = round_rows + 2 #the players names start 2 rows below where we find the word
        )
      ## This is for later but trust me, back in the day they had other ways to get players and we need to prepare ourselves for this when if we choose a year where this is a problem!
      
      if ('Other|Territorial Picks' %>% grep(raw_data$player) %>% length > 0) {
        other_rows <-
          'Other|Territorial Picks' %>% grep(raw_data$player)
        
        other_rounds.df <-
          data_frame(round = 'Other',
                     id.row = other_rows + 2)
        round_df %<>%
          bind_rows(other_rounds.df)
      }
      
      raw_data %<>%
        mutate(id.row = 1:nrow(.)) %>% #need to create a temporary id to merge the rows in
        left_join(round_df, by = 'id.row') %>% #this joins the data by the new id
        select(round, everything()) %>% #cleans up order
        FillDown('round') %>% #fills the round
        mutate(id.round = round %>% extract_numeric) %>% #want to extract the numeric round if it exists
        select(id.round, everything()) %>% #cleans up the order again
        select(-c(id.row, round)) #we dont need these columns
      
      raw_data %<>% ## remove the rows we don't need
        slice(-1) %>% #first row we never need
        dplyr::filter(!rk == 'Rk', !player %like% 'Round|Other Picks') #filters out fields that don't contain data because they contain those 3 words
      
      raw_data %<>%
        select(-rk) %>% #we dont need rk it's a meaning loss row
        rename(
          id.pick = pk, #better name
          id.bref.team = tm, #better name
          totals.years_played = yrs #better name
        ) %>%
        mutate(id.pick = id.pick %>% as.numeric) %>% #turn this field into a numeric one
        arrange(id.pick) #orders by pick!
      
      numeric_columns <- #tell R which fields are numeric
        raw_data %>%
        select(-c(id.bref.team, college, player)) %>% #these will be our non numeric fields
        names #takes the name
      
      raw_data %<>%
        mutate_each_(funs(as.numeric), 
                     vars = numeric_columns #takes our selected fields and converts them to #s
        )
      ## Let's Build a check comparing the data we have with what BREF says
      
      bref_picks <- 
        page %>% 
        html_nodes('h2') %>% #takes the header showing us how many draft players there were
        html_text %>% 
        extract_numeric()
      
      ## Player ID Extraction
      player <-
        page %>%
        html_nodes('td:nth-child(4) a') %>%
        html_text
      
      url.bref.player <-
        page %>%
        html_nodes('td:nth-child(4) a') %>%
        html_attr('href') %>%
        paste0('http://www.basketball-reference.com', .)
      
      stem.player <-
        page %>%
        html_nodes('td:nth-child(4) a') %>%
        html_attr('href') %>%
        str_replace_all('/players/|.html', '')
      
      players_urls <-
        data_frame(player, url.bref.player, stem.player) %>%
        separate(stem.player, c('letter.first', 'id.bref.player'),
                 sep = '/') %>%
        select(-letter.first)
      
      ## resolve with team
      teams_ids <-
        'http://asbcllc.com/data/nba/bref/nba_teams_ids.csv' %>%
        read_csv
      
      data <-
        raw_data %>%
        left_join(players_urls, by = 'player') %>%
        mutate(id.league,
               year.draft = draft_year,
               url.bref.draft = url.draft_year)
      
      data %<>%
        left_join(teams_ids, by = 'id.bref.team') %>%
        select(
          id.league,
          year.draft,
          id.round,
          id.pick:player,
          id.bref.player,
          id.bref.team,
          team,
          id.bref.current_team,
          current_team,
          everything()
        ) %>%
        arrange(id.pick)
      
      if (return_message == T) {
        players <-
          data %>% nrow
        
        random_player <-
          data %>%
          dplyr::filter(totals.pts > 0 & totals.years_played > 1) %>%
          arrange(desc(totals.pts)) %>%
          mutate(rank.total_points = 1:nrow(.)) %>%
          dplyr::filter(!is.na(id.bref.player)) %>%
          sample_n(1)
        
        "Congratulations you pulled in data for all " %>%
          paste0(
            players,
            ' players from the ',
            draft_year,
            ' Draft\nHave you heard of the #',
            random_player$id.pick,
            ' pick, ',
            random_player$player,
            '?\nHe played ',
            random_player$totals.years_played,
            ' seasons & ranked #',
            random_player$rank.total_points,
            ' in his draft class for total points scored!'
          ) %>%
          message
      }
      return(data)
    }
  
  
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