#!/bin/bash

apt-get -yq update
apt-get install -yq \
    ca-certificates \
    curl \
    ntp \
    wireguard

# Store Droplet ID in variable (utilises DO's Metadata Service - https://developers.digitalocean.com/documentation/metadata/)
DROPLET_ID=$(curl -s http://169.254.169.254/metadata/v1/id)

# k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${k3s_channel} K3S_TOKEN=${k3s_token} sh -s - server \
    --datastore-endpoint="${db_cluster_uri}" \
    ${critical_taint}
    --kubelet-arg "provider-id=digitalocean://$DROPLET_ID" \
    --flannel-backend=${flannel_backend} \
    --flannel-iface=eth1 \
    --disable local-storage \
    --disable-cloud-controller \
    ${enable_traefik}
    --disable servicelb \
    --kubelet-arg 'cloud-provider=external'