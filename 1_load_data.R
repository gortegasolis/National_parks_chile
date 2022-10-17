# Import metadata
source("Import_metadata.R")

names(metadata_df)

# Import polygons of protected areas
prot_areas <- readOGR("polygons/snaspe/") %>%
  st_as_sf() %>%
  mutate(pa_name = toupper(Nombre)) %>%
  # dplyr::rename(pa_name = ORIG_NAME) %>%
  group_by(pa_name) %>%
  summarise() %>%
  ungroup() %>%
  st_transform(., crs = 4326) %>%
  st_make_valid()

st_is_valid(prot_areas)

names(prot_areas)

prot_areas$pa_name <- gsub(x = prot_areas$pa_name, "P.N.", "", fixed = T) %>%
  gsub(x = ., "R.N.", "", fixed = T) %>%
  gsub(x = ., "M.N.", "", fixed = T) %>%
  gsub(x = ., "PARQUE NACIONAL", "", fixed = T) %>%
  gsub(x = ., "7", "SIETE", fixed = T) %>%
  str_squish() %>%
  stringi::stri_trans_general(str = ., "Latin-ASCII") %>%
  gsub(x = ., "ALACALUFES", "KAWESQAR") %>%
  gsub(x = ., "LAGUNA DE TORCA", "LAGUNA TORCA") %>%
  gsub(x = ., "LOS HUEMULES", "LOS HUEMULES DEL NIBLINTO") %>%
  gsub(x = ., "ROBLERIA COBRE DE LONCH", "ROBLERIA DEL COBRE DE LONCHA") %>%
  gsub(x = ., "CINCO HERMANOS", "CINCO HERMANAS") %>%
  gsub(x = ., "PAMPA DE TAMARUGAL", "PAMPA DEL TAMARUGAL") %>%
  gsub(x = ., "PAPOSO", "PAPOSO NORTE")

prot_map <- tm_shape(prot_areas) +
  tm_polygons()

tmap_leaflet(prot_map, mode = "view")

#Save in SQLite database
send2sqlite(condb, "prot_areas", tables = T)
