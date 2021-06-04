# milb_pbp_data
Contains scripts for building and updating a MiLB play-by-play database

## Building a database for the first time

Users should first ensure that they have a database environment set up with credentials to write to. The scripts here assume a PostGreSQL database with a table 'milb_pbp', but that can all be customized within the script based on the user.

Users should set their working directory to `~/milb_pbp_data/building_milb_pbp_db`. From there, open the `build_milb_pbp_db.R` script.

## Non-MLB level codes

Here is a key for non-MLB levels and their corresponding code

1 = MLB</br> 
11 = Triple-A</br> 
12 = Doubl-A</br> 
13 = Class A Advanced</br> 
14 = Class A</br> 
15 = Class A Short Season</br> 
5442 = Rookie Advanced</br> 
16 = Rookie</br> 
17 = Winter League</br> 


