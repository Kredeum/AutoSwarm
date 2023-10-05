// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {console} from "forge-std/Test.sol";

import {SetUpSwarm} from "@autoswarm/test/SetUpSwarm.t.sol";
import {SetUpERC6551} from "@autoswarm/test/SetUpERC6551.t.sol";
import {AutoSwarmAccountV0} from "@autoswarm/src/v0/AutoSwarmAccountV0.sol";

contract SetUpAutoSwarmAccountV0 is SetUpSwarm, SetUpERC6551 {
    AutoSwarmAccountV0 public autoSwarmAccountV0;
    bytes32 batchId0;
    uint256 ttl0 = 10 weeks;
    uint8 depth0 = 20;

    function setUpAutoSwarmAccountV0() public {
        require(chainId == block.chainid, "Wrong network");

        address nftOwner = IERC721(collection).ownerOf(tokenId);
        require(nftOwner != address(0), "No NFT here!");

        autoSwarmAccountV0 =
            AutoSwarmAccountV0(payable(registry.account(address(implementation), chainId, collection, tokenId, salt)));
        if (address(autoSwarmAccountV0).code.length == 0) {
            bytes memory initData = abi.encodeWithSignature("initialize(address)", address(postageStamp));
            vm.prank(nftOwner);
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, initData);
        }
        assert(address(autoSwarmAccountV0).code.length != 0);

        deal(address(bzzToken), address(autoSwarmAccountV0), ttl0 << depth0);
        batchId0 = autoSwarmAccountV0.stampsBuy(ttl0, depth0);
    }

    function setUp() public virtual {
        setUpERC6551();
        setUpSwarm();
        setUpAutoSwarmAccountV0();
    }
}
