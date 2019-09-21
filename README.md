# Consul Connect Demo

An incredibly modified version of <thomashashi/thomas_cc_demo>

This repo can be used to show Consul service discovery, Consul Connect, intentions and service failover between datacenters (via prepared query)

## Demo Variants

- Single Region - located in `terraform/single-region-demo`
  - demonstrates: service discovery, Consul Connect, and intentions
- Multi Region - located in `terraform/multi-region-demo`
  - demonstrates: service discovery, Consul Connect, intentions and service failover between datacenters using a prepared query

## Architecture & Diagrams

- This is a simple three tier architecture
  - Front tier: `web_client` service
  - Middle tier: two services `listing` and `product`
  - Back tier: `MongoDB` service
  - [High Level Architecture](./diagrams/1-High-Level-Architecture.png)
- It deployed the following resources in each region:
  - [Deployed Services](./diagrams/2-Deployed-Services.png)
- Service Configuration:
  - [Consul Config Single DC](./diagrams/3-Consul-Config-Single-DC.png)
  - Front Tier to the Middle Tier communicates via Consul Connect
  - Middle Tier to Back Tier Communicates via Service Discovery only
    - Demo begins with Service Discovery by showing connections between Middle & Back Tier
- Multi Region Configuration:
  - [Consul Config Multi DC](./diagrams/4-Consul-Config-Multi-DC.png)

## Images

- Images are already published in `us-east-1`, `us-east-2`, `us-west-1` and `us-west-2`
- If you need to customize or publish your own images view the [Packer README](./packer/README.md)

## Setup

- switch to the directory for the desired demo variant
  - for single region: `cd terraform/single-region-demo`
  - for multi-region: `cd terraform/multi-region-demo`
- Make a copy of the example variables file
  - `cp terraform.auto.tfvars.example terraform.auto.tfvars`
- Edit `terraform.auto.tfvars` and set the following entries:
  - `project_name` = something which is unique and all lowercase letters/numbers/dashes
  - `hashi_tags` = `owner` sub-entry = your email alias
  - `aws_region` = region to deploy the primary Consul datacenter
  - `ssh_key_name` = name of the AWS EC2 ssh key in region
  - `top_level_domain` = top-level-domain to create in Route53 Zone
  - `route53_zone_id` = AWS Route53 Zone ID to use for DNS entries
  - `consul_dc` = `dc1` (unless a unique need to change)
  - `consul_lic` = Consul Enterprise License string
- The _multi-region-demo_ requires these additional entries:
  - `aws_region_alt` = region to deploy alternate datacenter
  - `consul_dc_alt` = `dc2` since this is alternate datacenter
  - `ssh_pri_key_file` = path to file containing private SSH key specified in `ssh_key_name`

Notes:

- The combination of `project_name` and `owner` **must be unique within your AWS organization**
- `ssh_key_name` - if deploying to multiple regions, this key must exist with the same name in both regions specified in `aws_region` and `aws_region_alt`
- The `ssh_pri_key_file` is used in a provisioning step to execute commands to join the Consul datacenters

## Demo Prep

- Deploy with Terraform
- Open the two web URL's in the terraform output (in a browser)
  - Consul UI
  - web-page rendered by `web_client` service
- Open the two ssh sessions listed in the terraform output (in seperate terminal tabs)
  - a connection to an instance hosting the `listing` service
  - a connection to an instance hosting the `web_client` service
- Verify the all services are running in Consul UI

## Demo Script

_will be updated with numbered shortcut-scripts soon_

### Consul Service Discovery - Listing to MongoDB

- We're going to review a service using Consul for Service Discovery
- Connect to a Listing API server
  - `terraform output listing_api_servers`
  - `ssh ubuntu@<first ip returned>`
- Display the **listing service** definition with command
  - `cat /lib/systemd/system/listing.service`
- The service calls references addresses for itself and mongoDB
  - Point out lines in file:
    - `Environment=DB_URL=mongodb.service.consul`
      `Environment=DB_PORT=27017`
    - tells `listing` service how to talk to the `mongodb` service
    - this is using service discovery
  - Show Querying Consul DNS:
    - `dig +short mongodb.service.consul srv`
    - `dig +short product.service.consul srv`
  - Consul resolves queries to addresses `XYZ.service.consul`
    - ex: `ping mongodb.service.consul`

#### Consul Service Discovery - Network traffic

- Network traffic between `listing` and `mongodb` services
- Dump all network packet data to `mongodb`:
  - `sudo tcpdump -A 'host mongodb.service.consul and port 27017 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
  - Traffic will stream immediately as the connection to mongodb is persistent
  - Watch the traffic and press `ctrl-c` after you see the database records displayed
  - Point out that the data including database credentials **is traversing network in plaintext**
  - Hit _Cntl-C_ to exit `tcpdump`
- **Summary:** `listing` is finding `mongodb` dynamically, but nothing is protecting the traffic

### Consul Connect

- Next review service using Consul Connect
- Connect to webclient server
  - `terraform output webclient_servers`
  - `ssh ubuntu@<first ip returned>`
- Display the **web_client service** definition again
  - `cat /lib/systemd/system/web_client.service`
- **web_client** also calls **product** API, but using with Consul Connect
  - Point out line in file:
    - `Environment=PRODUCT_URI=http://localhost:10001`
    - It's connecting to something on `localhost` **not** connecting across the network
      - this is using Consul Connect

#### Consul Connect - Configuration

