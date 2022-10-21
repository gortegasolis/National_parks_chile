# Build dataframe of real visits
real_visits <- lapply(years, function(x) {
  res <- readxl::read_excel("pa_visits.xlsx",
                            sheet = x
  )
  res$year <- x
  return(res)
}) %>%
  data.table::rbindlist()

real_visits$pa_name <- gsub(x = glm_real_visits$name, "P.N.", "", fixed = T) %>%
  gsub(x = ., "R.N.", "", fixed = T) %>%
  gsub(x = ., "M.N.", "", fixed = T) %>%
  gsub(x = ., "PARQUE NACIONAL", "", fixed = T) %>%
  gsub(x = ., "7", "SIETE", fixed = T) %>%
  str_squish() %>%
  stringi::stri_trans_general(str = ., "Latin-ASCII")

#Save in SQLite database
send2sqlite(condb, "real_visits", tables = T)
