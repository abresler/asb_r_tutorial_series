


<div class="ui basic inverted segment"><h2 class="ui green header">What's the Dealio?</h2></div>

<div class="ui basic segment"><p>This is the first of what I hope will be on an ongoing series with the word class hoops heads at <a href='http://nyloncalculus.com' target='_blank'>Nylon Calculus</a> that explores learning Data Science through the beautiful lense of NBA Basketball.  This tutorial will teach you how to recreate <a href='https://twitter.com/Savvas_tj' target='_blank'>Savvas Tjortjoglou's</a> fantastic piece on using <a href='http://python.org/' target='_blank'>Python</a> to <a href='http://nyloncalculus.com/2015/09/07/nylon-calculus-101-data-scraping-with-python//' target='_blank'>extract NBA historic draft data</a> using R.  If you have yet to read the piece I highly recommend you do so before working through this tutorial.</p></div>

<div class="ui basic ui inverted red segment"><h2 class="ui header">Word of Caution</h2></div>

<div class="ui basic segment"><p>This and any future tutorials are not intended taken as:</p>
<li>An endorsement of R as the best programming language.</li>
<li>A characterization of Python as a bad or inferior language.</li>
<br>
<p>As I detailed in my <a href='http://asbcllc.com/presentations/si_hackathon/#/' target='_blank'>Sports Illustrated Hackathon keynote presentation</a>, it doesn't matter which programming language you pick so long as you master it to and use your skills to solve problems.</p>
<p>Any of the major programming languages {R, Python, JavaScript, C, ect..} with some expertise will let you do the truly amazing things that programming languages can do!  If you are a true amateur I'd advocate taking some time to learn about the major languages and then deciding which you think is best suited for you to learn.</p>

<p>That said, this and future tutorials **are** intended to destroy some misconceptions about the language that I love, <a href='https://en.wikipedia.org/wiki/R_(programming_language)' target='_blank'>R</a>.  There are myths you may come across that imply R is inferior to Python for web-scraping, that it's syntax doesn't make sense and that the language is too hard to learn.  <strong>None of these things are true</strong> and I hope by the end of this post, whatever existing programming language of choice is, learned or intended to be learned, you won't disagree with this statement.
</div>

<div class="ui inverted basic segment"><h2 class="ui yellow header">Enough of the Boring Stuff, Let's Gokul</h2></div>

<img class = "ui centered large image" src="http://static2.businessinsider.com/image/51a7a46369bedd4e01000009/gokel.gif" title = "My Boy Gokul">

<div class="ui basic segment">
<p>In order to complete today's tutorial you are going to ensure your computer is locked and load with a few things. 
<li>First make sure you have <a href="http://cran.r-project.org/" target='_blank'>R</a> and <a href="http://www.rstudio.com/products/rstudio/" target='_blank'>RStudio</a> installed.</li>
<li>Then if you don't already use <a href="https://www.mozilla.org/en-US/firefox/new/" target='_blank'>Firefox</a> or <a href="http://www.google.com/chrome/" target='_blank'>Chrome</a> pick a browser horse and install it.</li>
<li>Finally, launch your chosen browse and install the <em>fantastic</em> <a href="http://selectorgadget.com/" target='_blank'>SelectorGadget</a> widget.</li>
<br>
Fire up <img src="http://www.rstudio.com/wp-content/uploads/2014/06/RStudio-Ball.png" alt="" height = "30px" width = "30px">, because it's game time.
</p>
<p>The final step before we are ready for action is to ensure you have the necessary R packages installed. I am using the development versions of many of these packages. For those who need to install the packages, I've referenced the github repos in the comments, just copy and paste the code starting at <code>devtools::</code> until the end the line into.  For the non development packages just copy and paste starting from <code>install.packages</code>.
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
<p>In order to mine for NBA draft data gold we need to know a few things, the most important of which being what years have the draft has existed?</p>
<p>To answer this question we navigate our browsers here <code><a href = 'http://www.basketball-reference.com/draft/' target="_blank">http://www.basketball-reference.com/draft/</a></code>.  It looks like the draft has existed since <strong>1947</strong> if you include the NBA's precursor league the <a href = 'https://en.wikipedia.org/wiki/Basketball_Association_of_America' target="_blank">BAA</a> and <strong>1950</strong> if you don't.  
</p>
<p>We are almost ready to start mining we just need to pick a draft year to test.  Given that it was the year this distinguished author's birth, let's go with <strong>1983</strong>.  From the main draft index page click on the <code><a href = 'http://www.basketball-reference.com/draft/NBA_1983.html'  target="_blank">1983 Draft</a></code> link.  </p>
<p>Look at all that beautiful data just waiting for us to suck in, I am giddy.</p>
<img class = "ui centered large image" src="http://media.giphy.com/media/jDpKEDa83adRm/giphy.gif" title = "Bosh Yea">
<p>However, before we get ahead of ourselves thinking we've unlocked the magic formula to bringing data we long to explore into R we must find one more key input.  This important missing piece is the <a href = 'https://en.wikipedia.org/wiki/CSS' target = '_blank' >CSS</a> identifier of the data we want from the page, in this case the draft table.  Think of this piece of information as unique identifier for the the html data on the page we want.</p>
<p>Remember that SelectorGadget I mentioned earlier?  It's time to use it to extract the CSS identifier we need.
<li>Click the widget's button.</li>
<li>Next scroll over the table with the draft information</li>
<li>Click once an orange box surrounds the table</li>
<li>You should see something like the picture below</li>
<img class = "ui centered huge image" src="http://i.imgur.com/rdA0pMn.png" title = "css information">
</p>
<br>
<p>Just like the <a href = 'www.youtube.com/watch?v=Z5-rdr0qhWk' target = '_blank' >1978 Cars song</a> said, we've got <i>Just What We Needed</i> it's time to go data mining.</p>
</div>

