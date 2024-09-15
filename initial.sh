#!/bin/bash #
#
# Install curl #
apk add curl #
#
# Get API key from environment variable
API_KEY=${API_KEY} #
#
# Download GTFS file and OSM file
GTFS_URL="https://api-challenge2024.odpt.org/api/v4/files/JR-East/data/JR-East-Train-GTFS.zip?acl:consumerKey=$API_KEY" #
OSM_URL="https://download.geofabrik.de/asia/japan/kanto-latest.osm.pbf" #
#
# Doownload GTFS data
if [ ! -f ./otp/gtfs.zip ]; then #
  echo "Download URL: $GTFS_URL" #
  curl -L $GTFS_URL -o ./otp/gtfs.zip #
  echo "Downloaded GTFS data." #
else #
  echo "GTFS data already exists." #
fi #
#
# Download OSM data
if [ ! -f ./otp/osm.pbf ]; then #
  echo "Download OSM data..." #
  curl -L $OSM_URL -o ./otp/osm.pbf #
  echo "Downloaded OSM data." #
else #
  echo "OSM data already exists." #
fi #
#
# Replace [Access_Token_for_Challenge2024] in router-config.template.json with API key and create a new file
sed 's/\[Access_Token_for_Challenge2024\]/'"$API_KEY"'/g' ./otp/router-config.template.json > ./otp/router-config.json #
#
echo "API key has been embedded in the configuration file." #
#