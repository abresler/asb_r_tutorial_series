# R You Down with NBA Draft Scrapers?
<a href="https://twitter.com/abresler" target="_blank">Alex Bresler</a>  
September 8, 2015  



<div class="ui basic inverted segment"><h2 class="ui green header">What's the Dealio?</h2></div>

<div class="ui basic segment"><p>This is the first of what I hope will be on an ongoing series with the excellent hoops heads over at <a href='http://nyloncalculus.com' target='_blank'>Nylon Calculus</a> that explore learning Data Science through the beautiful lense of NBA Basketball.  This tutorial will teach you how to recreate <a href='https://twitter.com/Savvas_tj' target='_blank'>Savvas Tjortjoglou's</a> fantastic piece on using <a href='http://python.org/' target='_blank'>Python</a> to <a href='http://nyloncalculus.com/2015/09/07/nylon-calculus-101-data-scraping-with-python//' target='_blank'>extract NBA historic draft data</a>.  If you have yet to read the piece I highly recommend you do so before working through this tutorial.</p></div>

<div class="ui basic ui inverted red segment"><h2 class="ui header">Word of Caution</h2></div>

<div class="ui basic segment"><p>This and any future tutorials are not intended taken as:</p>
<li>An endorsement of R as the best programming language.</li>
<li>A characterization of Python as a bad language.</li>
<br>
As I detailed in my <a href='http://asbcllc.com/presentations/si_hackathon/#/' target='_blank'>Sports Illustrated Hackathon keynote presentation</a>, it doesn't matter which programming language you pick so long as you master it to empower yourself with MacGuyver like powers.  Any of the major programming languages {R, Python, JavaScript, C, ect..} with some work will let you do the truly amazing things programming languages can do!

That said, this and future tutorials **are** intended to destroy some misconceptions about the language that I love, <a href='https://en.wikipedia.org/wiki/R_(programming_language)' target='_blank'>R</a>.  There are myths you may come across that imply R is inferior to Python for webscraping, that it's syntax doesn't make sense and that the language is too hard to learn.  None of these things are true and I hope by the end of this post, whatever existing programming language of choice is, learned or intended to be learned, you won't disagree with this statement.
</div>

<div class="ui inverted basic segment"><h2 class="ui yellow header">Enough of the Boring Stuff, Let's Gokul</h2></div>

<img class = "ui centered large image" src="http://static2.businessinsider.com/image/51a7a46369bedd4e01000009/gokel.gif" title = "My Boy Gokul">

<div class="ui basic segment">
<p>In order to get started we need to make sure you have got all the necessary tools for today's exploration. First make sure you have <a href="http://cran.r-project.org/" target='_blank'>R</a> and <a href="http://www.rstudio.com/products/rstudio/" target='_blank'>RStudio</a> installed.  Then if you don't already use <a href="https://www.mozilla.org/en-US/firefox/new/" target='_blank'>Firefox</a> or <a href="http://www.google.com/chrome/" target='_blank'>Chrome</a> pick a browser horse and install it.  Finally, launch your chosen browse and install the <em>fantastic</em> <a href="http://selectorgadget.com/" target='_blank'>SelectorGadget</a> widget. Fire up <img src="http://www.rstudio.com/wp-content/uploads/2014/06/RStudio-Ball.png" alt="" height = "30px" width = "30px">, because it's game time.
</p>
<p>
The next thing you need to do is to make sure you have necessary packages installed.  I am using the development versions of many of these packages and I have referenced the github repos in the comments for those who need  to install them just copy and paste starting at <code>devtools::</code> until the end the line.  For the non development packages just copy and paste starting from <code>install.packages</code>.
</p>
</div>


```r
packages <- #These are the packages we need
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
```
<div class="ui inverted basic yellow segment"><h2 class="ui header">Time to Go Data Treasure Hunting</h2></div>
<img class = "ui centered large image" src="http://i.usatoday.net/sports/_photos/2012/07/28/Post-race-bling-almost-costs-Lochte-medal-E21UVME9-x-large.jpg" title = "Hunting for Gold">

