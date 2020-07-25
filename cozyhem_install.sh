#!/bin/bash
set -o xtrace

domain=$1
publicKey=$2

root_dir="$HOME/.cozyhem"
smartvpn_dir="$root_dir/smartvpn-client"
smartvpn_cred_file="$smartvpn_dir/credentials"

docker_dir="$root_dir/docker"
docker_profile="$docker_dir/cozyhem.profile"
dockercompose_file="$docker_dir/docker-compose.yaml"

cozyhem_dir="$root_dir/config"
cozyhem_config="$cozyhem_dir/home.yaml"

mkdir -p "$smartvpn_dir"
echo "USERNAME=$domain" > $smartvpn_cred_file 
echo "PUBLIC_KEY=$publicKey" >> $smartvpn_cred_file 

mkdir -p "$docker_dir"
touch "$docker_profile"

mkdir -p "$cozyhem_dir"
touch "$cozyhem_config"

cat > $dockercompose_file <<EOF
version: '3'
services:
  cozyhem-client:
    container_name: cozyhem-client
    restart: unless-stopped
    image: cozyhem/cozyhem-client
    volumes: 
      - $cozyhem_dir:/config
    environment:
      - TZ=America/Denver
    network_mode: host
    privileged: true

  smartvpn-client:
    container_name: smartvpn-client
    restart: unless-stopped
    image: cozyhem/smartvpn-client
    volumes:
      - $smartvpn_dir:/etc/wireguard
    network_mode: host
    environment:
      - TZ=America/Denver
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    user: 1000:1000

EOF

