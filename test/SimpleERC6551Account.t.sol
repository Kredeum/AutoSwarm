// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {IERC721Enumerable} from "lib/forge-std/src/interfaces/IERC721.sol";

contract SimpleERC6551AccountTest is Test, ReadWriteJson {
    uint256 salt = 0;

    uint256 chainId;
    address collection;
    uint256 tokenId;

    address registry;
    address implementation;

    function setUp() public {
        chainId = block.chainid;
        collection = readAddress("NFTCollection");
        tokenId = 1;

        registry = readAddress("ERC6551Registry");
        implementation = readAddress("SimpleERC6551Account");

        require(
            (registry.code.length > 0) && (implementation.code.length > 0), "BAD NETWORK: no registry or implementation"
        );
    }

    function test_erc6551_OK() public {
        assert(true);
    }

    // REGISTRY
    function test_erc6551_registry_code() public view {
        console.log("registry:", registry, registry.code.length);
        assert(registry.code.length > 0);
    }

    function test_erc6551_registry_account() public {
        address _account = ERC6551Registry(registry).account(implementation, chainId, collection, tokenId, salt);
        address account_ =
            ERC6551Registry(registry).createAccount(implementation, chainId, collection, tokenId, salt, "");
        console.log("account:", account_);

        assert((_account != address(0)) && (_account == account_));
    }

    // IMPLEMENTATION
    function test_erc6551_implementation() public view {
        console.log("implementation:", implementation, implementation.code.length);
        assert(implementation.code.length > 0);
    }

    function test_erc6551_implementation_reverts() public {
        vm.expectRevert();
        SimpleERC6551Account(payable(implementation)).token();
    }

    // ACCOUNT
    function test_erc6551_account() public {
        address account =
            ERC6551Registry(registry).createAccount(implementation, chainId, collection, tokenId, salt, "");
        assert(account.code.length > 0);
    }

    function test_erc6551_account_token() public {
        address account =
            ERC6551Registry(registry).createAccount(implementation, chainId, collection, tokenId, salt, "");
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
