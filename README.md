# Consul Demo

This repo can be used to show Consul service discovery, Consul Connect, intentions and service failover between datacenters (via prepared query)

## Demo Variants

- Single Region - located in `terraform/single-region-demo`
  - demonstrates: service discovery, Consul Connect, and intentions
- Multi Region - located in `terraform/multi-region-demo`
  - demonstrates: service discovery, Consul Connect, intentions and service failover between datacenters using a prepared query

## Architecture & Diagrams

- [Simple Three Tier Architecture](./diagrams/1-High-Level-Architecture-sm.png)
  - Front tier: `web_client` service
  - Middle tier: two services `listing` and `product`
  - Back tier: `MongoDB` service
- [Resources Deployed in each Region](./diagrams/2-Deployed-Services-sm.png)
- [Consul Configuration Single DC](./diagrams/3-Consul-Config-Single-DC-sm.png)
  - Front Tier to the Middle Tier communicates via Consul Connect
  - Middle Tier to Back Tier Communicates via Service Discovery only
    - Demo begins with Service Discovery by showing connections between Middle & Back Tier
    - Note: Intentions have no effect on the Back Tier, as it's not using Consul Connect
- [Multi Region Configuration](./diagrams/4-Consul-Config-Multi-DC-sm.png)

> A PowerPoint version and larger versions of these diagrams are included in the `./diagrams` directory

## Images

- Images are published in `us-east-1`, `us-east-2`, `us-west-1` and `us-west-2`
- If customizing images:
  - View the [Packer README](./packer/README.md)
  - Change the AMI name to avoid name conflict with original
    - set `AMI_PREFIX` value in `packer/Makefile`
    - set `ami_prefix` terraform variable in `terraform.auto.tfvars`
  - change `AMI_OWNER` value to your AWS organization ID

## Setup

- switch to the directory for the desired demo variant
  - for single region: `cd terraform/single-region-demo`
  - for multi-region: `cd terraform/multi-region-demo`
- Make a copy of the example variables file
  - `cp terraform.auto.tfvars.example terraform.auto.tfvars`
- Edit `terraform.auto.tfvars` and set the entries as described by the comments

Notes for multi-region demo:

> This demo is simplified if you push your system's default ssh key (`~/.ssh/id_rsa.pub`) to the AWS regions used with this demo.

- `reference/push-ssh-key-to-aws.sh` pushes an SSH key of your chosing to every region using the AWS CLI
  - edit the value of `aws_keypair_name` and `publickeyfile` in the script

> The multi-region terraform code, uses a post provisioner which requires specifying the AWS ssh key name & the content of the private key (via file reference or as a string)

- `ssh_key_name` - must exist with this name in both regions (by default us-west-2 and us-east-1)
- Must specify either `ssh_pri_key_data` or `ssh_pri_key_file` so that they refer to the Private SSH key for the key specified in `ssh_key_name`
  - `ssh_pri_key_file` - File URL to private key file (does not work with TFC/TFE)
  - `ssh_pri_key_data` - contents of private key as data with newlines replaced with `\n` (required for TFC/TFE)
    - remove newlines with command: `awk '{printf "%s\\n", $0}' ~/.ssh/id_rsa`

## Demo Prep

- Deploy with Terraform (takes 3-4 minutes)
- Following instruction in terraform output section `working connections`
  - Open two URL's in Browser for
    - web-page rendered by `web_client` service
    - Consul UI
  - keep Terraform Output visible by making connection in other Terminal tabs
- Edit `~/.ssh/known_hosts` and remove entries from previous demos
- Verify the all services are running in Consul UI

## Demo Script

- Show *High Level Architecture* diagram

> Explain the three tiers and communications between the services.
> We are going to start by discussing Service Discovery and Service Registration

### Consul Service Discovery

> In order for services to be discoverable via Consul, they first must register themselves.

#### Service Regitration

- open new terminal tab & connect to `MongoDB` instance
  - use connection string in terraform output `working connections`

> This instance's Consul client publishes all the services running on it to Consul.
> In this demo, MongoDB is the only service on this host, so let's review it's config.

- run `./1-cat-cons-config.sh` to display `MongoDB` service configuration