<div class="ui basic segment">
<p>In order to mine NBA draft data gold we need to know a few things before building our data mining rig the most important of which being what years the draft has existed.</p>
<p>To do this we navigate here <code><a href = 'http://www.basketball-reference.com/draft/' target="_blank">http://www.basketball-reference.com/draft/</a></code>.  It looks like the draft has existed since <strong>1947</strong> if you include the NBA's precursor the <a href = 'https://en.wikipedia.org/wiki/Basketball_Association_of_America' target="_blank">BAA</a> and <strong>1950</strong> if you don't.  
</p>
<p>We are nearly ready to start building we just need to pick a draft year to test.  Given that it was the year this author was born let's go with <strong>1983</strong>.  Let's navigate over the <code><a href = 'http://www.basketball-reference.com/draft/NBA_1983.html'  target="_blank">1983 Draft</a></code> page.  We need one more key input before we can get started and that is the <a href = 'https://en.wikipedia.org/wiki/CSS' target = '_blank' >CSS</a> id of the data we want from the page, in this case the draft table.</p>
<p>Remember that SelectorGadget I mentioned earlier?  It's time to use it to get the information we need.  Click the widget's button.  Next scroll over the table with the draft information.  You should see something like the picture below</p>
<img class = "ui centered huge image" src="http://i.imgur.com/rdA0pMn.png" title = "css information">
<br>
<p>Like the <a href = 'www.youtube.com/watch?v=Z5-rdr0qhWk' target = '_blank' >1978 Cars song</a> our trusty SelectorGadget gave us <i>Just What We Needed</i> now it's time to build!</p>
</div>

<div class="ui inverted circular segment">
<h2 class="ui inverted header">
Step 1
</h2>
</div>
<div class="ui inverted red circular segment">
<h2 class="ui inverted header">
Make Our Code Smart
</h2>
</div>
<div class="ui inverted green circular segment">
<h2 class="ui inverted header">
Extract the Data
</h2>
</div>
<div class="ui inverted blue circular segment">
<h2 class="ui inverted header">
Clean the Data
</h2>
</div>

<div class="ui basic segment">
<p>First thing we need to do use code to take the data from the website and help us bring it into a <code><a href = 'http://www.r-tutor.com/r-introduction/data-frame' target = '_blank'>data frame</a></code>.  We are going to use the excellent <code><a>rvest</a></code> package to begin the data extraction process.  Essentially our code is going to take a URL, capture the page, find the draft table and bring the data into R for data cleaning.  Before we do that I want to make our self adjusting and aware of the constraints of the data we are looking for.
</p>
<p> R, like any programming language is really smart so we want to take advantage of this to help us scale this function and allow it to auto update over time.  To do that we will teach our function to allow us to only search for draft years that exist and know if we are looking at a BAA or NBA draft year.  If we pick an illegible draft year R will tell us and stop what it's doing.</p>
<p>Also one important aside, you are going to see me use alot of the symbol <code>%>%</code> , it is a chaining tool, think of it like the term <strong>then</strong>.  I'm a huge fan of chaining it makes things flow much smoother from start to finish.</p>
<p>Also try to following along with my comments by looking for <code>#</code></p>
</div>


```r
draft_year <- #my pick
  1983

year.first_draft <- #remember from earlier
  1947
  
current_month <- #we're gonna to teach the code to know if the draft has
  Sys.Date() %>%
  month %>%
  as.numeric
  
if (current_month > 6) {
  year.most_recent_draft <- #the draft is the end of June so if its July we've passed the draft!
    Sys.Date() %>% #tells us what today is
    year %>% #extacts the year
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
  base <- #remember what we learned earlier?
    'http://www.basketball-reference.com/draft/BAA_'
  
  id.league <-
    'BAA'
} else {
  base <- #well if it's not the BAA it's the NBA, DUHHH
    'http://www.basketball-reference.com/draft/NBA_'
  
  id.league <-
    'NBA'
}

url.draft_year <-
  base %>%
  paste0(draft_year, '.html')

url.draft_year #our url with the data and it should work for any draft year!
```

```
## [1] "http://www.basketball-reference.com/draft/NBA_1983.html"
```

<div class="ui basic segment">
<p>Fantastic we got the all important URL where our data lives.   Now onto the data extraction</p>
<p>I am going to do some advanced data cleaning processes and I am also going to use R's magic to place the correct round into the data frame, something that is not done on Basketball-Reference.</p>
</div>



