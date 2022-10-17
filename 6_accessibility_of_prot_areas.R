#Accessibility data
source("0_load_install_libraries.R")
require(stars)
require(geobgu)
conflict_prefer("filter", "dplyr")
conflict_prefer("select", "dplyr")

#Accessibility taken from Weiss, et al. 2018. 10.1038/nature25181
access <- read_stars("accessibility/acc_50k.tif")

prot_areas <- readRDS("prot_areas.rds")
prot_areas <- st_transform(prot_areas, st_crs(access))

prot_acc <- list()
a <- 0

for (x in na.omit(unique(prot_areas$pa_name))){
  a <- a+1
  print(a)

  prot <- filter(prot_areas, pa_name == x)

  access_crop <- st_crop(access, prot)

  prot_acc[[a]] <- prot %>%
    mutate(acc_50k = geobgu::raster_extract(access_crop, prot, fun = mean, na.rm = TRUE))

  if(is.na(prot_acc[[a]]$acc_50k[1])){
    prot_acc[[a]] <- prot %>%
      mutate(acc_50k = geobgu::raster_extract(access, prot, fun = mean, na.rm = TRUE))
  }
}

# prot_acc2 <- filter(prot_areas, pa_name %in% c("ISLA CACHAGUA","ISLOTES DE PUNIHUIL","LA PORTADA"))
#
# prot_acc2 <- prot_acc2 %>%
#   mutate(acc_50k = geobgu::raster_extract(access, prot, fun = mean, na.rm = TRUE))

saveRDS(prot_acc, "prot_acc.rds")

prot_acc <- readRDS("prot_acc.rds")

prot_acc <- data.table::rbindlist(prot_acc) %>% select(!geometry)
