#### Build or Re-build Minor League PBP Database
#### Bill Petti
#### 2021-06

# load necessary libraries

require(baseballr)
require(tidyverse)
require(DBI)
require(RPostgreSQL)

# load helper functions

source('format_milb_gamepk_vars.R')
source('map_milb_game_pks.R')

## if you need to update the milb game_pks to pull, uncomment and run the following functions 
# pull all game_pk IDs for minor league games since 2010

milb_game_pks_bind <- map_milb_game_pks(start_date = '2010-01-01',
                                        end_date = '2021-12-31',
                                        milb_levels = c(11,12,13,14,15,5442,16,17))

write_csv(milb_game_pks_bind, '~/milb_pbp_data/milb_game_pk_master.csv')

# read in game_pk IDs

milb_game_pks_bind <- vroom::vroom('~/milb_pbp_data/milb_game_pk_master.csv')

cols <- readRDS('~/milb_pbp_data/milb_db_cols.RDS')

# this function will take a year and a level, loop over all associated game_pks, 
# and create a combined data set

annual_milb_pbp <- function(year, level) {
  
  game_pks <- milb_game_pks_bind %>%
    dplyr::filter(season == year,
                  sport.id == level)
  
  safe_pbp <- purrr::safely(get_pbp_mlb)
  
  total <- nrow(game_pks)
  
  game_pbp <- purrr::map2(.x = game_pks$game_pk,
                          .y = seq_along(game_pks$game_pk),
                          ~{message(paste0('Acquiring game ', .y, ' out of ', total, ' (', (round(.y/total, 2))*100,'%) for level ', unique(game_pks$sport.id), ' in ', unique(game_pks$season)))
                            safe_pbp(.x)}
  )
  
  game_pbp <- game_pbp %>%
    purrr::map('result') %>%
    dplyr::bind_rows() %>%
    dplyr::mutate(season = as.numeric(substr(game_date, 1, 4)))
  
  game_pbp <- game_pbp %>%
    dplyr::select(one_of(cols[-1]))
  
  return(game_pbp)
}

# this function will take the data set from the previous function, delete any existing data
# in the user's database for that year and level, and then upload/append that data to the 
# existing data set

delete_and_upload <- function(df, 
                              year, 
                              level, 
                              db_table) {
  
  # customize the pg and statcast_db variables based on your database settings
  
  pg <- DBI::dbDriver("PostgreSQL")
  
  statcast_db <- DBI::dbConnect(pg, dbname = "williampetti", 
                                user = "williampetti", 
                                password = "",
                                host = "localhost", 
                                port = 5432)
  
  query <- paste0('DELETE from milb_pbp where season = ', year, ' and home_level_id = ', level)
  
  DBI::dbGetQuery(statcast_db, query)
  
  DBI::dbWriteTable(statcast_db, db_table, df, append = TRUE, overwrite = FALSE)
  
  DBI::dbDisconnect(statcast_db)
  rm(statcast_db)
}

# create table and upload first year

payload <- annual_milb_pbp(2017, level = 13)

statcast_db <- DBI::dbConnect(pg, dbname = "williampetti", 
                              user = "williampetti", 
                              password = "",
                              host = "localhost", 
                              port = 5432)

DBI::dbWriteTable(statcast_db, "milb_pbp", payload, overwrite = TRUE)

rm(df)
gc()

# download and upload additional years and levels
# you can set the years and sport.ids to be whatever you like, 
# but mind that you may want some breaks to batch things

grid_for_map <- expand.grid(year = c(2017,2018,2019), 
                            sport.id = c(11, 12, 13, 14, 15, 5442, 16, 17))

purrr::map2(.x = grid_for_map$year,
            .y = grid_for_map$sport.id,
            ~{message('Now scraping games for level ',.y, ' for the ', .x, ' season...')
              
              payload <- annual_milb_pbp(year = .x, 
                                         level = .y)
              
              message('Uploading new data for level ',.y, ' for the ', .x, ' season...')
              
              delete_and_upload(df = payload, 
                                year = .x, 
                                level = .y, 
                                db_table = "milb_pbp")
            })

# create indices

statcast_db <- DBI::dbConnect(pg, dbname = "williampetti", 
                         user = "williampetti", 
                         password = "",
                         host = "localhost", 
                         port = 5432)

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_batter_name')

DBI::dbGetQuery(statcast_db, 'create index milb_pbp_batter_name on milb_pbp ("matchup.batter.fullName")')

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_pitcher_name')

DBI::dbGetQuery(statcast_db, 'create index milb_pbp_pitcher_name on milb_pbp ("matchup.pitcher.fullName")')

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_season')

DBI::dbGetQuery(statcast_db, 'create index milb_pbp_season on milb_pbp (season)')

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_in_play')

DBI::dbGetQuery(statcast_db, 'create index milb_pbp_in_play on milb_pbp ("details.isInPlay")')

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_event')

DBI::dbGetQuery(statcast_db, 'create index milb_pbp_event on milb_pbp ("result.eventType")')

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_pitcher_index')

DBI::dbGetQuery(statcast_db, 'create index milb_pbp_pitcher_index on milb_pbp ("matchup.pitcher.id")')

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_batter_index')

DBI::dbGetQuery(statcast_db, 'create index milb_pbp_batter_index on milb_pbp ("matchup.batter.id")')

DBI::dbGetQuery(statcast_db, 'drop index milb_pbp_date')

DBI::dbGetQuery(statcast_db, "create index milb_pbp_date on milb_pbp (game_date)")

DBI::dbGetQuery(statcast_db, "drop index milb_pbp_type")

DBI::dbGetQuery(statcast_db, "create index milb_pbp_type on milb_pbp (type)")

DBI::dbGetQuery(statcast_db, "drop index milb_pbp_home_level_id")

DBI::dbGetQuery(statcast_db, "create index milb_pbp_home_level_id on milb_pbp (home_level_id)")

DBI::dbGetQuery(statcast_db, "drop index milb_pbp_away_level_id")

DBI::dbGetQuery(statcast_db, "create index milb_pbp_away_level_id on milb_pbp (away_level_id)")