```r
page <- #get the html from the page into R
  url.draft_year %>%
  read_html

raw_data <-
  page %>%
  html_nodes('#stats') %>% #remember this is the #node from earlier where the table lies
  html_table(header = F, fill = F) %>% #this function reads the table 
  data.frame %>% #its not a data.frame I need to turn it into one
  tbl_df #I am going to convert it into a special type of data.frame using tbl_df

headers <- #Get the parent header rows so we can append them into the column names
  raw_data %>% 
  slice(1) %>% #if you look at the data they are in the 1st row
  unlist %>% #returns a list we dont want that
  as.character %>% #be safe and turn them into character vectors
  tolower %>% #lower case is my preference
  str_replace('\\ ', '_') #column names SHOULD NOT contain spaces, use the snake!!

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
raw_data %>% 
  glimpse #explore the data!
```

```
## Observations: 226
## Variables: 22
## $ id.round            (dbl) 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...
## $ id.pick             (dbl) 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,...
## $ id.bref.team        (chr) "HOU", "IND", "HOU", "SDC", "CHI", "GSW", ...
## $ player              (chr) "Ralph Sampson", "Steve Stipanovich", "Rod...
## $ college             (chr) "University of Virginia", "University of M...
## $ totals.years_played (dbl) 9, 5, 10, 14, 10, 1, 12, 16, 17, 13, 16, 1...
## $ totals.g            (dbl) 456, 403, 768, 1073, 679, 45, 928, 987, 12...
## $ totals.mp           (dbl) 13591, 12591, 24876, 30152, 13247, 354, 24...
## $ totals.pts          (dbl) 7039, 5323, 9014, 15097, 5080, 166, 11834,...
## $ totals.trb          (dbl) 4011, 3131, 5087, 2987, 4128, 82, 4718, 33...
## $ totals.ast          (dbl) 1038, 938, 2750, 2729, 635, 22, 1298, 1086...
## $ shooting.fg_pct     (dbl) 0.486, 0.484, 0.503, 0.482, 0.454, 0.571, ...
## $ shooting.3p_pct     (dbl) 0.172, 0.179, 0.260, 0.370, 0.037, NA, 0.1...
## $ shooting.ft_pct     (dbl) 0.661, 0.796, 0.761, 0.833, 0.738, 0.418, ...
## $ per_game.mp         (dbl) 29.8, 31.2, 32.4, 28.1, 19.5, 7.9, 26.8, 2...
## $ per_game.pts        (dbl) 15.4, 13.2, 11.7, 14.1, 7.5, 3.7, 12.8, 9....
## $ per_game.trb        (dbl) 8.8, 7.8, 6.6, 2.8, 6.1, 1.8, 5.1, 3.4, 3....
## $ per_game.ast        (dbl) 2.3, 2.3, 3.6, 2.5, 0.9, 0.5, 1.4, 1.1, 1....
## $ advanced.ws         (dbl) 20.1, 30.4, 56.0, 75.2, 17.4, 0.8, 45.0, 4...
## $ advanced.ws_per_48  (dbl) 0.071, 0.116, 0.108, 0.120, 0.063, 0.106, ...
## $ advanced.bpm        (dbl) 0.0, 1.1, 1.6, 0.4, -2.7, -1.8, -1.3, -0.6...
## $ advanced.vorp       (dbl) 6.8, 9.9, 23.0, 18.6, -2.5, 0.0, 4.2, 7.0,...
```

<div class="ui basic segment">
<p>Booyah, just like that we have the data from the table for the 1983 draft.</p>
<img class = "ui centered large image" src="https://s-media-cache-ak0.pinimg.com/originals/fa/0b/cf/fa0bcf6038813071226f70396fb8115a.gif" title = "Booyah">
</div>

<div class="ui inverted circular segment">
<h2 class="ui inverted header">
Step 2
</h2>
</div>
<div class="ui inverted red circular segment">
<h2 class="ui inverted header">
Import Missing Page Data
</h2>
</div>
<div class="ui inverted green circular segment">
<h2 class="ui inverted header">
Resolve Data
</h2>
</div>
<div class="ui inverted blue circular segment">
<h2 class="ui inverted header">
Add Fun Message
</h2>
</div>

