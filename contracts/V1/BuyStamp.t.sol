// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {SetUpAutoSwarmAccount} from "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract BuyStampTest is SetUpAutoSwarmAccount {
    address public BUYER = makeAddr("buyer");

    function test_BuyStamp_OK() public pure {
        assert(true);
    }

    function test_BuyStamp_AutoSwarmAccount() public {
        uint256 amount = 1e18;

        deal(address(bzzToken), address(autoSwarmAccount), amount);

        vm.startPrank(nftOwner);

        bytes32 stampId = autoSwarmAccount.buyYearStamp(2023, bytes32("dfqsdf"), 10_000, 0);
        console.logBytes32(stampId);

        vm.stopPrank();

        assert(true);
    }

    function test_BuyStamp_AutoSwarmMarket() public {
        uint256 amount = 1e18;
        deal(address(bzzToken), BUYER, amount);

        vm.startPrank(BUYER);

        bzzToken.approve(address(autoSwarmMarket), amount);
        bytes32 stampId = autoSwarmMarket.buyStamp(2023, bytes32("hjfghjf"), 10_000, 0);
        console.logBytes32(stampId);

        vm.stopPrank();

        assert(true);
    }
}
