// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetUpSwarm.t.sol";

contract SetUpSwarmTest is SetUpSwarm {
    function setUp() public {
        setUpSwarm();
    }

    function test_SetUpSwarm_OK() public pure {
        assert(true);
    }

    function test_SetUpSwarm_PostageStamps() public {
        bytes memory codeToDeploy = getCodeToDeploy("PostageStamp");
        require(isSameRunCode(codeToDeploy, address(postageStamp).code), "postageStamp code differs");
    }

    function test_SetUpSwarm_BzzToken() public {
        bytes memory codeToDeploy = getCodeToDeploy("BzzToken");
        require(isSameRunCode(codeToDeploy, address(bzzToken).code), "BzzToken code differs");
    }

    function test_SetUpSwarm() public view {
        require(postageStamp.batchOwner(batchId0) == address(this), "Bad batch owner");

        require(postageStamp.bzzToken() == address(bzzToken), "BzzToken not linked by PostageStamp");
        require(bzzToken.totalSupply() > 0, "BzzToken totalSupply is zero");
        require(minDepth >= 16, "MinDepth must be more than 16");

        require(postageStamp.hasRole(postageStamp.PRICE_ORACLE_ROLE(), oracle), "Oracle has not Oracle_Role");
        require(postageStamp.hasRole(postageStamp.DEFAULT_ADMIN_ROLE(), admin), "Admin has not Admin_Role");
    }
}