<div class="ui basic segment">
<p>Believe it or not we are almost done.  All that is left to do is import the other important data from the page we captured that being the player's BREF ID, if it exists, and the players BREF profile URL.  I have also done the less than fun grunt working of creating a separate file that contains all the BREF team IDs, the team's name, it's current team ID and team name.</p>
<p>After collecting and importing that data we will merge it do the raw data and we will be done.  I also like to add fun messages to my code, especially when functions are built around it, that's coming next folks.  Messages show you that your code is done running and can be tailored to, make you laugh, feel good about your work, or as in this case, learn a new fact.</p>
</div>


```r
player <-
  page %>%
  html_nodes('td:nth-child(4) a') %>% #get the player names to resolve against our data table
  html_text

url.bref.player <-
  page %>%
  html_nodes('td:nth-child(4) a') %>%
  html_attr('href') %>% # pull in the player's page stem if they exist
  paste0('http://www.basketball-reference.com', .) #add in the base url

stem.player <-
  page %>%
  html_nodes('td:nth-child(4) a') %>%
  html_attr('href') %>%
  str_replace_all('/players/|.html', '') #parse the stem to help us extract the player ID

players_urls <-
  data_frame(player, url.bref.player, stem.player) %>%
  separate(stem.player, c('letter.first', 'id.bref.player'), #separate out the letter to get the raw stem
           sep = '/') %>%
  select(-letter.first) #remove the first letter

## resolve with teams

teams_ids <-
    'http://asbcllc.com/data/nba/bref/nba_teams_ids.csv' %>% #import my team id data
    read_csv

data <-
  raw_data %>%
  left_join(players_urls, by = 'player') %>% #join the raw data with the urls and stems
  mutate(id.league, #add in the league id
         year.draft = draft_year, #add in the draft year
         url.bref.draft = url.draft_year)

data %<>%
  left_join(teams_ids, by = 'id.bref.team') %>% #join against the team names
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

### Let's craft our message that tells us a random fact a player wh

players <-
  data %>% 
  nrow #counts the number of players in that draft

random_player <-
  data %>%
  mutate(rank.total_points = 1:nrow(.)) %>% #adds a ranking field
  dplyr::filter(totals.pts > 0 & totals.years_played > 1) %>% #filters for players who played over 1 season and scored points
  arrange(desc(totals.pts)) %>% #sorts the data descending by 
  dplyr::filter(!is.na(id.bref.player)) %>% #filters for players 
  sample_n(1) #takes a random sample of the players that meet the criteria

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
```

```
## Congratulations you pulled in data for all 226 players from the 1983 Draft
## Have you heard of the #139 pick, Sedale Threatt?
## He played 14 seasons & ranked #139 in his draft class for total points scored!
```

<div class="ui basic segment">
<p>Let's take a quick look at a snapshot of the data</p>
</div>


```r
data %>% 
  select(id.round, id.pick, player, team, totals.years_played, totals.pts) %>%
  mutate(totals.pts = totals.pts %>% comma(digits = 0)) %>% #some formating
  head %>% 
  format_table(align = 'c')
```



| id.round | id.pick |      player       |         team          | totals.years_played | totals.pts |
|:--------:|:-------:|:-----------------:|:---------------------:|:-------------------:|:----------:|
|    1     |    1    |   Ralph Sampson   |    Houston Rockets    |          9          |   7,039    |
|    1     |    2    | Steve Stipanovich |    Indiana Pacers     |          5          |   5,323    |
|    1     |    3    |   Rodney McCray   |    Houston Rockets    |         10          |   9,014    |
|    1     |    4    |    Byron Scott    |  San Diego Clippers   |         14          |   15,097   |
|    1     |    5    |   Sidney Green    |     Chicago Bulls     |         10          |   5,080    |
|    1     |    6    |   Russell Cross   | Golden State Warriors |          1          |    166     |

<div class="ui basic segment">
<img class = "ui centered medium image" src='http://i.imgur.com/Cp62j1q.gif'>
</div>

<div class="ui basic ui inverted blue segment"><h2 class="ui header">Let's Get Function-al</h2></div>
<div class="ui basic segment">
<p class = 'ui center aligned'>Now that we know our code works let's build a function that takes a draft year and returns a data frame with the cleaned and resolve data.  We want to the function to inherit the smarts we looked at earlier and we will add an option as to whether our special message will be returned upon execution of the function. </p>
</div>


