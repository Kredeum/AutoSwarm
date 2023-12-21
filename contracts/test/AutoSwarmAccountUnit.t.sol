// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {console} from "forge-std/Test.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import "@autoswarm/test/setup/SetUpAutoSwarmAccount.t.sol";

contract AutoSwarmAccountUnitTest is SetUpAutoSwarmAccount {
    uint256 constant BLOCKS_PER_YEAR = 365 * 24 * 3600 / 5;

    function test_AutoSwarmAccountUnit_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmAccountUnit_Create() public {
        address account = registry.account(address(implementation), salt, chainId, collection, tokenId);

        if (account.code.length == 0) {
            registry.createAccount(address(implementation), salt, chainId, collection, tokenId);
        }
        assert(account.code.length != 0);
    }

    function test_AutoSwarmAccount_initialize3() public {
        bytes32 salt = "3";

        tba = AutoSwarmAccount(
            payable(registry.createAccount(address(implementation), salt, chainId, collection, tokenId))
        );
        deal(address(bzzToken), address(tba), 4e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_initialize1() public {
        bytes32 salt = "1";

        tba = AutoSwarmAccount(payable(registry.account(address(implementation), salt, chainId, collection, tokenId)));

        assert(address(tba).code.length == 0);
        registry.createAccount(address(implementation), salt, chainId, collection, tokenId);
        assert(address(tba).code.length != 0);

        vm.expectRevert();

        deal(address(bzzToken), address(tba), 2e8 * BLOCKS_PER_YEAR);

        // assert(tba.swarmHash() == bytes32("1"));
        // assert(tba.swarmSize() == 1);
        // assert(bzzToken.allowance(address(tba), address(autoSwarmMarket)) == 0);
        // assert(tba.getTopUpYearPrice() == 2e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_initialize2() public {
        bytes32 salt = "2";

        tba = AutoSwarmAccount(payable(registry.account(address(implementation), salt, chainId, collection, tokenId)));
        deal(address(bzzToken), address(tba), 4e8 * BLOCKS_PER_YEAR);

        registry.createAccount(address(implementation), salt, chainId, collection, tokenId);

        // assert(tba.swarmHash() == bytes32("1"));
        // assert(bzzToken.allowance(address(tba), address(autoSwarmMarket)) == 0);
        // assert(tba.getTopUpYearPrice() == 4e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_swarhHash() public view {
        // assert(tba.swarmHash() == bytes32("1"));
    }

    function test_AutoSwarmAccount_swarmSize() public view {
        // assert(tba.swarmSize() == 1);
    }

    function test_AutoSwarmAccount_getTopUpYearPrice() public view {
        // assert(tba.getTopUpYearPrice() == 2e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_token() public view {
        (uint256 chId, address coll, uint256 tokId) = tba.token();

        assert(chId == chainId);
        assert(coll == collection);
        assert(tokId == tokenId);
    }

    function test_AutoSwarmAccount_implementation() public view {
        address impl = tba.implementation();
        console.log("test_AutoSwarmAccount_implementation ~ implementation:", impl);
    }
}
