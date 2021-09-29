// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

contract OneFreeNFT is ERC721("OneFreeNFT", "OF") {
    enum CouponStatus {
        UNUSED,
        REDEEM_REQUESTED,
        USED
    }

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
        require(
            ownerOf(tokenId) == msg.sender,
            "OneFreeNFT: you don't own this coupon"
        );
        require(couponStatus[tokenId] == CouponStatus.UNUSED);

        couponStatus[tokenId] = CouponStatus.REDEEM_REQUESTED;
    }

    function grant(uint256 tokenId) external {
        require(
            couponGivers[tokenId] == msg.sender,
            "OneFreeNFT: you didn't give this coupon"
        );
        require(couponStatus[tokenId] == CouponStatus.REDEEM_REQUESTED);

        couponStatus[tokenId] = CouponStatus.USED;
        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string[5] memory parts;

        parts[0] = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'> <style> .base { fill: black; font-family: Comic Sans MS, Comic Sans, cursive; font-size: 14px; } .red { fill: red } </style> <rect width='100%' height='100%' fill='white' /><text x='10' y='20' class='base'>1 free coupon for</text><text x='10' y='40' class='base red'>";

        parts[1] = coupons[tokenId];

        parts[2] = "</text><text x='10' y='80' class='base'>from</text><text x='10' y='100' class='base'>0x";

        parts[3] = toAsciiString(ownerOf(tokenId));

        parts[4] = "</text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4])
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Coupon #',
                        Strings.toString(tokenId),
                        '", "description": "1 free coupon for ',
                        coupons[tokenId],
                        '", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    // from https://ethereum.stackexchange.com/a/8447
    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