- Explain connection between `web_client` and `product` services

  - describe `web_client` consul config

    - `cat /etc/consul/web_client.hcl`
    - Point out this stanza:

       ```js
       connect {
         sidecar_service = {
           proxy = {
             upstreams = [
               {
                 destination_name = "product"
                 local_bind_port = 10001
                 destination_type = "prepared_query"
               }
             ]
           }
         }
       }
       ```

  - This configures Consul to run a local proxy connecting local port `10001` to `product`

- `web_client.service` talks to `product` on `localhost` on port `10001`
  - Consul proxies localhost:10001 to `product` services AND encrypts the traffix
  - Limits un-encrypted traffic to calls betwen local system processes
- **Summary:** `web_client` is dynamically linking the `product` services AND traffic to the remote service (`product`) is encrypted

#### Consul Connect - Network traffic

- Show network traffic between between `web_client` and `product` services
  - We need to dump all packets to the `product` service, like we did above for the `listing` service
  - Query Consul DNS to get hostname and port of `product` services
    - Show Querying Consul DNS:
      - `dig +short product.connect.consul srv`
        - Query Consul DNS and capture vars for hostname & port:
            \-`dig +short product.connect.consul srv > .rec && HN=$(awk 'NR==1{print $4}' .rec | sed s/\.$//) && HP=$(awk 'NR==1{print $3}' .rec)`
        - Dump all network packet data to `product` service (using vars captured above):
          - `sudo tcpdump -A "host $HN and port $HP and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)"`
    - Go to the browser window, reload a few times
    - Return to terminal - point out all the traffic is TLS-encrypted gibberish
    - Hit _Cntl-C_ to exit `tcpdump`
- **Summary:** `web_client` is connecting to `product` services via Consul Connect and **all data is automatically TLS encrypted**

- End of WebClient
  - `exit` to close the SSH connection

### Consul Connect Summary

1.Point out that to connect `web_client` to to `product` via connect was

  1. Enable Connect
  2. Tell `web_client` that `product` service is reachable on localhost ports
  3. Consul Connect handles balancing traffic between 1, 2, 20, 100 healthy instances
  4. Consul Connect _encrypts_ all network traffic
  5. `web_client` knows _nothing_ about TLS
  6. `web_client` knows _nothing_ about mutual-TLS authentication
  7. `web_client` doesn't have to manage certificates, keys, CRLs, CA certs...
  8. `web_client` simply makes the same _simple, unencrypted requests_ it always has

2.Point out that by configuring `product` to listen only on `localhost`, you've reduced the security boundary to individual server instances --- all network traffic is _encrypted_

3.Point out that all you did to change a standard application was to configure Consul Connect and  _tell the app to listen only on localhost_
  1.`product` knows _nothing_ about TLS
  2.`product` knows _nothing_ about mutual-TLS authentication
  3.`product` doesn't have to manage certificates, keys, CRLs, CA certs...
  4.`product` simply sees _simple, unencrypted traffic_ coming to it

### Intentions

- Intentions can be defined via CLI or the Consul Web UI
  - If using the CLI, connect to `product` server

- Config Consul Connect to deny all traffic by default
  - `consul intention create -deny '*' '*'`
  - It cannot reach the `product` API by refreshing web browser
- Allow `web_client` to talk to `product`
  - `consul intention create -allow 'web_client' 'product'`
  - **Show it can now reach product API** by refreshing the web browser
- Delete ability of `web_client` to talk to `product`
  - `consul intention delete 'web_client' 'product'`
  - **Show product\` API is unreachable again** by refreshing the web browser
- Describe "Scalability of Intentions"
  - If you have 6 `web_client` instances, 17 `listing` instances and 23 `product` instances
    - you'd have `6 * 17 + 6 * 23 = 240` endpoint combinations to define
      - Those can be replaced with just _2_ intention definitions
    - Intentions follow the service
      - If you double the number of backends, you have to add _another_ 240 endpoint combinations
      - With Intentions, you do _nothing_ because intentions follow the service

### Configuration K/V - displayed on webclient UI

- On webclient UI, point out **Configuration** Section
  - the `product` service reads the Consul K/V store (along with the mongodb records)
  - data returns to `web_client` and displayed

### Multi-Region Demo (Only) - Failover with Prepared Queries

> Webclient service is configured to use a "prepared query" to find the `product` service.
> If every product service in the current DC fails, it looks for the service in other DCs

- Open `web_client` for DC1
  - point out **Configuration** Section
  - lists **datacenter = dc1** and the value of **test** set for DC1
- Trigger Failover
  - in the the Consul UI in DC1
  - on K/V tab, create a key called `run` in `product/` and set it to `false`
- switch to the services tab of the Consul UI in DC1
  - refresh and show the `product` servers slowly
  - keep refreshing until there is one health check failure for each `product` node in the DC (2 by default)
- switch back to `web_client` for DC1
  - point out **Configuration** Section
    - It's not showing **datacenter = dc2** and the value of **test** set for DC2
    - Consul has automatically used the `product` service in DC2
- (optional) review the Consul configuration that llowed the web client to do this

  - ssh into `web_client` in DC1
  - `cat /etc/consul/web_client.hcl`
  - Point out this stanza:

    ```js
    connect {
      sidecar_service = {
        proxy = {
          upstreams = [
            {
              destination_name = "product"
              local_bind_port = 10001
              destination_type = "prepared_query"
            }
          ]
        }
      }
    }
    ```
