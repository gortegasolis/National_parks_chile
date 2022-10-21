#Forest height
source("0_load_install_libraries.R")
require(stars)
require(geobgu)
conflict_prefer("filter", "dplyr")
conflict_prefer("select", "dplyr")

potapov <- read_stars("potapov/Forest_height_2019_SAM.tif")

prot_areas <- readRDS("prot_areas.rds")
prot_areas <- st_transform(prot_areas, st_crs(potapov))

prot_fheight <- list()
a <- 0

for (x in na.omit(unique(prot_areas$pa_name))){
  a <- a+1
  print(a)
  
  prot <- filter(prot_areas, pa_name == x)
  
  potapov_crop <- st_crop(potapov, prot)
  
  prot_fheight[[a]] <- prot %>%
    mutate(for_height = geobgu::raster_extract(potapov_crop, prot, fun = mean, na.rm = TRUE))
  
  if(is.na(prot_fheight[[a]]$for_height[1])){
    prot_fheight[[a]] <- prot %>%
      mutate(for_height = geobgu::raster_extract(potapov, prot, fun = mean, na.rm = TRUE))
  }
}

# prot_fheight2 <- filter(prot_areas, pa_name %in% c("ISLA CACHAGUA","ISLOTES DE PUNIHUIL","LA PORTADA"))
# 
# prot_fheight2 <- prot_fheight2 %>%
#   mutate(for_height = geobgu::raster_extract(potapov, prot, fun = mean, na.rm = TRUE))

saveRDS(prot_fheight, "prot_fheight.rds")

prot_fheight <- readRDS("prot_fheight.rds")

prot_fheight <- data.table::rbindlist(prot_fheight) %>% select(!geometry)
