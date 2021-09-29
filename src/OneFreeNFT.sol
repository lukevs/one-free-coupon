// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OneFreeNFT is ERC721("OneFreeNFT", "OF") {
    enum CouponStatus{ UNUSED, REDEEM_REQUESTED, USED }

    uint256 private _tokenIdCounter = 0;

    mapping(uint256 => string) public coupons;
    mapping(uint256 => address) public couponGivers;
    mapping(uint256 => CouponStatus) public couponStatus;

    function mint(address to, string memory coupon) external returns (uint256) {
      uint256 tokenId = _tokenIdCounter;
      coupons[tokenId] = coupon;
      couponGivers[tokenId] = msg.sender;

      _tokenIdCounter += 1;

      bytes memory data = abi.encodePacked(msg.sender, coupon);
      _safeMint(to, tokenId, data);

      return tokenId;
    }

    function redeem(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "OneFreeNFT: you don't own this coupon");
        require(couponStatus[tokenId] == CouponStatus.UNUSED);

        couponStatus[tokenId] = CouponStatus.REDEEM_REQUESTED;
    }

    function grant(uint256 tokenId) external {
        require(couponGivers[tokenId] == msg.sender, "OneFreeNFT: you didn't give this coupon");
        require(couponStatus[tokenId] == CouponStatus.REDEEM_REQUESTED);

        couponStatus[tokenId] = CouponStatus.USED;
        _burn(tokenId);
    }
}
