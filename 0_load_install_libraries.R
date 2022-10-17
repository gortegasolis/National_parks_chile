# Load/install libraries
pacman::p_load(
  readxl,
  gkgraphR,
  rgdal,
  sf,
  lwgeom,
  spdplyr,
  gtrendsR,
  parallel,
  RSelenium,
  rvest,
  stringi,
  elevatr,
  raster,
  spdep,
  parallel,
  tmap,
  nngeo,
  reticulate,
  conflicted,
  RSQLite
)

pacman::p_load(tidyverse)

# Function to keep a lightweight workspace
send2sqlite <- function(con, dataframe, tables = F) {
  if (is(get(dataframe), "sf") == T){
   st_write(get(dataframe), dsn = con, layer = paste0("spat_", dataframe))
  } else{
    RSQLite::dbWriteTable(
      conn = con,
      name = paste0("tbl_", dataframe),
      value = get(dataframe),
      overwrite = T
    )
  }

  rm(
    list = dataframe,
    envir = .GlobalEnv
  )
  if (tables == T) {
    dbListTables(con)
  }
}

# Connect database
condb <- dbConnect(RSQLite::SQLite(), "National_parks.sqlite")
dbGetInfo(condb)