> Explain service config & health check basics.
> Consul uses this infomation to build a Service Catalog.
> Consul monitors healthchecks to insure only healthy services listed in catalog.

- (optional) - show service tab on Consul UI, select MondoDB & show service checks
- you can `exit` the ssh connection to `MongoDB` instance

#### Service Discovery

> Once services are registered, other services can easily discover them.
> Let's show how the listing service connects to MongoDB.

- open new terminal tab & connect to `listing` instance
  - use connection string in terraform output `working connections`

> The listing service is written in NodeJS and isn't Consul aware.
> It reads the environment variables DB_URL to get MongoDB servers address.

- run `./1-cat-system.sh` to show listing service systemd configuration

> It's systemd config set DB_URL Environment Var to mongodb.service.consul.

- run `./2-dig.sh` to show a dns query using dig for all mongodb services

> Consul automatically resolves service names via DNS to an IP where mongodb is running.
> Dig queries Consul via DNS and returns healthy mongodb service.

- (optional) ping the mongodb service: `ping mongodb.service.consul`
- (optional) list product services using dig: `dig +short product.service.consul srv`
- (optional) list services registered with Consul: `consul catalog services`

#### Service Discovery - Network traffic

> Service discovery allows service to easily discover and connect to other services.
> But Network traffic is unencrypted unless services coded with encryption.

- run `./3-nw-traffic.sh` to show network traffic between `listing` and `mongodb`
  - Traffic will stream immediately as the connection to mongodb is persistent
  - Watch the traffic and press `ctrl-c` after you see the database records displayed

> Point out that the data including db creds is traversing network in plaintext.

- Hit _Cntl-C_ to exit network traffic dump
- you can `exit` the ssh connection to `listing` instance

### Consul Connect

> Next we're going to talk about Consul Connect and some of the enhancements it brings.

- Show *Consul Config Single DC* diagram

> You'll notice that the Front Tier and Middle tier have sidecar-proxies.
> They are configured to communicate using Consul Connect.
> The Back Tier is configured to only use Service Discovery.

- open new terminal tab & connect to `webclient` instance
  - use connection string in terraform output `working connections`

#### Consul Connect - Configuration

> In the diagram, webclient communicates with listing & product services.
> Let's show how the webclient service is configured.

- run `./1-cat-system.sh` to show webclient service systemd configuration

> Systemd config sets Environment Vars for listing & product to localhost @ unique ports.
> So how are these local ports re-directed to the proper serices? via the proxy.

- run `./2-cat-cons-config.sh` to display `webclient` service configuration

> Describe the connect-sidecar service block.
> Upstream connections bind a local port to services in Consul.
> This configures Consul to run a local proxy connecting local port `10001` to `product`.
> Consul proxies localhost:10001 to `product` services AND encrypts the traffic.
> Consul proxies localhost:10002 to `listing` services AND encrypts the traffic.
> note: product uses "prepared query" to enable failover to other datacenters.

- run `./3-dig.sh` to show a dns query using dig for all product services
- (optional) list listing services using dig: `dig +short listing.service.consul srv`

> Like earlier, this host resolves service names to an IP where product is running.
> Notice, here we search on servicename.CONNECT.consul instead of .SERVICE.consul.
> this limits our results to services using Consul Connect.

- (optional) query mongoDB service using connect `dig +short mongodb.connect.consul srv`

> Nothing returned as no MongoDB services are configured for connect (refer to diagram if necessary).

#### Consul Connect - Network traffic

> The sidecar proxies used in Consul Connect use TLS to encrypt communications.

- run `./4-nw-traffic.sh` to show network traffic between `listing` and `mongodb`
- wait or refresh the web_client web-page to see network trafic

> As we can see, the network traffic is not TLS encrypted gibberish.

- Hit _Cntl-C_ to exit network traffic dump

- you can `exit` the ssh connection to `webclient` instance

#### Consul Connect Summary

