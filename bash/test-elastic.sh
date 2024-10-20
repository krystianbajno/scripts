curl -X POST "http://localhost:9200/scrapes_chunks/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "content": "example"
    }
  }
}
'