<div class="ui inverted circular segment">
<h2 class="ui inverted header">
Step 1
</h2>
</div>
<div class="ui inverted red circular segment">
<h2 class="ui inverted header">
Enlighten Our Code
</h2>
</div>
<div class="ui inverted green circular segment">
<h2 class="ui inverted header">
Extract
</h2>
</div>
<div class="ui inverted blue circular segment">
<h2 class="ui inverted header">
Clean
</h2>
</div>

<div class="ui basic segment">
<p>During this next portion of the tutorial we are going to write code that will port the NBA draft data into a <code><a href = 'http://www.r-tutor.com/r-introduction/data-frame' target = '_blank'>data frame</a></code>.  We are going to use the excellent <code><a>rvest</a></code> package accomplish much of this.  Essentially our code is going to:
<li>Create the URL where the data lives</li>
<li>Use the URL to navigate to the page</li>
<li>Capture the page in R</li>
<li>Identify draft table</li>
<li>Put the table into a data frame.</li>
<li>Clean the messy imported data</li>
</p>
<p>However, before we complete those steps I want to <strong>enlighten</strong> our code.  By that I mean I want to teach our code to be aware of the context of the data we are collecting. This will make our code self adjusting so we don't have to update our code over and over again as new drafts occur {assuming the HTML structure of the page where the data lives doesn't change, a far from fail proof assumption}.</p>
<p>Specifically, we are going to teach our code to allow us to only search for draft years that are completed.  We are also going to teach our code how to differentiate between a BAA and NBA draft while simultaneously telling us which one we picked.  We also want our code to tell us if we are searching for an ineligible draft year and stop what it is doing if we happen to make this mistake.</p>
<p>One major aside, you are going to see me use alot of the symbol <code>%>%</code>, it is a called a <strong>pipe chaining operator</strong>, think of it like the term <strong>then</strong>.  I'm a huge fan of chaining it makes code flow more smoothly and cuts down on the amount of code you need to write. If you are on a Mac you can have R write a pipe easily by pressing <code>command+shift+M</code>, Windows users I believe there is similar syntax as well.</p>
<p>Finally, if you are here to try to learn some R, I urge you to try to follow along with my comments by looking for <code>#</code> and in case you are wondering <code><-</code> is how you assign thing in R and <code>%<>%</code> is a beautiful combination of <code>%>%</code> and <code><-</code>, much simultaneously takes something, transforms it and assigns it.</p>
</div>


```r
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
```

```
## [1] "http://www.basketball-reference.com/draft/NBA_1983.html"
```

<div class="ui basic segment">
<p>Fantastic, this code based upon our selected draft year creates the URL where the draft data lives.  Now that we have this we can move on to the fun part
<br>
<div class="ui green inverted center aligned segment">Data Extraction</div>
</p>
<p>I am going to write some fairly advanced data cleaning code that will use R's magic to infer player's corresponding draft round so we can add it as a variable in our data frame, unfortunately Basketball-Reference doesn't provide that information to us in an easily usable way.</p>
<img class = "ui centered large image" src="https://usatftw.files.wordpress.com/2014/07/c01_covmain_17_25159729.jpg?w=1000&h=661" title = "Lebron GIF">
</div>


```r
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

raw_data %>% 
  glimpse # This function gives us a snapshot of our data frame!
```

