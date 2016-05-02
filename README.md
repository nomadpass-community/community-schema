### Nomad Pass API

The API server uses [PostgREST](http://postgrest.com).

The Geolocation API endpoint uses data populated from [this
dataset](https://s3-ap-southeast-1.amazonaws.com/nomadpass/IP2LOCATION-LITE-DB5.CSV.gz)

#### Set up development environment

This schema requires Postgis. (On mac `brew install postgis`).

To deploy with [sqitch](http://sqitch.org/):

```bash
createuser nomad
createdb nomad_dev -O nomad
sqitch deploy db:pg:nomad_dev
```

Add GeoIP data from S3:

```bash
curl -L https://s3-ap-southeast-1.amazonaws.com/nomadpass/IP2LOCATION-LITE-DB5.CSV.gz | gunzip > geo.csv
psql -d nomad_dev -c "\\COPY internal.ip2location_db5 FROM 'geo.csv' WITH CSV QUOTE AS '\"';"
```

#### Running the dev API server

```bash
brew install postgrest
postgrest postgres://nomad:@localhost:5432/nomad_dev \
  --schema v1 --anonymous nomad
```
