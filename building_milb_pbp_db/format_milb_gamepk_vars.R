#### Align formatting of MiLB game_pk files

format_milb_gamepk_vars <- function(df) {
  
  # character
  
  character_vars <- c("calendarEventID", "content.link", "dayNight", "description", 
                      "doubleHeader", "gameDate", "gamedayType", "gameType", "ifNecessary", "ifNecessaryDescription", 
                      "link", "recordSource", "rescheduledFrom", "resumedFrom", 
                      "seriesDescription", "sport.name", "status.abstractGameState", 
                      "status.detailedState", "teams.away.team.link", "teams.away.team.name", 
                      "teams.home.team.link", "teams.home.team.name", "tiebreaker", 
                      "venue.link", "venue.name")
  
  # numeric
  
  numeric_vars <- c("game_pk", "gameNumber", "gamesInSeries", "inningBreakLength", 
                    "new_season", "scheduledInnings", "season", "seasonDisplay", 
                    "seriesGameNumber", "sport.id", "teams.away.leagueRecord.losses", 
                    "teams.away.leagueRecord.pct", "teams.away.leagueRecord.wins", 
                    "teams.away.score", "teams.away.seriesNumber", "teams.away.team.id", 
                    "teams.home.leagueRecord.losses", "teams.home.leagueRecord.pct", 
                    "teams.home.leagueRecord.wins", "teams.home.score", "teams.home.seriesNumber", 
                    "teams.home.team.id", "venue.id")
  
  # logical
  
  logical_vars <- c("isTie", "publicFacing", "rescheduleDate", "resumeDate", "status.abstractGameCode", 
                    "status.codedGameState", "status.reason", "status.startTimeTBD", 
                    "status.statusCode", "teams.away.isWinner", "teams.away.splitSquad", 
                    "teams.home.isWinner", "teams.home.splitSquad")
  
  df <- df %>%
    dplyr::mutate_if(names(df) %in% character_vars, as.character) %>%
    dplyr::mutate_if(names(df) %in% numeric_vars, as.numeric) %>%
    dplyr::mutate_if(names(df) %in% logical_vars, as.logical)
  
  return(df)
  
}

