// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpERC6551.t.sol";

contract SetUpERC6551Test is SetUpERC6551 {
    function setUp() public {
        setUpERC6551();
    }

    function test_SetUpERC6551_OK() public pure {
        assert(true);
    }

    function test_SetUpERC6551_NFTCollection() public view {
        (,, bytes memory codeToDeploy) = isDeployed("ERC721PresetMinterPauserAutoId");
        require(isSameRunCode(codeToDeploy, collection.code), "NFTCollection code differs");
    }

    function test_SetUpERC6551_ERC6551Registry() public view {
        (,, bytes memory codeToDeploy) = isDeployed("ERC6551Registry");
        require(isSameRunCode(codeToDeploy, address(registry).code), "ERC6551Registry code differs");
    }

    function test_SetUpERC6551_SimpleERC6551Account() public view {
        (,, bytes memory codeToDeploy) = isDeployed("SimpleERC6551Account");
        require(isSameRunCode(codeToDeploy, address(implementation).code), "SimpleERC6551Account code differs");
    }

    function test_SetUpERC6551() public view {
        require(ERC721PresetMinterPauserAutoId(collection).totalSupply() > 0, "NFTCollection totalSupply is zero");
    }
}
