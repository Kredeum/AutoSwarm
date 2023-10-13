// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {console} from "forge-std/Test.sol";

import {SetUpSwarm} from "@autoswarm/test/SetUpSwarm.t.sol";
import {SetUpERC6551} from "@autoswarm/test/SetUpERC6551.t.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";

contract SetUpAutoSwarmAccount is SetUpSwarm, SetUpERC6551 {
    AutoSwarmAccount public autoSwarmAccount;
    bytes32 batchId0;
    uint256 ttl0 = 10 weeks;
    uint8 depth0 = 20;

    function setUpAutoSwarmAccount() public {
        require(chainId == block.chainid, "Wrong network");

        address nftOwner = IERC721(collection).ownerOf(tokenId);
        require(nftOwner != address(0), "No NFT here!");

        autoSwarmAccount =
            AutoSwarmAccount(payable(registry.account(address(implementation), chainId, collection, tokenId, salt)));
        if (address(autoSwarmAccount).code.length == 0) {
            bytes memory initData = abi.encodeWithSignature("initialize(address)", address(postageStamp));
            vm.prank(nftOwner);
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, initData);
        }
        assert(address(autoSwarmAccount).code.length != 0);
    }

    function setUp() public virtual {
        setRecording(false);
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarmAccount();
    }
}
