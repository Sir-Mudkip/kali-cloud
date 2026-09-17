#!/usr/bin/env bash

set -eoux pipefail

source /build/helper_functions

# Docker / container-registry and IaC static-analysis tooling. The kics IaC
# scanner is a Go tool built in the builder stage (build/00-go-installs.sh) and
# pulled in via COPY --from=builder.

# checkov
pipx install checkov

# grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# regctl
REGCTL_VERSION=$(curl_latest_release regclient/regclient)
wget2 -q "https://github.com/regclient/regclient/releases/download/${REGCTL_VERSION}/regctl-linux-amd64" -O /opt/regctl
install -o root -g root -m 0755 /opt/regctl /usr/local/bin/regctl
rm /opt/regctl
