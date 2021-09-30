#!/usr/bin/env bash

set -eo pipefail

# import the deployment helpers
. $(dirname $0)/common.sh

# Deploy.
OneFreeCouponAddr=$(deploy OneFreeCoupon)
log "OneFreeCoupon deployed at:" $OneFreeCouponAddr
