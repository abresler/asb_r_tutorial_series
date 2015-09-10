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
      
      draft_year <- # our chosen draft year
        1983
      
      year.first_draft <- # remember from earlier 1st BAA draft
        1947
      
      current_month <- # we're gonna to teach the code to know if the draft has
        Sys.Date() %>%
        month %>%
        as.numeric
      
      if (current_month > 6) {
        year.most_recent_draft <- # the draft is at the end of June so if its July we've passed the draft!
          Sys.Date() %>% # tells us what today is
          year %>% # extracts the year
          as.numeric()
      } else {
        year.most_recent_draft <-
          Sys.Date() %>% 
          year %>% 
          as.numeric() - 1 #if it's earlier than July we take last year's draft
      }
      
      if (!draft_year %in% year.first_draft:year.most_recent_draft) {
        stop.message <-
          "Not a valid draft year boss!!  Drafts can only be between " %>%
          paste0(year.first_draft, ' and ', year.most_recent_draft)
        stop(stop.message)
      }
      
      if (draft_year < 1950) {
        base <- # remember what we learned earlier?
          'http://www.basketball-reference.com/draft/BAA_'
        
        id.league <- 
          'BAA' # based on the date R will know hte league
      } else {
        base <- # well if it's not the BAA it's the NBA, DUHHH
          'http://www.basketball-reference.com/draft/NBA_'
        
        id.league <-
          'NBA'
      }
      
      url.draft_year <-
        base %>%
        paste0(draft_year, '.html') # creates the url where the data lives
      
      url.draft_year # our url with the data and it should work for any draft year!
      
      page <- # Get the html from the page into R
        url.draft_year %>%
        read_html
      
      raw_data <-
        page %>%
        html_nodes('#stats') %>% # Remember this is the css id from earlier
        html_table(header = F, fill = F) %>% # This function reads the table 
        data.frame %>% # Data is not ts not a data.frame this puts it into tht form
        tbl_df # This converts it into a super dope special type of data fram tbl_df
      
      headers <- # Get the parent header rows so we can append them into the column names and sove the duplicate name problem
        raw_data %>% 
        slice(1) %>% # Takes the 1st row where this header info
        unlist %>% # Returns a the row as list we dont want that
        as.character %>% # We want to explicitly define this vector as a character
        tolower %>% # Gonna be part of our title, I perfer lower case titles
        str_replace('\\ ', '_') # Column names SHOULD NOT contain spaces, use the snake!!
      
      # Time to get the actual column items
      
      columns <-
        raw_data %>%
        slice(2) %>% # This information lives in the second row
        tolower %>% 
        str_replace('%', '_pct') %>% # % should also never be a column header this gets rid of them
        str_replace('/', '_per_') # / should ALSO never be a column header, this removes them
      
      name.df <- # This creates a data frame that will contain column names
        data_frame(header = headers, column = columns) %>% # data_frame is a special faster data frame from dplyr that I reccomend you use whever possible
        mutate( # Mutate adds variables to data frames
          header = ifelse(header == '', NA, header), # No headers for blank items, they happen to be identifiers about the draft player versus statistics
          header = ifelse(header %like% 'round|territorial_picks', NA, header) # If we see these words we want to exclude that row
        ) %>%
        FillDown('header') %>% # Fills down the keys 
        mutate(name.column = ifelse(header %>% is.na, column, paste(header, column, sep = '.')) # if the field has a header we want to join the items together if not just keep the item as the name, we know which those are by where the NAs live
        )
      
      names(raw_data) <- # change the names to our new clean names!
        name.df$name.column
      
      ## Use R skills to magically figure out which round the player was taken in
      
      round_rows <- # find out the row number where we get indication of the round
        'Round' %>% # that is the word we need to look for 
        grep(raw_data$player) # we want to return the row numbers in the 4th column where we find that word, the round headers live in this column
      
      round_df <- #create data frame where the rounds start
        data_frame(round = paste0('Round ', 1:length(round_rows)), # the number of times we see the word indicates how many rounds that year had with some slight exceptions
                   id.row = round_rows + 2 # the players names start 2 rows below where we find the word
        )
      
      ## This is for later but trust me from exploring, there were other ways players ended up on teams that weren't considered drafts, there were specific words that Basketball-Reference uses to delinate them and those are the 2 words we looking for
      
      if ('Other|Territorial Picks' %>% grep(raw_data$player) %>% #looking for their existence, if they exist the length of the results won't be zero
          length > 0) {
        other_rows <-
          'Other|Territorial Picks' %>% grep(raw_data$player)
        
        other_rounds.df <-
          data_frame(round = 'Other', #create a special name so we will get an NA for the round when we magically extract the round later
                     id.row = other_rows + 2)
        round_df %<>%
          bind_rows(other_rounds.df)
      }
      
      raw_data %<>%
        mutate(id.row = 1:nrow(.)) %>% # We need to create a temporary id to merge the rows in the draft data frame to this, here we do this
        left_join(round_df, by = 'id.row') %>% # A left join keeps the first table and merges any matching table from the right table, in this case the right table is the round data, frame
        select(round, everything()) %>% # cleans up order
        FillDown('round') %>% # Fills the round by the boundries
        mutate(id.round = round %>% extract_numeric) %>% # We want to extract the numeric round if it exists this does that
        select(id.round, everything()) %>% # cleans up the order again
        select(-c(id.row, round)) # we dont need these columns, using - tells R to remove these columns
      
      ## Last step, remove the rows we don't need
      
      raw_data %<>% ## remove the rows we don't need
        slice(-1) %>% # First row the way we import the data contains the items, remember
        dplyr::filter(!rk == 'Rk', !player %like% 'Round|Other Picks') # In these tables we know how to find "bad" rows by looking for "Rk" in the rk column and the word Round or Other Picks in the player column filters out fields that don't contain data because they contain those 3 words
      
      raw_data %<>%
        select(-rk) %>% # We dont need the rank column its meaningless
        rename( #A little more name cleaning
          id.pick = pk, # better name, helps us remember that the pick is an id which it is
          id.bref.team = tm, # this column corresponds with the basketball reference
          totals.years_played = yrs # Better name, shows us how many years someone played
        ) %>%
        arrange(id.pick) #orders by pick!
      
      numeric_columns <- # Tell R which fields are numeric and then convert them to numeric fields!
        raw_data %>%
        select(-c(id.bref.team, college, player)) %>% # Selects the non numeric fields
        names # Returns the names of the columns that we want to convert
      
      raw_data %<>%
        mutate_each_(funs(as.numeric),  # this is where we tell R what function we want to use on our selected columns, here its as.numeric
                     vars = numeric_columns # These are the columns from earlier
        )
      
    
      ## Player ID Extraction
      player <-
        page %>%
        html_nodes('td:nth-child(4) a') %>% # This is the column where the player IDs live
        html_text %>% # this takes the html output and returns text
        str_trim # To be safe this trims the code in case there are any unceassary white spaces
      
      url.bref.player <- # This creates the player URL
        page %>%
        html_nodes('td:nth-child(4) a') %>%
        html_attr('href') %>% # This function pulls in the html attribute, in this case the stem
        paste0('http://www.basketball-reference.com', .) # We need to append the base URL!
      
      stem.player <- # Here we are going to extract out from the steam the exact player ID
        page %>%
        html_nodes('td:nth-child(4) a') %>%
        html_attr('href') %>%
        str_replace_all('/players/|.html', '') # eliminates the unnecassary words to help us get at the clean ID
      
      players_urls <- # This will create a data frame with the information we want
        data_frame(player, url.bref.player, stem.player) %>%
        separate(stem.player, c('letter.first', 'id.bref.player'), #  Separates the remaining 2 parts by its delimiter the / we only want the second column which contains the id
                 sep = '/') %>%
        select(-letter.first) # removes the unneeded column
      
      ## Resolve the team ids
      
      teams_ids <-
        'http://asbcllc.com/data/nba/bref/nba_teams_ids.csv' %>% 
        read_csv # imports my team data
      
      data <- #create a new data frame which will be our final data frame with all the information
        raw_data %>%
        left_join(players_urls, by = 'player') %>% # joins are existing data with the players who have BREF profiles
        mutate(id.league, # add in the league id from earlier
               year.draft = draft_year, # add in the draft year from earlier, I like to use periods to separate columns, total personal preference
               url.bref.draft = url.draft_year # this tells us the URL where we got our data from
        )
      
      data %<>%
        left_join(teams_ids, by = 'id.bref.team') %>% # Joins our data frame with the team data which will merge in the missing team data
        select( #reorder the data
          id.league, 
          year.draft,
          id.round,
          id.pick:player,
          id.bref.player,
          id.bref.team,
          team,
          id.bref.current_team,
          current_team,
          everything() #select everything else in the data frame
        ) %>%
        arrange(id.pick)
      
      ### Time to Messagify!!
      
      players <-
        data %>% 
        nrow #counts the number of players in that draft
      
      random_player <- # I want our message to return information about a random player from that draft
        data %>%
        arrange(desc(totals.pts)) %>% # arranges the data with the top scorers first
        mutate(rank.total_points = 1:nrow(.)) %>% # adds a ranking field
        dplyr::filter(totals.pts > 0 & totals.years_played > 1) %>% #filters for players who played over 1 season and scored points
        dplyr::filter(!is.na(id.bref.player)) %>% # filters out players who don't have a BREF profile page
        sample_n(1) # returns 1 random row with a player that fits the criteria!
      
      # Print the message
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