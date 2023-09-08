// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpAutoSwarm.t.sol";

contract AutoSwarmTest is SetUpAutoSwarm {
    function stampsBuyForNFT(uint256 chainId, address collection, uint256 tokenId) public returns (bytes32) {
        address accountAddress = registry.account(address(implementation), chainId, collection, tokenId, salt);

        if (accountAddress.code.length == 0) {
            registry.createAccount(
                address(implementation),
                chainId,
                collection,
                tokenId,
                salt,
                abi.encodeWithSignature("initialize(bool)", true)
            );
        }

        assert(accountAddress.code.length != 0);

        return autoSwarm.stampsBuy(ttl0, depth0, "");
    }

    function test_AutoSwarm_OK() public pure {
        assert(true);
    }
}