```r
get_nba_year_draft_data <-
  function(draft_year = 1984,
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
    
    page <- 
      url.draft_year %>%
      read_html
    
    raw_data <-
      page %>%
      html_nodes('#stats') %>% 
      html_table(header = F, fill = F) %>%
      data.frame %>% 
      tbl_df
    
    headers <- 
      raw_data %>% 
      slice(1) %>% 
      unlist %>% 
      as.character %>%
      tolower %>%
      str_replace('\\ ', '_') 
    
    #Time to get the column items
    
    columns <-
      raw_data %>%
      slice(2) %>%
      tolower %>% 
      str_replace('%', '_pct') %>%
      str_replace('/', '_per_') 
    
    name.df <-
      data_frame(header = headers, column = columns) %>%
      mutate(
        header = ifelse(header == '', NA, header), 
        header = ifelse(header %like% 'round|territorial_picks', NA, header)
      ) %>%
      FillDown('header') %>% 
      mutate(name.column = ifelse(header %>% is.na, column, paste(header, column, sep = '.')))
    
    names(raw_data) <-
      name.df$name.column
    
    ## Magically figure out which round the player was taken in
    
    round_rows <-
      'Round' %>% 
      grep(raw_data$player)
    
    round_df <-
      data_frame(round = paste0('Round ', 1:length(round_rows)),
                 id.row = round_rows + 2
      )
    
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
      mutate(id.row = 1:nrow(.)) %>% 
      left_join(round_df, by = 'id.row') %>%
      select(round, everything()) %>%
      FillDown('round') %>%
      mutate(id.round = round %>% extract_numeric) %>% 
      select(id.round, everything()) %>%
      select(-c(id.row, round)) 
    
    raw_data %<>%
      slice(-1) %>%
      dplyr::filter(!rk == 'Rk', !player %like% 'Round|Other Picks')
    
    raw_data %<>%
      select(-rk) %>% 
      rename(
        id.pick = pk, 
        id.bref.team = tm, 
        totals.years_played = yrs #better name
      ) %>%
      mutate(id.pick = id.pick %>% as.numeric) %>%
      arrange(id.pick)
    
    numeric_columns <-
      raw_data %>%
      select(-c(id.bref.team, college, player)) %>%
      names
    
    raw_data %<>%
      mutate_each_(funs(as.numeric), 
                   vars = numeric_columns
      )
    
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
```

<div class="ui inverted red segment">
<p>Ok let's take her for a whirl and examine the 2013 draft.</p>
</div>


```r
data <- 
  get_nba_year_draft_data(draft_year = 2013,return_message = T)
```

```
## Congratulations you pulled in data for all 60 players from the 2013 Draft
## Have you heard of the #11 pick, Michael Carter-Williams?
## He played 2 seasons & ranked #2 in his draft class for total points scored!
```
<div class="ui basic segment">
<p class = 'ui center aligned'>Let's examine some of the results.</p>
</div>

```r
data %>% 
  select(id.round, id.pick, player, team, totals.years_played, totals.pts, per_game.pts, per_game.trb, per_game.ast, advanced.ws) %>%
  mutate(totals.pts = totals.pts %>% comma(digits = 0)) %>% #some formating
  head(15) %>% #lets do the top 15 picks
  format_table(align = 'c')
```



