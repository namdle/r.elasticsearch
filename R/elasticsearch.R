


es.search.scroll <- function(es.hostname="http://locahost:9200",
                             es.index.names,
                             es.query,
                             es.scroll.size=100,
                             es.scroll.time="5m",
                             es.limit = 0,
                             transform.es.f = function(es.result) return(es.result)) {

  ch <- RCurl::getCurlHandle()
  url <- paste(es.hostname, es.index.names,
               paste("_search?fields&search_type=scan&", "scroll=", es.scroll.time, "&size=", es.scroll.size,sep=""),
               sep="/")

  message(paste("Query Elasticsearch", url))

  es.http.response <- RCurl::getForm(url, style='post', .opts = list(postfields=es.query), curl=ch)
  es.result <- jsonlite::fromJSON(es.http.response)

  if (!is.null(es.result$error)) {
    stop(es.result$error)
  }

  total <- es.result$hits$total
  message(paste("Total results=", total))

  # start scrolling thru results
  hits.all <- NULL
  repeat {
    es.scroll.id <- es.result[["_scroll_id"]]
    url <- paste(es.hostname, "_search",
                 paste("scroll?scroll=", es.scroll.time, "&scroll_id=", es.scroll.id, sep=""),
                 sep="/")

    es.http.response <- RCurl::getURL(url, curl=ch, .encoding="UTF-8", .mapUnicode=FALSE)

    tryCatch( {
      #print(substr(es.http.response, nchar(es.http.response)-200, nchar(es.http.response)))
      es.result <- jsonlite::fromJSON(es.http.response)

      if (length(es.result$hits$hits) == 0) {
        break()
      }

      hits <- transform.es.f(es.result)
      hits.all <- rbindlist(list(hits.all, hits), fill=TRUE)

      message(paste("Retrieved", nrow(es.result$hits$hits), ". Total:", nrow(hits.all)))

    }, error = function(c) {
      message(paste("Failed to parse ES results:", c))
    })

    if (es.limit > 0 & nrow(hits.all) > es.limit)
       break()
  }

  return(hits.all)
}

es.search <- function(es.hostname="http://locahost:9200",
                      es.index.names,
                      es.index.type,
                      es.params,
                      es.query) {

  ch <- RCurl::getCurlHandle()
  if (missing(es.index.type)) {
    url <- paste(es.hostname, es.index.names, "_search", sep="/")
  }
  else {
    url <- paste(es.hostname, es.index.names, es.index.type, "_search", sep="/")
  }

  message(paste("Query Elasticsearch", url))

  es.http.response <- RCurl::getForm(url, style='post', .opts = list(postfields=es.query), .params=es.params, curl=ch)
  es.result <- jsonlite::fromJSON(es.http.response)

  return (es.result)
}
