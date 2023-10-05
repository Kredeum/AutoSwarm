// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract AutoSwarmAccountUnitTest is SetUpAutoSwarmAccount {
    function test_AutoSwarmAccountUnit_OK() public view {
        console.log("test_AutoSwarmAccountUnit_stampsBuy ~ autoSwarmAccount:", address(autoSwarmAccount));
        assert(true);
    }

    function test_AutoSwarmAccountUnit_Create() public {
        address account = registry.account(address(implementation), chainId, collection, tokenId, salt);

        if (account.code.length == 0) {
            registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        }
        assert(account.code.length != 0);
    }

    // function test_AutoSwarmAccount_nonce() public {
    //     bytes32 salt1 = autoSwarmAccount._newNonce();
    //     assert(salt1 != "");
    //     bytes32 salt2 = autoSwarmAccount._newNonce();
    //     assert(salt2 != salt1);
    // }

    function test_AutoSwarmAccount_token() public view {
        (uint256 chId, address coll, uint256 tokId) = AutoSwarmAccount(payable(autoSwarmAccount)).token();

        assert(chId == chainId);
        assert(coll == collection);
        assert(tokId == tokenId);
    }
}
