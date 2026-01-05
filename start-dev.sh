#!/usr/bin/env bash

mkdir -p config

vault server -dev -dev-root-token-id root -dev-tls -dev-tls-san=host.docker.internal -dev-cluster-json="config/cluster.json" -dev-listen-address=0.0.0.0:8200