| id.round | id.pick |          player          |          team          | totals.years_played | totals.pts | per_game.pts | per_game.trb | per_game.ast | advanced.ws |
|:--------:|:-------:|:------------------------:|:----------------------:|:-------------------:|:----------:|:------------:|:------------:|:------------:|:-----------:|
|    1     |    1    |     Anthony Bennett      |  Cleveland Cavailers   |          2          |    515     |     4.7      |     3.4      |     0.6      |    -0.1     |
|    1     |    2    |      Victor Oladipo      |     Orlando Magic      |          2          |   2,398    |     15.8     |     4.2      |     4.1      |     4.8     |
|    1     |    3    |       Otto Porter        |   Washington Wizards   |          2          |    523     |     4.7      |     2.5      |     0.7      |     2.7     |
|    1     |    4    |       Cody Zeller        |   Charlotte Hornets    |          2          |    962     |     6.7      |     5.0      |     1.3      |     6.5     |
|    1     |    5    |         Alex Len         |      Phoenix Suns      |          2          |    518     |     4.7      |     5.0      |     0.3      |     3.6     |
|    1     |    6    |       Nerlens Noel       |  New Orleans Hornets   |          1          |    744     |     9.9      |     8.1      |     1.7      |     4.0     |
|    1     |    7    |       Ben McLemore       |    Sacramento Kings    |          2          |   1,716    |     10.5     |     2.9      |     1.4      |     3.3     |
|    1     |    8    | Kentavious Caldwell-Pope |    Detroit Pistons     |          2          |   1,513    |     9.3      |     2.5      |     1.0      |     4.6     |
|    1     |    9    |        Trey Burke        | Minnesota Timberwolves |          2          |   1,868    |     12.8     |     2.8      |     5.0      |     3.3     |
|    1     |   10    |      C.J. McCollum       | Portland Trailblazers  |          2          |    625     |     6.3      |     1.4      |     0.9      |     2.0     |
|    1     |   11    | Michael Carter-Williams  |   Philadelphia 76ers   |          2          |   2,133    |     15.7     |     5.8      |     6.5      |     2.1     |
|    1     |   12    |       Steven Adams       | Oklahoma City Thunder  |          2          |    802     |     5.3      |     5.7      |     0.7      |     7.0     |
|    1     |   13    |       Kelly Olynyk       |    Dallas Mavericks    |          2          |   1,263    |     9.4      |     5.0      |     1.6      |     6.5     |
|    1     |   14    |     Shabazz Muhammad     |       Utah Jazz        |          2          |    655     |     8.7      |     2.8      |     0.7      |     2.3     |
|    1     |   15    |  Giannis Antetokounmpo   |    Milwaukee Bucks     |          2          |   1,555    |     9.8      |     5.6      |     2.3      |     7.4     |
<div class="ui basic segment">
<div class="ui black segment">Oh Anthony Bennett.....</p></div>
<img class = "ui centered large image" src="https://usatthebiglead.files.wordpress.com/2014/01/anthony-bennett-jumps-when-touched-with-powerade-against-knicks.gif" title = "Anthony Bennett">
</div>

<div class="ui inverted circular segment">
<h2 class="ui inverted header">
Part II
</h2>
</div>
<div class="ui inverted grey circular segment">
<h2 class="ui inverted header">
Scale Up the Function
</h2>
</div>

<div class="ui basic segment">
<p class = 'ui center aligned'>Now that we have a working function that pulls in the data for any draft year we give it we can use that function to create one that either automatically pulls in every draft since NBA or BAA inception or pulls in the draft years that you give it.</p>
<p>Let's build and test that function, it's what we set out to today and won't be much more work!</p>
</div>


```r
get_all_nba_draft_data <- function(year_start = NA, year_end = NA,
                                   include_baa = T, return_message = T) {
  
  if (include_baa == T) {
    year.first_draft <-
      1947 #first BAA year
  } else{
    year.first_draft <- 
      1950 #first NBA year
  }
  
  if (year_start %>% is.na) {
    year_start <-
      year.first_draft #if we specify when to start it overwrites startdate
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
      as.numeric() - 1 #same from before
  }
  
  if (year_end %>% is.na) {
    year_end <- 
      year.most_recent_draft #If we don't select an end draft year overwrite with the most recent
  }
  
  draft_years <- 
    year_start:year_end #create a numeric vector of the draft years we want
  
  all_data <- 
    data_frame() #form an empty data_frame
  
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
      dplyr::filter(totals.pts > 0) %>% #people who have scored
      arrange(desc(totals.pts)) %>% #sort by points
      mutate(rank.total_points = 1:nrow(.)) %>%
      dplyr::filter(!is.na(id.bref.player)) %>%
      slice(1:1000) %>%  #take the top 1000s players by points
      sample_n(1) #take a sample of 1
    
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
```


```r
all_data <- 
  get_all_nba_draft_data()
```

```
## Congratulations you pulled in data for 7789 players from the 1947 to 2015 drafts
## Have you heard of the #11 pick in the 2011 Draft, Klay Thompson?
## He played 4 seasons & ranks #719 all time in total points scored during your selected draft eras!
```

```r
all_data %>% 
  select(year.draft, id.round, id.pick, player, team, totals.years_played, totals.pts, per_game.pts, per_game.trb, per_game.ast, advanced.ws) %>%
  arrange(desc(totals.pts)) %>% 
  mutate(totals.pts = totals.pts %>% comma(digits = 0)) %>% #some formating
  head(15) %>% #lets do the top 15 picks
  format_table(align = 'c')
```



