// SPDX-License-Identifier: MITs
pragma solidity ^0.8.4;

import {console} from "forge-std/console.sol";
import {IERC721} from "forge-std/interfaces/IERC721.sol";

import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {SetUpAutoSwarmMarket} from "@autoswarm/test/setup/SetUpAutoSwarmMarket.t.sol";

contract PostageStampMock {
    function bzzToken() public pure returns (address) {
        return address(1);
    }
}

contract AutoSwarmMarketHarness is AutoSwarmMarket {
    constructor(address _postageStamp) AutoSwarmMarket(_postageStamp) {
        console.log("AutoSwarmMarketUnitTest ~ constructor");
    }

    function ceilDiv(uint256 a, uint256 b) public pure returns (uint256) {
        return _ceilDiv(a, b);
    }

    function subPos(uint256 a, uint256 b) public pure returns (uint256) {
        return _subPos(a, b);
    }
}

contract AutoSwarmMarketHarnessTest {
    AutoSwarmMarketHarness autoSwarmMarketHarness;
    PostageStampMock postageStampMock;

    function setUp() public {
        postageStampMock = new PostageStampMock();
        autoSwarmMarketHarness = new AutoSwarmMarketHarness(address(postageStampMock));
    }

    function test_AutoSwarmMarketHarness_OK() public pure {
        assert(true);
    }

    function test_AutoSwarmMarketHarness_ceilDiv() public view {
        assert(autoSwarmMarketHarness.ceilDiv(0, 100) == 0);
        assert(autoSwarmMarketHarness.ceilDiv(1, 100) == 1);
        assert(autoSwarmMarketHarness.ceilDiv(100, 100) == 1);
        assert(autoSwarmMarketHarness.ceilDiv(101, 100) == 2);
    }

    function test_AutoSwarmMarketHarness_subPos() public view {
        assert(autoSwarmMarketHarness.subPos(0, 1) == 0);
        assert(autoSwarmMarketHarness.subPos(3, 1) == 2);
        assert(autoSwarmMarketHarness.subPos(10, 12) == 0);
        assert(autoSwarmMarketHarness.subPos(23, 5) == 18);
    }
}
