# system(
#   "wget https://www.ine.cl/docs/default-source/geodatos-abiertos/cartografia/censo-2017/ciudades-pueblos-aldeas-y-caser%C3%ADos/shp/ciudades_2017.zip?sfvrsn=b86e9ed1_3;
#        mkdir ciudades_2017;
#        mv ciudades_2017.zip?sfvrsn=b86e9ed1_3 ciudades_2017/ciudades_2017.zip;
#        unzip ciudades_2017/ciudades_2017.zip -d ciudades_2017"
# )

pacman::p_load(tidyverse, rgdal, sf)

ciudades_censo <- readOGR("polygons/ciudades_2017/") %>%
  st_as_sf() %>%
  filter(TOT_PERSON > 49999) %>%
  st_transform(., crs = 4326)
st_drop_geometry(ciudades_censo) %>% View()
plot(select(ciudades_censo, TOT_PERSON))

# Create an index of nearest cities
city_to_pa_index <- st_join(na.omit(prot_areas), ciudades_censo, join = nngeo::st_nn, returnDist = FALSE, parallel = 20) %>%
  st_drop_geometry() %>%
  select(pa_name, URBANO) %>%
  right_join(., select(metadata_df, pa_name, type_eng)) %>%
  unite("full_pa_name", type_eng, pa_name, sep = " ", remove = FALSE) %>%
  unique()

# Get driving distances from google
gdist <- sapply(unique(city_to_pa_index$full_pa_name), function(x) {
  try({
    df <- filter(city_to_pa_index, full_pa_name == x)
    res <- gmapsdistance(df$URBANO, df$full_pa_name, mode = "driving", shape = "long", combinations = "pairwise")
    Sys.sleep(5)
    return(res)
  })
}, USE.NAMES = TRUE, simplify = FALSE)

#Flatten results
city_2_pa <- unlist2d(gdist) %>%
  pivot_wider(names_from = .id.2, values_from = V1) %>%
  left_join(., city_to_pa_index, by = c(".id.1" = "full_pa_name")) %>%
  rename(city_2_pa_distance = Distance) %>%
  rename(city_2_pa_time = Time) %>%
  select(pa_name, URBANO, city_2_pa_distance, city_2_pa_time) %>%
  mutate(city_2_pa_distance = as.numeric(city_2_pa_distance),
         city_2_pa_time = as.numeric(city_2_pa_time))

#Backup
#saveRDS(city_2_pa, "city_2_pa.rds")

#Save in SQLite database
send2sqlite(condb, "city_2_pa", tables = T)
