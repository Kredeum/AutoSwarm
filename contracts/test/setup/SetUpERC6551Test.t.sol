// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {IERC721Enumerable} from "forge-std/interfaces/IERC721.sol";
import {console} from "forge-std/console.sol";

import "@autoswarm/test/setup/SetUpERC6551.t.sol";

contract SetUpERC6551Test is SetUpERC6551 {
    function setUp() public {
        setRecording(false);
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

    function test_SetUpERC6551_Implementation() public view {
        bytes memory codeToDeploy = getCodeToDeploy("AutoSwarmAccount");
        console.logBytes(codeToDeploy);
        console.log("test_SetUpERC6551_Implementation ~ codeToDeploy:", codeToDeploy.length);
        console.logBytes(address(implementation).code);
        console.log(
            "test_SetUpERC6551_Implementation ~ address(implementation).code:", address(implementation).code.length
        );
        require(
            isSameRunCode(codeToDeploy, address(implementation).code),
            "Implementation code differs from AutoSwarmAccount"
        );
    }

    function test_SetUpERC6551() public view {
        require(IERC721Enumerable(collection).totalSupply() > 0, "NFTCollection totalSupply is zero");
    }
}
