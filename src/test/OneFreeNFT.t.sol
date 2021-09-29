// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./utils/OneFreeNFTTest.sol";

contract OneFreeMintTest is OneFreeNFTTest {
    function testMint() public {
        string memory coupon = "high five";
        uint256 tokenId = alice.mint(address(bob), coupon);

        assertEq(oneFreeNFT.ownerOf(tokenId), address(bob));
        assertEq(oneFreeNFT.couponGivers(tokenId), address(alice));
        assertEq(oneFreeNFT.coupons(tokenId), coupon);
    }
}
