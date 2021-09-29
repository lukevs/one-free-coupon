#!/usr/bin/env bash

set -eo pipefail

# import the deployment helpers
. $(dirname $0)/common.sh

# Deploy.
OneFreeNFTAddr=$(deploy OneFreeNFT)
log "OneFreeNFT deployed at:" $OneFreeNFTAddr
