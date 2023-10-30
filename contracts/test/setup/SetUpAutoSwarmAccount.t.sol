// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {console} from "forge-std/Test.sol";

import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";

import {SetUpSwarm} from "@autoswarm/test/setup/SetUpSwarm.t.sol";
import {SetUpAutoSwarmMarket} from "@autoswarm/test/setup/SetUpAutoSwarmMarket.t.sol";
import {SetUpERC6551} from "@autoswarm/test/setup/SetUpERC6551.t.sol";

contract SetUpAutoSwarmAccount is SetUpAutoSwarmMarket, SetUpERC6551 {
    AutoSwarmAccount public autoSwarmAccount;
    bytes32 batchId0;
    uint256 ttl0 = 10 weeks;
    uint8 depth0 = 20;

    function setUpAutoSwarmAccount() public {
        require(chainId == block.chainid, "Wrong network");

        address nftOwner = IERC721(collection).ownerOf(tokenId);
        require(nftOwner != address(0), "No NFT here!");

        uint256 bzzAmount = autoSwarmMarket.getStampPriceOneYear(1);

        autoSwarmAccount =
            AutoSwarmAccount(payable(registry.account(address(implementation), salt, chainId, collection, tokenId)));
        deal(address(bzzToken), address(autoSwarmAccount), bzzAmount);

        if (address(autoSwarmAccount).code.length == 0) {
            vm.startPrank(nftOwner);
            registry.createAccount(address(implementation), salt, chainId, collection, tokenId);
            autoSwarmAccount.initialize(address(autoSwarmMarket), bytes32("1"), 85_000, bzzAmount);
            vm.stopPrank();
        }
        assert(address(autoSwarmAccount).code.length != 0);
    }

    function setUp() public override {
        super.setUp();
        setUpERC6551();
        setUpAutoSwarmAccount();
    }
}