```
## Observations: 226
## Variables: 22
## $ id.round            (dbl) 1, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 1, 5, ...
## $ id.pick             (dbl) 1, 10, 100, 101, 102, 103, 104, 105, 106, ...
## $ id.bref.team        (chr) "HOU", "WSB", "UTA", "DET", "DAL", "WSB", ...
## $ player              (chr) "Ralph Sampson", "Jeff Malone", "Matt Clar...
## $ college             (chr) "University of Virginia", "Mississippi Sta...
## $ totals.years_played (dbl) 9, 13, NA, 1, 1, NA, NA, NA, NA, NA, NA, N...
## $ totals.g            (dbl) 456, 905, NA, 7, 1, NA, NA, NA, NA, NA, NA...
## $ totals.mp           (dbl) 13591, 29660, NA, 28, 16, NA, NA, NA, NA, ...
## $ totals.pts          (dbl) 7039, 17231, NA, 12, 3, NA, NA, NA, NA, NA...
## $ totals.trb          (dbl) 4011, 2364, NA, 3, 5, NA, NA, NA, NA, NA, ...
## $ totals.ast          (dbl) 1038, 2154, NA, 1, 0, NA, NA, NA, NA, NA, ...
## $ shooting.fg_pct     (dbl) 0.486, 0.484, NA, 0.462, 0.333, NA, NA, NA...
## $ shooting.3p_pct     (dbl) 0.172, 0.268, NA, NA, NA, NA, NA, NA, NA, ...
## $ shooting.ft_pct     (dbl) 0.661, 0.871, NA, NA, 0.500, NA, NA, NA, N...
## $ per_game.mp         (dbl) 29.8, 32.8, NA, 4.0, 16.0, NA, NA, NA, NA,...
## $ per_game.pts        (dbl) 15.4, 19.0, NA, 1.7, 3.0, NA, NA, NA, NA, ...
## $ per_game.trb        (dbl) 8.8, 2.6, NA, 0.4, 5.0, NA, NA, NA, NA, NA...
## $ per_game.ast        (dbl) 2.3, 2.4, NA, 0.1, 0.0, NA, NA, NA, NA, NA...
## $ advanced.ws         (dbl) 20.1, 54.2, NA, 0.0, 0.0, NA, NA, NA, NA, ...
## $ advanced.ws_per_48  (dbl) 0.071, 0.088, NA, -0.046, -0.003, NA, NA, ...
## $ advanced.bpm        (dbl) 0.0, -2.1, NA, -6.9, -12.1, NA, NA, NA, NA...
## $ advanced.vorp       (dbl) 6.8, -0.9, NA, 0.0, 0.0, NA, NA, NA, NA, N...
```

<div class="ui basic segment">
<p>Booyah, just like that we have the data from the table for the 1983 draft.</p>
<div class="ui huge black message">Data Mined.</div>
<img class = "ui centered large image" src="https://s-media-cache-ak0.pinimg.com/originals/fa/0b/cf/fa0bcf6038813071226f70396fb8115a.gif" title = "Booyah">
</div>

<div class="ui inverted circular segment">
<h2 class="ui inverted header">
Step 2
</h2>
</div>
<div class="ui inverted red circular segment">
<h2 class="ui inverted header">
Import Page's Other Valuable Data
</h2>
</div>
<div class="ui inverted green circular segment">
<h2 class="ui inverted header">
Resolve
</h2>
</div>
<div class="ui inverted blue circular segment">
<h2 class="ui inverted header">
Messagify
</h2>
</div>

<div class="ui basic segment">
<p>Believe it or not we are almost done and the hardest parts are behind us.  All that is left to do is import the other valuable data from the draft page that being the player's BREF ID, if it exists, which in turn gives us the player's BREF profile URL. In addition to that, we want to resolve the BREF team IDs to the actual draft team.</p>
<p>The player IDs can be found the same way we brought in the table data, their CSS identifiers.  In this case they are they are an <code>attribute</code> of the 4th table data column.</p>
<p>As for the resolving the team IDs that is more complicated process which I've taken the liberty of already doing separately.  We are going to just read in that file which contains all the BREF team IDs, the team names, current team ids, and whether the franchise is still in existence.</p>
<p>After collecting and importing that information we will merge it the existing data framewe will be finished!  The final step is a personal preference, though completely unnecassary to the process of learning to be an R coding master.  I like to <strong>Messagify</strong> my code, especially when functions are built around the code, and that's coming next folks.  Messages show you that your code is done running and can be tailored to, make you laugh, feel good about your work, or as the case here, learn a potentially random new fact.  When we build our functions I will show you how to make Messagifying optional</p>
</div>


```r
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
```

