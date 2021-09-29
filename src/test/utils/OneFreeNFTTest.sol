// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "ds-test/test.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "../../OneFreeNFT.sol";
import "./Hevm.sol";

contract User is ERC721Holder {
    OneFreeNFT internal oneFreeNFT;

    constructor(address _oneFreeNFT) {
        oneFreeNFT = OneFreeNFT(_oneFreeNFT);
    }

    function mint(address to, string memory coupon) public returns (uint256) {
        return oneFreeNFT.mint(to, coupon);
    }

    function redeem(uint256 tokenId) public {
        return oneFreeNFT.redeem(tokenId);
    }

    function grant(uint256 tokenId) public {
        return oneFreeNFT.grant(tokenId);
    }
}

contract OneFreeNFTTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    // contracts
    OneFreeNFT internal oneFreeNFT;

    // users
    User internal alice;
    User internal bob;

    function setUp() public virtual {
        oneFreeNFT = new OneFreeNFT();
        alice = new User(address(oneFreeNFT));
        bob = new User(address(oneFreeNFT));
    }
}
