// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {console} from "forge-std/Test.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {Address} from "@openzeppelin/contracts/utils/address.sol";

import "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract AutoSwarmAccountUnitTest is SetUpAutoSwarmAccount {
    uint256 constant BLOCKS_PER_YEAR = 365 * 24 * 3600 / 5;

    function test_AutoSwarmAccountUnit_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmAccountUnit_Create() public {
        address account = registry.account(address(implementation), chainId, collection, tokenId, salt);

        if (account.code.length == 0) {
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        }
        assert(account.code.length != 0);
    }

    function test_AutoSwarmAccount_initialize1() public {
        uint256 salt = 1;

        autoSwarmAccount =
            AutoSwarmAccount(payable(registry.account(address(implementation), chainId, collection, tokenId, salt)));

        registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        assert(address(autoSwarmAccount).code.length != 0);

        vm.expectRevert("Not enough Bzz amount");
        autoSwarmAccount.initialize(address(autoSwarmMarket), bytes32("1"), 85_000, 1e15);

        vm.expectRevert("Not enough Bzz balance");
        autoSwarmAccount.initialize(address(autoSwarmMarket), bytes32("1"), 85_000, 2e15);

        deal(address(bzzToken), address(autoSwarmAccount), 2e8 * BLOCKS_PER_YEAR);

        autoSwarmAccount.initialize(address(autoSwarmMarket), bytes32("1"), 85_000, 2e8 * BLOCKS_PER_YEAR);
        console.log(
            "test_AutoSwarmAccount_initialize1 ~ autoSwarmAccount.getTopUpYearPrice():",
            autoSwarmAccount.getTopUpYearPrice()
        );
        assert(autoSwarmAccount.swarmHash() == bytes32("1"));
        assert(autoSwarmAccount.swarmSize() == 85_000);
        assert(autoSwarmAccount.getBzzAllowance() == 2e8 * BLOCKS_PER_YEAR);
        assert(autoSwarmAccount.getTopUpYearPrice() == 2e8 * BLOCKS_PER_YEAR);

        vm.expectRevert("Already initialized");
        autoSwarmAccount.initialize(address(autoSwarmMarket), bytes32("1"), 85_000, 1e15);
    }

    function test_AutoSwarmAccount_initialize2() public {
        uint256 salt = 2;

        autoSwarmAccount =
            AutoSwarmAccount(payable(registry.account(address(implementation), chainId, collection, tokenId, salt)));
        deal(address(bzzToken), address(autoSwarmAccount), 4e8 * BLOCKS_PER_YEAR);

        registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");

        autoSwarmAccount.initialize(address(autoSwarmMarket), bytes32("1"), 1_200_000,  4e8 * BLOCKS_PER_YEAR);
        console.log(
            "test_AutoSwarmAccount_initialize2 ~ autoSwarmAccount.getTopUpYearPrice():",
            autoSwarmAccount.getTopUpYearPrice()
        );
        assert(autoSwarmAccount.swarmHash() == bytes32("1"));
        assert(autoSwarmAccount.swarmSize() == 1_200_000);
        assert(autoSwarmAccount.getBzzAllowance() == 4e8 * BLOCKS_PER_YEAR);
        assert(autoSwarmAccount.getTopUpYearPrice() == 4e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_swarhHash() public view {
        assert(autoSwarmAccount.swarmHash() == bytes32("1"));
    }

    function test_AutoSwarmAccount_swarmSize() public view {
        assert(autoSwarmAccount.swarmSize() == 85_000);
    }

    function test_AutoSwarmAccount_getTopUpYearPrice() public view {
        assert(autoSwarmAccount.getTopUpYearPrice() == 2e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_getBzzBalance() public view {
        assert(autoSwarmAccount.getBzzBalance() ==  2e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_getBzzAllowance() public view {
        assert(autoSwarmAccount.getBzzAllowance() ==  2e8 * BLOCKS_PER_YEAR);
    }

    function test_AutoSwarmAccount_token() public view {
        (uint256 chId, address coll, uint256 tokId) = autoSwarmAccount.token();

        assert(chId == chainId);
        assert(coll == collection);
        assert(tokId == tokenId);
    }
}
