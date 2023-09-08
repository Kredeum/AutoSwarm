// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpERC6551.t.sol";

contract SimpleERC6551AccountTest is SetUpERC6551 {
    function setUp() public {
        setUpERC6551();
    }

    function test_SimpleERC6551Account_OK() public pure {
        assert(true);
    }

    // REGISTRY
    function test_SimpleERC6551Account_registry_code() public view {
        console.log("registry:", address(registry), address(registry).code.length);
        assert(address(registry).code.length > 0);
    }

    function test_SimpleERC6551Account_registry_account() public {
        address _account = registry.account(address(implementation), chainId, collection, tokenId, salt);
        address account_ = registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        console.log("account:", account_);

        assert((_account != address(0)) && (_account == account_));
    }

    // IMPLEMENTATION
    function test_SimpleERC6551Account_implementation() public view {
        console.log(" implementation:", address(implementation), address(implementation).code.length);
        assert(address(implementation).code.length > 0);
    }

    function test_SimpleERC6551Account_implementation_reverts() public {
        vm.expectRevert();
        SimpleERC6551Account(payable(address(implementation))).token();
    }

    // ACCOUNT
    function test_SimpleERC6551Account_account() public {
        address account = registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        assert(account.code.length > 0);
    }

    function test_SimpleERC6551Account_account_token() public {
        address account = registry.createAccount(address(implementation), chainId, collection, tokenId, salt, "");
        (uint256 chainId_, address collection_, uint256 tokenId_) = SimpleERC6551Account(payable(account)).token();
        assert(chainId_ == chainId);
        assert(collection_ == collection);
        assert(tokenId_ == tokenId);
    }

    // COLLECTION
    function test_erc6551_collection() public view {
        console.log("collection:", collection, collection.code.length);
        assert(collection.code.length > 0);
    }

    function test_erc6551_collection_totalSupply() public view {
        assert(IERC721Enumerable(collection).totalSupply() > 0);
    }
}
