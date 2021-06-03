#### Build a data set of historical MiLB game_pks
#### Bill Petti 
#### 2021-06

map_milb_game_pks <- function(start_date = '2021-06-01', 
                              end_date = '2021-06-01', 
                              milb_levels = c(11,12,13,14,15,5442,16,17)) {
  
  dates <- seq.Date(as.Date(start_date), as.Date(end_date), by = 'day')
  
  gp_grid <- expand.grid(levels = milb_levels,
                         dates = dates)
  
  safe_gp <- purrr::safely(get_game_pks_mlb)
  
  milb_gp <- purrr::map2(.x = gp_grid$levels,
                         .y = gp_grid$dates,
                         ~{message(paste0('Collecting all game_pks on ', .y, ' for level ', .x))
                           
                           safe_gp(date = .y, level_ids = .x)
                         })
  
  milb_gp_bind <- milb_gp %>%
    purrr::map('result') %>%
    dplyr::bind_rows() %>%
    format_milb_gamepk_vars()
  
  return(milb_gp_bind)
}