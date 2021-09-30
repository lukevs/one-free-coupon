#!/usr/bin/env bash

set -eo pipefail

# bring up the network
. $(dirname $0)/run-temp-testnet.sh

# run the deploy script
. $(dirname $0)/deploy.sh

# get the address
addr=$(jq -r '.OneFreeCoupon' out/addresses.json)

# mint a coupon
seth send $addr \
    'mint(address,string memory)(uint256)' \
    '0x0000000000000000000000000000000000000001' \
     '"hug"' \
    --keystore $TMPDIR/8545/keystore \
    --password /dev/null

sleep 1

# coupon for token should be set to that value
coupon=$(seth call $addr 'coupons(uint256)(string)' 0)
[[ $coupon = "hug" ]] || error

echo "Success."