```
## Congratulations you pulled in data for all 226 players from the 1983 Draft
## Have you heard of the #33 pick, Dirk Minniefield?
## He played 3 seasons & ranked #33 in his draft class for total points scored!
```

<div class="ui basic segment">
<p>The moment of truth is here, we've completed the steps need to bring the cleaned and resolved draft data into R, now we have to make sure it worked!
</p>
<p>
To do that we are going to select the a few columns, arrange by top total point scorers, and look at the top 5 names.
</p>
</div>


```r
data %>% 
  select(id.round, id.pick, player, team, totals.years_played, totals.pts) %>%
  mutate(totals.pts = totals.pts %>% comma(digits = 0)) %>% # formats to adda comma
  head %>% # Takes the top 5 players
  format_table(align = 'c') # This creates the beautiful SVG table you are looking at
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
<p class = 'ui center aligned'>Now that we know our code works is fleek and works like Draymond Green in the paint, it's time to take our code and turn it into a function we can use whenever we feel like it.  As I mentioned earlier, I am going to add in a few lines of code that will make returning a message optional.  I am going to rewrite the code from earlier in a consolidated manner so you can just skip to the bottom if you want.</p>
</div>


```r
get_nba_year_draft_data <-
  function(draft_year = 1983, # this is the default year if you run the function with no year sepcified
           return_message = T # this specifies the default behavior is to return our message
           ) {
    options(warn = -1) # Turns off some annoying warnings
    
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
      mutate(name.column = ifelse(header %>% is.na, column, 
                                  paste(header, column, sep = '.'))
             )
    
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
        totals.years_played = yrs 
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
    
    if (
      return_message == T # this will only run our message if we tell it to in our function
        ) {
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
    return(data) # returns the final data frame, this is what we see!
  }
```

<div class="ui inverted red segment">
<p>Lets put our function to work and make sure we can accurately pull in the data from <strong>2013 Draft</strong>.</p>
</div>


```r
data <- 
  get_nba_year_draft_data(draft_year = 2013,return_message = T)
```

```
## Congratulations you pulled in data for all 60 players from the 2013 Draft
## Have you heard of the #34 pick, Isaiah Canaan?
## He played 2 seasons & ranked #22 in his draft class for total points scored!
```
<div class="ui basic segment">
<p class = 'ui center aligned'>
Let's repeat what we did earlier, this time we are going to add a few more columns and look at the first 15 picks.
</p>
</div>

```r
data %>% 
  select(id.round, id.pick, player, team, totals.years_played, totals.pts, per_game.pts, per_game.trb, per_game.ast, advanced.ws) %>%
  mutate(totals.pts = totals.pts %>% comma(digits = 0)) %>% #some formating
  head(15) %>%  # Takes the top 15
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
<div class="ui black segment">Oh Anthony Bennett.....</p>
<img class = "ui centered large image" src="https://usatthebiglead.files.wordpress.com/2014/01/anthony-bennett-jumps-when-touched-with-powerade-against-knicks.gif" title = "Anthony Bennett">
</div>

<div class="ui inverted circular segment">
<h2 class="ui inverted header">
Part II
</h2>
</div>
<div class="ui inverted grey circular segment">
<h2 class="ui inverted header">
Scale the Function to the NBA Draft Heavens
</h2>
</div>
<div class="ui inverted blue circular segment">
<h2 class="ui inverted header">
Write the Complete Draft History Data to Disk
</h2>
</div>

<div class="ui basic segment">
<p class = 'ui center aligned'>
We now have demonstrated that our function works and will provide us for draft data for any valid year we give it.  We can take this function and integrate it into another function that will let us pull in the complete NBA/BAA draft history or the specific draft years we want.  We already put in the hard work creating the first function, this second function only has a few missing pieces before it will be up and running.
</p>
<p>
We want our function to let us explicitly ask us whether we want the BAA data.  We want our code to know what to do if we don't identify an explicit range of drafts.  In this case we want our code to return all the eligible drafts if the range is undefined.  Finally Messagify this function to return a random fact about a player in the chosen range.</p>
<a class="ui  red tag label"><strong>Let's Do It!!</strong></a>
<a class="ui teal tag label">It's Only Going to Take a Minute or 2!</a>
<a class="ui black tag label">Don't Forget to Test the Function On Years You Are Interested in Seeing!!</a>
</div>


```r
get_all_nba_draft_data <- function(year_start = NA, year_end = NA,
                                   include_baa = T, return_message = T) {
  
  # This makes sure the first function is in your environment
  if ('get_nba_year_draft_data' %in% ls() ){
    #
  }
  
  if (
    include_baa == T # asks us if we want BAA data, assumes we do
    ) {
    year.first_draft <-
      1947 # first BAA draft year
  } else {
    year.first_draft <- 
      1950 # first NBA draft year
  }
  
  if (year_start %>% is.na) {
    year_start <-
      year.first_draft # takes the first BAA or NBA draft year if we don't give our code a start year
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
      as.numeric() - 1 # Takes the most recent draft if we don't identify an explicit end to the draft range
  }
  
  if (year_end %>% is.na) {
    year_end <- 
      year.most_recent_draft #If we don't select an end draft year overwrite with the most recent
  }
  
  draft_years <- 
    year_start:year_end #create a numeric vector of the draft years we want
  
  ## Loop through the selected draft years, get the data and append it to the master data frame
  
  all_data <- 
    data_frame() # form an empty data_frame that will act as the master data frame
  
  for (year in draft_years){
    data <- 
      get_nba_year_draft_data(draft_year = year, return_message = F) # we dont want to see a bunch of messages so lets turn it off for this
    
    all_data %<>% # takes the master data frame
      bind_rows(data) # binds the rows of the year's data frame to that
  }
  
  if (return_message == T) {
    players <-
      all_data %>% 
      nrow
    
    ## We want this message to show us some random facts about one of the top 1000 scorers
    
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
  return(all_data) #returns the data
}
```
<div class="ui basic segment">
<p class = 'ui center aligned'>
The function should be loaded into your environment.  Let's test it out.  Since the function is smart and makes assumptions if information isn't given, you don't need to input any assumptions, doing this will return the full NBA draft history inclusive of the BAA drafts.
</p>
<p>Oh yea, be patient this function might take a little while.</p>
</div>

```r
all_data <- 
  get_all_nba_draft_data()
```

```
## Congratulations you pulled in data for 7789 players from the 1947 to 2015 drafts
## Have you heard of the #4 pick in the 1985 Draft, Xavier McDaniel?
## He played 12 seasons & ranks #170 all time in total points scored during your selected draft eras!
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
<p>
Now that we have the entire draft history in a data frame we can write it to disk so we have it locally.
</p>
</div>


```r
all_data %>% 
  write_csv(path = 'data/nba_baa_drafts_1947_2015.csv') #pick where ever you want to save it this is just my choice.
```

<div class="ui basic ui inverted blue segment"><h2 class="ui header">Parting Notes</h2></div>
<div class="ui basic segment">
<p class = 'ui center aligned'>We did it ladies and gentleman.  We now have a function that can pull in any and all NBA or BAA drafts we give it.</p>
<img class = "ui centered large image" src="http://www.survivingcollege.com/wp-content/uploads/2013/04/tumblr_mlmzl1vRWd1soiqg9o2_500.gif" title = "Jeah">
<p>Today's tutorial ends here but we now have refined NBA draft data gold ready for all sorts of interesting data analysis and visualization, things R also excels at.<p>
<p>Check back soon and for a tutorial that will teach how how to visualize and analyze this dataset.</p>
<p>I hope you enjoyed this and recognize that R can do anything that Python does with ease and grace and if you ever hear someone say R isn't good at web-scraping you can shake your head and laugh!</p>
<p>You can find the code for the functions <a href = 'https://github.com/abresler/asb_r_tutorial_series/tree/master/python_to_r/nba/draft_scraper_09_08_2015/code' target = '_blank'>here</a> and I urge you to download or fork the repo and use the code whenever you need it!</p>
<div class="ui inverted green segment">
<p>As always please don't hesitate to reach out to me on <a href = 'https://twitter.com/abresler'>twitter</a> with any questions, comments and concerns!</p>
</div>
</div>

<div class="ui inverted red circular segment">
<h2 class="ui inverted header">
Shout
</h2>
</div>
<div class="ui inverted circular segment">
<h2 class="ui inverted header">
Outs
</h2>
</div>

<div class="ui divided selection list">
<a class="item">
<div class="ui black horizontal label"><a href = 'https://twitter.com/hadleywickham' target="_blank">Hadley Wickham</a></div>
<small>Author of most of the amazing R packages we used today</small>
</a>
<a class="item">
<div class="ui red horizontal label"><a href = 'http://savvastjortjoglou.com/' target="_blank">Savvas Tjortjoglou</a></div>
<small>Inspiration for this tutorial and basketball data blogger extraordinaire </small>
</a>
<a class="item">
<div class="ui teal horizontal label"><a href = 'http://semantic-ui.com/' target="_blank">Semantic-UI</a></div>
<small>Web's most beautiful open-source UI frame-work.</small>
</a>
</div>
