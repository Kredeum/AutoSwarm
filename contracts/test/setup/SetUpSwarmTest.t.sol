// SPDX-License-Identifier: MITs
pragma solidity 0.8.23;

import "@autoswarm/test/setup/SetUpSwarm.t.sol";

contract SetUpSwarmTest is SetUpSwarm {
    function setUp() public {
        setRecording(false);
        setUpSwarm();
    }

    function test_SetUpSwarm_OK() public pure {
        assert(true);
    }

    function test_SetUpSwarm_PostageStamps() public view {
        bytes memory codeToDeploy = _getCodeToDeploy("PostageStamp");
        require(codeToDeploy.length == address(postageStamp).code.length, "postageStamp code length differs");
        // include immutable variables
        // require(_isSameCode(codeToDeploy, address(postageStamp).code), "postageStamp code differs");
    }

    function test_SetUpSwarm_BzzToken() public view {
        bytes memory codeToDeploy = _getCodeToDeploy("BzzToken");
        require(_isSameCode(codeToDeploy, address(bzzToken).code), "BzzToken code differs");
    }

    function test_SetUpSwarm_Swarm() public view {
        require(postageStamp.bzzToken() == address(bzzToken), "BzzToken not linked by PostageStamp");
        require(bzzToken.totalSupply() > 0, "BzzToken totalSupply is zero");
        require(minDepth >= 16, "MinDepth must be more than 16");

        require(postageStamp.hasRole(postageStamp.PRICE_ORACLE_ROLE(), oracle), "Oracle has not Oracle_Role");
        require(postageStamp.hasRole(postageStamp.DEFAULT_ADMIN_ROLE(), admin), "Admin has not Admin_Role");
    }
}
