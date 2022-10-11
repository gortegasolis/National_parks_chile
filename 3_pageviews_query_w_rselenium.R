# Set download folder
dwn_fold <- list(chromeOptions = list(prefs = list(
  "download.default_directory" = paste0(getwd(), "/chrome_downloads")
)))

# Load browser driver and start server
rD <- rsDriver(browser = "chrome", chromever = "96.0.4664.45", verbose = T, extraCapabilities = dwn_fold)
remDr <- rD[["client"]]

# Define function "get_csv"
get_csv <- function() {
  Sys.sleep(10)
  webElem <- remDr$findElement("class", "download-btn-group")
  webElem$clickElement()
  Sys.sleep(2)
  webElem <- remDr$findElement("class", "download-csv")
  webElem$clickElement()
  Sys.sleep(10)
}

# Loop to download data
pageviews_data <- foreach(x = 1:NROW(metadata_df), .errorhandling = "pass") %do% {
  base_url <- metadata_df$base_url[x]
  wiki_name <- metadata_df$wiki_page_name[x]

  # Navigate
  remDr$navigate(paste0("https://pageviews.toolforge.org/langviews/?project=", base_url, "&platform=all-access&agent=user&start=2016-01-01&end=2021-01-01&sort=views&direction=1&view=list&page=", wiki_name))

  Sys.sleep(20)

  # Get main data table and links
  webElem <- remDr$findElement("class", "output-table")

  main_table <- webElem$getPageSource()[[1]] %>%
    read_html() %>%
    html_table()

  main_table <- main_table[[1]][-1, ]
  main_table$wiki_name <- wiki_name

  links <- webElem$getPageSource()[[1]] %>%
    read_html() %>%
    html_elements("table") %>%
    html_elements("tbody") %>%
    html_elements("tr") %>%
    html_elements(., xpath = "td[4]") %>%
    html_elements("a") %>%
    html_attr("href") %>%
    gsub("/pageviews", "https://pageviews.toolforge.org/pageviews/", x = .)

  # Get csv
  num <- 0
  lapply(links, function(x) {
    remDr$navigate(x)
    get_csv()
    while (file.exists(paste0("chrome_downloads/", wiki_name, num))) {
      num <- num + 1
    }
    system(paste0("mv chrome_downloads/pageviews* chrome_downloads/", wiki_name, num))
  })
  return(main_table)
}

# Stop selenium server
remDr$close
rD$server$stop()

# Import and check pageviews data
pageviews_df <- data.table::rbindlist(pageviews_data)%>%
  mutate(title = stri_trans_general(`Page title`, 'latin-ascii')) # Check langviews info

#Get wiki creation date
wiki_creation <- lapply(1:NROW(pageviews_df), function(x){
  print(pageviews_df$`Page title`[x])
  url <- paste0("https://",
                pageviews_df$Language[x],
                ".wikipedia.org/w/api.php?action=query&prop=revisions&rvlimit=1&rvprop=timestamp&rvdir=newer&format=json&titles=",
                pageviews_df$title[x])
  
  res <- tryCatch({jsonlite::fromJSON(url)[["query"]][["pages"]][1] %>% 
    unlist2d() %>% 
    mutate(value = coalesce(V1, timestamp)) %>%
    dplyr::select(.id.2, value) %>%
    pivot_wider(names_from = .id.2, values_from = value)},
    error = function(e) NA)
  return(res)
})

wiki_creation_df <- wiki_creation[!is.na(wiki_creation)] %>% 
  data.table::rbindlist()  %>%
  left_join(pageviews_df,., by = c("title" = "title")) %>%
  mutate(creat_year = substr(revisions, 1,4) %>% as.numeric()) %>%
  dplyr::select(wiki_name, creat_year) %>%
  group_by(wiki_name) %>%
  slice_min(order_by = creat_year, n = 1) %>%
  unique()
