#!/usr/bin/env bash

set -eoux pipefail

# Multi-cloud tooling: each tool covers more than one cloud provider (AWS, Azure,
# Kubernetes, OCI, etc.). gcloud / GCP tooling is intentionally omitted.

# prowler (AWS, Azure, Kubernetes)
pipx install prowler

# cloud_enum (AWS, Azure)
pipx install git+https://github.com/initstring/cloud_enum

# cloudsploit (AWS, Azure, OCI, GitHub)
git clone --depth 1 "http://github.com/aquasecurity/cloudsploit.git" /opt/cloudsploit
cd /opt/cloudsploit
npm install --omit=dev
npm cache clean --force
chmod +x /opt/cloudsploit/index.js
