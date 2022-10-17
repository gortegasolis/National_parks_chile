# Query Google Trends
id_list <- unique(na.omit(metadata_df$schema_id))
id_list

id_list2 <- unique(na.omit(paste(metadata_df$type_eng, metadata_df$pa_name)))
id_list2

g_int_fun <- function(x, geo = "") {
  dat <- gtrends(keyword = c("/m/02p92st", x), geo = geo, time = "2007-01-01 2021-01-01")
  Sys.sleep(sample(10:30, 1))
  return(dat)
}

gtrends_data_world <- lapply(id_list, function(x) {
  tryCatch(g_int_fun(x),
    error = function(e) e
  )
})

gtrends_data_chile <- lapply(id_list, function(x) {
  tryCatch(g_int_fun(x, geo = "CL"),
    error = function(e) e
  )
})

gtrends_data_world2 <- lapply(id_list, function(x) {
  res <- call_gtrends_wd(x, key_gtrends)
  Sys.sleep(sample(1:5, 1))
  return(res)
})

gtrends_data_chile2 <- lapply(id_list, function(x) {
  res <- call_gtrends_cl(x, key_gtrends)
  Sys.sleep(sample(1:5, 1))
  return(res)
})

gtrends_data_world3 <- lapply(id_list2, function(x) {
  res <- call_gtrends_wd(x, key_gtrends)
  Sys.sleep(sample(1:5, 1))
  return(res)
})

gtrends_data_chile3 <- lapply(id_list2, function(x) {
  res <- call_gtrends_cl(x, key_gtrends)
  Sys.sleep(sample(1:5, 1))
  return(res)
})
