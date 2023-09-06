// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetupSwarm.t.sol";

contract StorageIncentivesTest is SetupSwarmTest {
    function test_incentives_OK() public pure {
        assert(true);
    }

    // BZZTOKEN
    function test_incentives_bzzToken() public view {
        console.log("bzzToken:", address(bzzToken), address(bzzToken).code.length);
        assert(address(bzzToken).code.length > 0);
    }

    function test_incentives_bzzToken_totalSupply() public view {
        assert(bzzToken.totalSupply() > 0);
    }

    // POSTAGESTAMP
    function test_incentives_postageStamp() public view {
        console.log("postageStamp:", address(postageStamp), address(postageStamp).code.length);
        assert(address(postageStamp).code.length > 0);
    }

    function test_incentives_postageStamp_bzzToken() public  view {
        console.log("postageStamp:", address(postageStamp), address(postageStamp).code.length);
        assert(address(postageStamp).code.length > 0);

        assert(postageStamp.bzzToken() == address(bzzToken));
    }
}
