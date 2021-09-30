#!/usr/bin/env bash

set -eo pipefail

# import the deployment helpers
. $(dirname $0)/common.sh

# Deploy.
OneFreeCouponAddr=$(deploy OneFreeCoupon '0x084b1c3c81545d370f3634392de611caabff8148')
log "OneFreeCoupon deployed at:" $OneFreeCouponAddr
