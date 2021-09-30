// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./utils/OneFreeCouponTest.sol";

contract OneFreeMintTest is OneFreeCouponTest {
    function testMint() public {
        string memory coupon = "high five";
        uint256 tokenId = alice.mint(address(bob), coupon);

        assertEq(oneFreeNFT.ownerOf(tokenId), address(bob));
        assertEq(oneFreeNFT.couponGivers(tokenId), address(alice));
        assertEq(oneFreeNFT.coupons(tokenId), coupon);
    }

    function testRedeem() public {
        string memory coupon = "high five";
        uint256 tokenId = alice.mint(address(bob), coupon);

        assertCouponStatusEq(
            oneFreeNFT.couponStatus(tokenId),
            OneFreeCoupon.CouponStatus.UNUSED
        );

        bob.redeem(tokenId);
        assertCouponStatusEq(
            oneFreeNFT.couponStatus(tokenId),
            OneFreeCoupon.CouponStatus.REDEEM_REQUESTED
        );

        alice.grant(tokenId);
        assertCouponStatusEq(
            oneFreeNFT.couponStatus(tokenId),
            OneFreeCoupon.CouponStatus.USED
        );
    }

    function assertCouponStatusEq(
        OneFreeCoupon.CouponStatus firstStatus,
        OneFreeCoupon.CouponStatus secondStatus
    ) private {
        assertEq(uint256(firstStatus), uint256(secondStatus));
    }
}
