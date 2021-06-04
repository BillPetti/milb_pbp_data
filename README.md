# milb_pbp_data
Contains scripts for building and updating a MiLB play-by-play database

## Building a database for the first time

Users should first ensure that they have a database environment set up with credentials to write to. The scripts here assume a PostGreSQL database with a table 'milb_pbp', but that can all be customized within the script based on the user.

Users should set their working directory to `~/milb_pbp_data/building_milb_pbp_db`. From there, open the `build_milb_pbp_db.R` script.

