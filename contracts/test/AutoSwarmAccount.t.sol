// SPDX-License-Identifier: MITs
pragma solidity 0.8.23;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {SetUpAutoSwarmAccount} from "@autoswarm/test/setup/SetUpAutoSwarmAccount.t.sol";

contract AutoSwarmAccountTest is SetUpAutoSwarmAccount {
    function test_AutoSwarmAccount_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmAccount_topUp_NFT() public {
        address accountAddress = registry.account(address(implementation), salt, chainId, collection, tokenId);
        console.log(accountAddress, "NFT Account");

        // DISPLAY NFT owner
        assert(block.chainid == chainId);
        address nftOwner = IERC721(collection).ownerOf(tokenId);
        console.log(nftOwner, "NFT owner");

        vm.startPrank(nftOwner);

        // CREATE NFT Account if not already exists
        if (accountAddress.code.length == 0) {
            registry.createAccount(address(implementation), salt, chainId, collection, tokenId);
        }
        assert(accountAddress.code.length != 0);

        vm.stopPrank();
    }
}
