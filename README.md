# R Elasticsearch

Simple R script to query from Elasticsearch API

## Installation

Install directly from the source package:


Install the [devtools](https://github.com/hadley/devtools) package:

	install.packages("devtools")
	library(devtools)

And then run the `install_github` command:

	install_github("namdle/r.elasticsearch")
	library(r.elasticsearch)


#### Basic use

Using the scroll API:

	hits.all <- es.search.scroll(es.hostname="http://localhost:9200", 
                             es.index.names="logstash-2014.11.10",
                             es.scroll.size=2000, 
                             es.scroll.time="10m",
                             es.limit=0,
                             es.query='{
                              "query": {
                                "filtered": {
                                  "filter": {
                                    "bool": {
                                      "must": [
                                        {
                                          "term": {
                                            "user": "namdle"
                                          }
                                        },
                                        {
                                          "term": {
                                            "is_employee": "false"
                                          }
                                        }
                                      ]
                                    }
                                  }
                                }
                              }
                             }')             

