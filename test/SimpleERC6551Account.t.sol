// SPDX-License-Identifier: MITs
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {IERC721Enumerable} from "lib/forge-std/src/interfaces/IERC721.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

interface IBzz {
    function bzzToken() external returns (address);
}

contract SimpleERC6551AccountTest is Test, ReadWriteJson {
    uint256 salt = 0;

    uint256 chainId;
    address collection;
    uint256 tokenId;

    address registry;
    address implementation;

    address postageStamp;
    address bzzToken;

    function setUp() public {
        chainId = block.chainid;
        collection = readAddress("NFTCollection");
        tokenId = 1;

        registry = readAddress("ERC6551Registry");
        implementation = readAddress("SimpleERC6551Account");

        postageStamp = readAddress("PostageStamp");
        bzzToken = readAddress("BzzToken");
    }

    function test_OK() public pure {
        assert(true);
    }

    // REGISTRY
    function test_registry_code() public view {
        console.log("registry:", registry, registry.code.length);
        assert(registry.code.length > 0);
    }

    function test_registry_account() public {
        address _account = ERC6551Registry(registry).account(implementation, chainId, collection, tokenId, salt);
        address account_ =
            ERC6551Registry(registry).createAccount(implementation, chainId, collection, tokenId, salt, "");
        console.log("account:", account_);

        assert((_account != address(0)) && (_account == account_));
    }

    // IMPLEMENTATION
    function test_implementation() public view {
        console.log("implementation:", implementation, implementation.code.length);
        assert(implementation.code.length > 0);
    }

    function test_implementation_reverts() public {
        vm.expectRevert();
        SimpleERC6551Account(payable(implementation)).token();
    }

    // ACCOUNT
    function test_account() public {
        address account =
            ERC6551Registry(registry).createAccount(implementation, chainId, collection, tokenId, salt, "");
        assert(account.code.length > 0);
    }

    function test_account_token() public {
        address account =
            ERC6551Registry(registry).createAccount(implementation, chainId, collection, tokenId, salt, "");
        (uint256 chainId_, address collection_, uint256 tokenId_) = SimpleERC6551Account(payable(account)).token();
        assert(chainId_ == chainId);
        assert(collection_ == collection);
        assert(tokenId_ == tokenId);
    }

    // COLLECTION
    function test_collection() public view {
        console.log("collection:", collection, collection.code.length);
        assert(collection.code.length > 0);
    }

    function test_collection_totalSupply() public view {
        assert(IERC721Enumerable(collection).totalSupply() > 0);
    }

    // BZZTOKEN
    function test_bzzToken() public view {
        console.log("bzzToken:", bzzToken, bzzToken.code.length);
        assert(bzzToken.code.length > 0);
    }

    function test_bzzToken_totalSupply() public view {
        assert(IERC20(bzzToken).totalSupply() > 0);
    }

    // POSTAGESTAMP
    function test_postageStamp() public view {
        console.log("postageStamp:", postageStamp, postageStamp.code.length);
        assert(postageStamp.code.length > 0);
    }

    function test_postageStamp_bzzToken() public  {
        console.log("postageStamp:", postageStamp, postageStamp.code.length);
        assert(postageStamp.code.length > 0);

        assert(IBzz(postageStamp).bzzToken() == bzzToken);
    }
}
