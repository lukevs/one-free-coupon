// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OneFreeNFT is ERC721("OneFreeNFT", "OF") {
    uint256 private _tokenIdCounter = 0;

    mapping(uint256 => string) public coupons;
    mapping(uint256 => address) public couponGivers;

    function mint(address to, string memory coupon) external returns (uint256) {
      uint256 tokenId = _tokenIdCounter;
      coupons[tokenId] = coupon;
      couponGivers[tokenId] = msg.sender;

      _tokenIdCounter += 1;

      bytes memory data = abi.encodePacked(msg.sender, coupon);
      _safeMint(to, tokenId, data);

      return tokenId;
    }
}
