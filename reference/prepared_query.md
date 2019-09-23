# Prepared Query Information

The prepared query used to discover the product service is listed below.  It's configured in Consul by the Terraform code using the Consul provider.

```json
{
  "Name": "product",
  "Service": {
    "Service": "product",
    "Failover": {
       "Datacenters": ["dc2", "dc1"]
    },
    "OnlyPassing": true,
    "Connect": true
  }
}
```

To write this prepared query manually:

- Write the json code listed above to the file `prepared.json`
- Write Prepared Query to Consul using the API (connect to a Consul Server)
  - `curl --request POST --data @prepared.json http://127.0.0.1:8500/v1/query`

Example Consul API commands for prepared queries:

- List Prepared Queries
  - `curl http://127.0.0.1:8500/v1/query`
- Get ID of first Query
  - `UUID=$(curl -s http://127.0.0.1:8500/v1/query | jq -r .[0].ID)`
- remove Query
  - `curl --request DELETE "http://127.0.0.1:8500/v1/query/$UUID"`
