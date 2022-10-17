# Dist to airports
airports <- readOGR("polygons/airports/") %>%
  st_as_sf() %>%
  st_transform(., crs = 4326) %>%
  filter(cod_iata %in% c("SCL", "PUQ", "ANF", "PMC", "IQQ", "CCP", "ARI", "CPO", "BBA", "CJC", "ZCO", "LSC", "ZAL", "IPC", "ZOS"))

# Create an index of nearest airports
airp_to_pa_index <- st_join(na.omit(prot_areas), airports, join = nngeo::st_nn, returnDist = FALSE, parallel = 20) %>%
  st_drop_geometry() %>%
  select(pa_name, Aerodromo) %>%
  right_join(., select(metadata_df, pa_name, type_eng)) %>%
  unite("full_pa_name", type_eng, pa_name, sep = " ", remove = FALSE) %>%
  unique()

# Get driving distances from google
gdist_airp <- sapply(unique(airp_to_pa_index$full_pa_name), function(x) {
  try({
    df <- filter(airp_to_pa_index, full_pa_name == x)
    res <- gmapsdistance(df$Aerodromo, df$full_pa_name, mode = "driving", shape = "long", combinations = "pairwise")
    Sys.sleep(5)
    return(res)
  })
}, USE.NAMES = TRUE, simplify = FALSE)

#Flatten results
airp_2_pa <- unlist2d(gdist_airp) %>%
  pivot_wider(names_from = .id.2, values_from = V1) %>%
  left_join(., airp_to_pa_index, by = c(".id.1" = "full_pa_name")) %>%
  rename(airp_2_pa_distance = Distance) %>%
  rename(airp_2_pa_time = Time) %>%
  select(pa_name, Aerodromo, airp_2_pa_distance, airp_2_pa_time) %>%
  mutate(airp_2_pa_distance = as.numeric(airp_2_pa_distance),
         airp_2_pa_time = as.numeric(airp_2_pa_time))

#Backup
#saveRDS(airp_2_pa, "airp_2_pa.rds")

#Save in SQLite database
send2sqlite(condb, "airp_2_pa", tables = T)
