// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpERC6551.t.sol";
import {IERC721Enumerable} from "lib/forge-std/src/interfaces/IERC721.sol";

contract SetUpERC6551Test is SetUpERC6551 {
    function setUp() public {
        setUpERC6551();
    }

    function test_SetUpERC6551_OK() public pure {
        assert(true);
    }

    function test_SetUpERC6551_NFTCollection() public view {
        bytes memory codeToDeploy = getCodeToDeploy("NFTCollection");
        require(isSameRunCode(codeToDeploy, collection.code), "NFTCollection code differs");
    }

    function test_SetUpERC6551_ERC6551Registry() public view {
        bytes memory codeToDeploy = getCodeToDeploy("ERC6551Registry");
        require(isSameRunCode(codeToDeploy, address(registry).code), "ERC6551Registry code differs");
    }

    function test_SetUpERC6551_AutoSwarmAccount() public view {
        bytes memory codeToDeploy = getCodeToDeploy("AutoSwarmAccount");
        require(isSameRunCode(codeToDeploy, address(implementation).code), "AutoSwarmAccount code differs");
    }

    function test_SetUpERC6551() public view {
        require(IERC721Enumerable(collection).totalSupply() > 0, "NFTCollection totalSupply is zero");
    }
}