> Steps required to configure `web_client` to talk to `product` via connect

  1. Enable Connect
  2. Tell `web_client` that `product` service is reachable on localhost ports
  3. Consul Connect handles balancing traffic between 1, 2, 20, 100 healthy instances
  4. Consul Connect _encrypts_ all network traffic
  5. `web_client` knows _nothing_ about TLS
  6. `web_client` knows _nothing_ about mutual-TLS authentication
  7. `web_client` doesn't have to manage certificates, keys, CRLs, CA certs...
  8. `web_client` simply makes the same _simple, unencrypted requests_ it always has

> By configuring `product` to listen only on `localhost`, you've reduced the security boundary to individual server instances --- all network traffic is _encrypted_.
> Only steps necessary to enable existing application to configure Consul Connect and  _configure app to communicate to port on localhost_.

  1. `product` knows _nothing_ about TLS
  2. `product` knows _nothing_ about mutual-TLS authentication
  3. `product` doesn't have to manage certificates, keys, CRLs, CA certs...
  4. `product` simply sees _simple, unencrypted traffic_ coming to it

#### Intentions

> Intention enable defining specific services that each service can communicate.

- Show Web Client web page, and point out its communicating with Listing & Product

> now we'll stop all services (using Consul connect) from communicating.

- Open Consul UI and select Intentions tab
  - Create an Intention from `*` to `*` of type `Deny` and click save
- Show Web Client web page and point out it cannot communicate with Listing or Product services

> lets allow web_client to communicate with the listing service.

- Switch back to Consul Intentions UI
  - Create Intention from `web_client` to `listing` of type `Allow` and click save
- Show Web Client web page and point out it can now communicate with Listing

> Intentions also specifying the service that can initiate communications.

- Switch back to Consul Intentions UI
  - Create Intention from `product` to `web_client` of type `Allow` and click save
- Show Web Client web page and point out the it still cannot communicate with product

> Now the web_client still cannot talk to product, beccause the intention we added allows product to initiate connections to web_client (not the other way arround).
> So, lets add a connection that allows web_client to initiate communications with product.

- Switch back to Consul Intentions UI
  - Create Intention from `web_client` to `product` of type `Allow` and click save
- Show Web Client web page and point out both working again

> Describe "Scalability of Intentions".
> If you have 6 `web_client` instances, 17 `listing` instances and 23 `product` instances; you'd have `6 * 17 + 6 * 23 = 240` endpoint combinations to define.
> Those can be replaced with just _2_ intention definitions.
> Another example: If you double the number of backends, you have to add _another_ 240 endpoint combinations.
> With Intentions, you do _nothing_ because intentions follow the service.

### Configuration K/V - displayed on webclient UI

- Show Web Client web page, point out **Configuration** Section
  - the `product` service reads the Consul K/V store (along with the mongodb records)
  - data returns to `web_client` and displayed

### Datacenter Failover with Prepared Queries - Multi-Region Demo (Only)

> Webclient service is configured to use a "prepared query" to find the `product` service.  If every product service in the current DC fails, it looks for the service in other DCs.  Additional info on the prepared query can be found in the [prepared_query reference](./reference/prepared_query.md)

- Show Web Client web page
  - point out **Configuration** Section under Product API
  - shows **datacenter = dc1**

> Now we're going to trigger a fail of the product service in this datacenter.

- Open Consul UI and select Key/Value tab (make sure it's in dc1)
  - Click on folder neamed `product` then value named `run`
  - Change value from `true` to `false`
- Switch to the Consul UI services & refresh to see `product` services fail
  - keep refreshing until all nodes have failed

> Now that the service has failed, let see view the webpage.

- Show Web Client web page
  - point out **Configuration** Section under Product API
  - now shows **datacenter = dc2**, as the instance responding is in DC2

#### Optional Failover Drilldown

- ssh into any one of the previous servers (in DC1)
- type `dig +short product.connect.consul srv`
  - no product services are available in this DC
- type `dig +short product.query.consul srv`
  - but by searchign the prepared query (as the web_client is doing) shows services in the other datacenter
- disable the failover by setting the `product/run` key back to `true`
  - wait for the services to become active again in DC1
  - type `dig +short product.query.consul srv` and show how he results have changed back to this DC
  - type `dig +short product.connect.consul srv` - shows the same results as the query, as all the services in this DC are working
