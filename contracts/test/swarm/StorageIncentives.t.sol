// SPDX-License-Identifier: MITs
pragma solidity 0.8.23;

import "@autoswarm/test/setup/SetUpSwarm.t.sol";

contract StorageIncentivesTest is SetUpSwarm {
    function setUp() public {
        setRecording(false);
        setUpSwarm();
    }

    function test_StorageIncentives_OK() public pure {
        assert(true);
    }

    // BZZTOKEN
    function test_StorageIncentivesgetBzzToken() public view {
        console.log("bzzToken:", address(bzzToken), address(bzzToken).code.length);
        assert(address(bzzToken).code.length > 0);
    }

    function test_StorageIncentivesgetBzzToken_totalSupply() public view {
        assert(bzzToken.totalSupply() > 0);
    }

    // POSTAGESTAMP
    function test_StorageIncentives_postageStamp() public view {
        console.log("postageStamp:", address(postageStamp), address(postageStamp).code.length);
        assert(address(postageStamp).code.length > 0);
    }

    function test_StorageIncentives_postageStampgetBzzToken() public view {
        console.log("postageStamp:", address(postageStamp), address(postageStamp).code.length);
        assert(address(postageStamp).code.length > 0);

        assert(postageStamp.bzzToken() == address(bzzToken));
    }
}
