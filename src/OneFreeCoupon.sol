// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

interface IDefaultResolver {
    function name(bytes32 node) external view returns (string memory);
}

interface IReverseRegistrar {
    function node(address addr) external view returns (bytes32);
    function defaultResolver() external view returns (IDefaultResolver);
}

contract OneFreeCoupon is ERC721("OneFreeCoupon", "OFC") {
    enum CouponStatus {
        UNUSED,
        REDEEM_REQUESTED,
        USED
    }

    IReverseRegistrar ensReverseRegistrar;

    uint256 private _tokenIdCounter = 0;

    mapping(uint256 => string) public coupons;
    mapping(uint256 => address) public couponGivers;
    mapping(uint256 => CouponStatus) public couponStatus;

    constructor(address ensReverseRegistrar_) {
        ensReverseRegistrar = IReverseRegistrar(ensReverseRegistrar_);
    }

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
            "OneFreeCoupon: you don't own this coupon"
        );
        require(
            couponStatus[tokenId] == CouponStatus.UNUSED,
            "OneFreeCoupon: token must be unused"
        );

        couponStatus[tokenId] = CouponStatus.REDEEM_REQUESTED;
    }

    function grant(uint256 tokenId) external {
        require(
            couponGivers[tokenId] == msg.sender,
            "OneFreeCoupon: you didn't give this coupon"
        );
        require(
            couponStatus[tokenId] == CouponStatus.REDEEM_REQUESTED,
            "OneFreeCoupon: token hasn't been redeemed"
        );

        couponStatus[tokenId] = CouponStatus.USED;
        _burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        address couponGiver = couponGivers[tokenId];
        string memory couponGiverName = lookupENSName(couponGiver);

        if (bytes(couponGiverName).length == 0) {
            couponGiverName = toAsciiString(couponGiver);
        }

        require(_exists(tokenId), "OneFreeCoupon: token id doesn't exist");
        return buildTokenURI(tokenId, coupons[tokenId], couponGiverName);
    }

    function buildTokenURI(uint256 tokenId, string memory coupon, string memory couponGiverName)
        public
        pure
        returns (string memory)
    {
        string[5] memory parts;

        parts[
            0
        ] = "<svg xmlns='http://www.w3.org/2000/svg' width='792' height='612' fill='none' xmlns:v='https://vecta.io/nano'><path fill='#fff' d='M0 0h792v612H0z'/><path d='M684.877 292.381a49.79 49.79 0 0 0-1.669 9.027l-2.49-.226L680.5 306l.218 4.818 2.49-.226a49.79 49.79 0 0 0 1.669 9.027l-2.406.68a52.29 52.29 0 0 0 3.468 8.997l2.24-1.111a50.03 50.03 0 0 0 4.817 7.815l-1.999 1.501c1.935 2.576 4.101 4.968 6.468 7.145l1.692-1.84c2.252 2.071 4.694 3.939 7.297 5.573l-1.329 2.117c2.71 1.702 5.587 3.162 8.602 4.353l.918-2.326a49.62 49.62 0 0 0 8.814 2.568l-.474 2.454 4.775.697a3.24 3.24 0 0 1 1.076.298l1.073-2.258c1.216.578 2.193 1.567 2.703 2.785l-2.306.966a2.49 2.49 0 0 1 .194.967v5h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v5c0 .344-.068.665-.189.956l2.31.958a5.02 5.02 0 0 1-2.707 2.707l-.958-2.31c-.291.121-.612.189-.956.189h-5.038v2.5h-10.076v-2.5H702.81v2.5h-10.076v-2.5h-10.075v2.5h-10.076v-2.5h-10.076v2.5h-10.076v-2.5h-10.075v2.5H632.28v-2.5h-10.076v2.5h-10.076v-2.5h-10.075v2.5h-10.076v-2.5h-10.076v2.5h-10.075v-2.5H561.75v2.5h-10.076v-2.5h-10.076v2.5h-10.076v-2.5h-10.075v2.5h-10.076v-2.5h-10.076v2.5H491.22v-2.5h-10.076v2.5h-10.076v-2.5h-10.076v2.5h-10.075v-2.5h-10.076v2.5h-10.076v-2.5h-10.076v2.5h-10.075v-2.5h-10.076v2.5h-10.076v-2.5h-10.076v2.5h-10.075v-2.5h-10.076v2.5h-10.076v-2.5h-10.076v2.5h-10.075v-2.5h-10.076v2.5h-10.076v-2.5H299.78v2.5h-10.075v-2.5h-10.076v2.5h-10.076v-2.5h-10.076v2.5h-10.075v-2.5h-10.076v2.5H229.25v-2.5h-10.076v2.5h-10.075v-2.5h-10.076v2.5h-10.076v-2.5h-10.076v2.5h-10.076v-2.5H158.72v2.5h-10.076v-2.5h-10.076v2.5h-10.076v-2.5h-10.075v2.5h-10.076v-2.5H98.265v2.5H88.189v-2.5H78.114v2.5H68.038v-2.5H63a2.48 2.48 0 0 1-.956-.189l-.958 2.31a5.02 5.02 0 0 1-2.707-2.707l2.309-.958A2.48 2.48 0 0 1 60.5 501v-5H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-5a2.49 2.49 0 0 1 .194-.967l-2.306-.966c.511-1.218 1.487-2.207 2.703-2.785l1.073 2.258c.331-.157.695-.261 1.076-.298l4.775-.697-.474-2.454c3.046-.589 5.993-1.453 8.814-2.568l.918 2.326c3.015-1.191 5.892-2.651 8.603-4.353l-1.329-2.117a50.21 50.21 0 0 0 7.296-5.573l1.693 1.84a52.81 52.81 0 0 0 6.468-7.145L98.004 336a49.98 49.98 0 0 0 4.817-7.815l2.24 1.111a52.29 52.29 0 0 0 3.468-8.997l-2.406-.68a49.79 49.79 0 0 0 1.669-9.027l2.49.226.218-4.818-.218-4.818-2.49.226a49.79 49.79 0 0 0-1.669-9.027l2.406-.68a52.29 52.29 0 0 0-3.468-8.997l-2.24 1.111A49.98 49.98 0 0 0 98.004 276l1.999-1.501a52.81 52.81 0 0 0-6.468-7.145l-1.693 1.84a50.21 50.21 0 0 0-7.296-5.573l1.329-2.117c-2.71-1.702-5.588-3.162-8.603-4.353l-.918 2.326c-2.822-1.115-5.769-1.979-8.814-2.568l.474-2.454-4.775-.697c-.381-.037-.745-.141-1.076-.298l-1.073 2.258c-1.216-.578-2.192-1.567-2.703-2.785l2.306-.966A2.49 2.49 0 0 1 60.5 251v-5H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-10H58v-10h2.5v-5a2.48 2.48 0 0 1 .189-.956l-2.309-.958a5.02 5.02 0 0 1 2.707-2.707l.958 2.31A2.48 2.48 0 0 1 63 108.5h5.038V106h10.076v2.5H88.19V106h10.076v2.5h10.075V106h10.076v2.5h10.076V106h10.076v2.5h10.075V106h10.076v2.5h10.076V106h10.076v2.5h10.075V106h10.076v2.5h10.076V106h10.076v2.5h10.075V106h10.076v2.5h10.076V106h10.076v2.5h10.075V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.075v2.5h10.076V106h10.076v2.5h10.076V106h10.076v2.5h10.075V106h10.076v2.5h10.076V106h10.076v2.5h10.075V106h10.076v2.5h10.076V106h10.076v2.5h10.075V106h10.076v2.5H728c.344 0 .665.068.956.189l.958-2.31a5.02 5.02 0 0 1 2.707 2.707l-2.31.958c.121.291.189.612.189.956v5h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v10h2.5v10h-2.5v5a2.49 2.49 0 0 1-.194.967l2.306.966c-.51 1.218-1.487 2.207-2.703 2.785l-1.073-2.258a3.24 3.24 0 0 1-1.076.298l-4.775.697.474 2.454a49.62 49.62 0 0 0-8.814 2.568l-.918-2.326c-3.015 1.191-5.892 2.651-8.602 4.353l1.329 2.117c-2.603 1.634-5.045 3.502-7.297 5.573l-1.692-1.84c-2.367 2.177-4.533 4.569-6.468 7.145l1.999 1.501a50.03 50.03 0 0 0-4.817 7.815l-2.24-1.111a52.29 52.29 0 0 0-3.468 8.997l2.406.68z' stroke='#000' stroke-width='5' stroke-dasharray='10 10'/><text fill='#000' xml:space='preserve' style='white-space:pre' font-family='Comic Sans MS' font-size='24' letter-spacing='0em'><tspan x='87' y='444.227'>given by:</tspan><tspan x='87' y='477.227'>";

        parts[1] = couponGiverName;

        parts[
            2
        ] = "</tspan><tspan x='230.004' y='160.227'>COUPON REDEEMABLE FOR:</tspan></text><text fill='#000' xml:space='preserve' style='white-space:pre' font-family='Comic Sans MS' font-size='36' font-weight='bold' letter-spacing='0em'><tspan text-anchor='middle' x='50%' y='325.453'>";

        parts[3] = coupon;

        parts[4] = "</tspan></text></svg>";

        string memory output = string(
            abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4])
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Coupon #',
                        Strings.toString(tokenId),
                        '", "description": "coupon redeemable for ',
                        coupon,
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

    function lookupENSName(address addr) internal view returns (string memory) {
        bytes32 node = ensReverseRegistrar.node(addr);
        return ensReverseRegistrar.defaultResolver().name(node);
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
        return string(abi.encodePacked("0x", s));
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