| year.draft | id.round | id.pick |       player        |          team          | totals.years_played | totals.pts | per_game.pts | per_game.trb | per_game.ast | advanced.ws |
|:----------:|:--------:|:-------:|:-------------------:|:----------------------:|:-------------------:|:----------:|:------------:|:------------:|:------------:|:-----------:|
|    1969    |    1     |    1    | Kareem Abdul-Jabbar |    Milwaukee Bucks     |         20          |   38,387   |     24.6     |     11.2     |     3.6      |    273.4    |
|    1985    |    1     |   13    |     Karl Malone     |       Utah Jazz        |         19          |   36,928   |     25.0     |     10.1     |     3.6      |    234.6    |
|    1996    |    1     |   13    |     Kobe Bryant     |   Charlotte Hornets    |         19          |   32,482   |     25.4     |     5.3      |     4.8      |    173.1    |
|    1984    |    1     |    3    |   Michael Jordan    |     Chicago Bulls      |         15          |   32,292   |     30.1     |     6.2      |     5.3      |    214.0    |
|    1959    |    NA    |   NA    |  Wilt Chamberlain   | Philadelphia Warriors  |         14          |   31,419   |     30.1     |     22.9     |     4.4      |    247.3    |
|    1992    |    1     |    1    |  Shaquille O'Neal   |     Orlando Magic      |         19          |   28,596   |     23.7     |     10.9     |     2.5      |    181.7    |
|    1998    |    1     |    9    |    Dirk Nowitzki    |    Milwaukee Bucks     |         17          |   28,119   |     22.2     |     7.9      |     2.6      |    192.0    |
|    1968    |    1     |    1    |     Elvin Hayes     |   San Diego Rockets    |         16          |   27,313   |     21.0     |     12.5     |     1.8      |    120.8    |
|    1984    |    1     |    1    |   Hakeem Olajuwon   |    Houston Rockets     |         18          |   26,946   |     21.8     |     11.1     |     2.5      |    162.8    |
|    1960    |    1     |    1    |   Oscar Robertson   |   Cincinnati Royals    |         14          |   26,710   |     25.7     |     7.5      |     9.5      |    189.2    |
|    1982    |    1     |    3    |  Dominique Wilkins  |       Utah Jazz        |         15          |   26,668   |     24.8     |     6.7      |     2.5      |    117.5    |
|    1962    |    1     |    7    |    John Havlicek    |     Boston Celtics     |         16          |   26,395   |     20.8     |     6.3      |     4.8      |    131.7    |
|    1997    |    1     |    1    |     Tim Duncan      |   San Antonio Spurs    |         18          |   25,974   |     19.5     |     11.0     |     3.1      |    201.2    |
|    1995    |    1     |    5    |    Kevin Garnett    | Minnesota Timberwolves |         20          |   25,949   |     18.2     |     10.2     |     3.8      |    190.4    |
|    1998    |    1     |   10    |     Paul Pierce     |     Boston Celtics     |         17          |   25,899   |     20.7     |     5.8      |     3.7      |    149.1    |

<div class="ui basic segment">
<p class = 'ui center aligned'>We did it ladies and gentleman.  We now have a function that can pull in any and all NBA or BAA drafts we give it.</p>
<p>Today's tutorial ends here but we now have refined data gold ready for all sorts of interesting data analysis and visualization, things R also excels at.</p>
</div>


<div class="ui basic segment">
<p class = 'ui center aligned'>We did it ladies and gentleman.  We now have a function that can pull in any and all NBA or BAA drafts we give it.</p>
<img class = "ui centered large image" src="http://www.survivingcollege.com/wp-content/uploads/2013/04/tumblr_mlmzl1vRWd1soiqg9o2_500.gif" title = "Jeah">
<p>Today's tutorial ends here but we now have refined data gold ready for all sorts of interesting data analysis and visualization, things R also excels at.  Check back soon and I will have a new tutorial doing just this.</p>
<p>I hope you enjoyed this and recognize that R can do anything that Python does with ease and grace and if you ever hear someone say R isn't good at web-scraping you can shake your head and laugh!</p>
</div>
