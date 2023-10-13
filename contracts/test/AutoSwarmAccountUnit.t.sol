// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {console} from "forge-std/Test.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";
import {Address} from "@openzeppelin/contracts/utils/address.sol";

import "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract AutoSwarmHelper {
    using Address for address;

    function isOwnerHelper(AutoSwarmAccount autoSwarmAccount) public returns (bool ok) {
        console.log(tx.origin, "AutoSwarmHelper tx.origin", ok);
        console.log(msg.sender, "AutoSwarmHelper msg.sender", ok);
        console.log(address(this), "AutoSwarmHelper this");

        console.log(address(autoSwarmAccount), "autoSwarmAccount");
        bytes memory data = abi.encodeWithSignature("isOwner()");

        ok = autoSwarmAccount.isOwner();
        console.log("AutoSwarmHelper isOwnerHelper", ok);

        // bytes memory res = address(autoSwarmAccount).functionDelegateCall(data);
        // ok = abi.decode(res, (bool));
        // console.log("AutoSwarmHelper isOwnerHelper", ok);
    }
}

contract AutoSwarmAccountUnitTest is SetUpAutoSwarmAccount {
    function test_AutoSwarmAccountUnit_OK() public view {
        console.log("test_AutoSwarmAccountUnit_stampsBuy ~ autoSwarmAccount:", address(autoSwarmAccount));
        assert(true);
    }

    function test_AutoSwarmAccount_isOwner() public {
        bool ok;
        address owner = autoSwarmAccount.owner();
        console.log(owner, "owner");

        vm.prank(nftOwner);
        ok = autoSwarmAccount.isOwner();
        assert(ok);

        vm.prank(address(1));
        ok = autoSwarmAccount.isOwner();
        assert(!ok);
    }

    function test_AutoSwarmAccount_ownerHelper() public {
        address owner = autoSwarmAccount.owner();
        console.log(owner, "owner");

        AutoSwarmHelper autoSwarmHelper = new AutoSwarmHelper();
        vm.prank(nftOwner, nftOwner);
        bool ok = autoSwarmHelper.isOwnerHelper(autoSwarmAccount);
        assert(!ok);
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
