// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import "./SetupSwarm.t.sol";

contract AutoSwarmTest is SetupSwarmTest {
    function _buy(uint256 ttl, uint8 depth) internal returns (bytes32) {
        deal(address(bzzToken), address(autoSwarm), ttl << depth);
        return autoSwarm.stampsBuy(ttl, depth);
    }

    function _topUp(bytes32 batchId, uint256 ttl) internal {
        (, uint8 depth,,,,) = postageStamp.batches(batchId);
        deal(address(bzzToken), address(autoSwarm), ttl << depth);
        autoSwarm.stampsTopUp(batchId, ttl);
    }

    function test_autoswarm_OK() public pure {
        assert(true);
    }

    function test_autoswarm_buy() public {
        uint256 ttl = 10 weeks;
        bytes32 batchId = _buy(ttl, 20);

        assert(postageStamp.remainingBalance(batchId) == ttl);
    }

    function test_autoswarm_remaining() public {
        uint8 depth = 20;
        uint256 ttl = 10 weeks;
        console.log("test_autoswarm_remaining ~ ttl:", ttl);

        uint256 lastPrice = postageStamp.lastPrice();
        vm.prank(oracle);
        postageStamp.setPrice(lastPrice + 1);

        bytes32 batchId = _buy(ttl, depth);

        vm.roll(postageStamp.lastUpdatedBlock() + 1);
        assert(postageStamp.remainingBalance(batchId) < ttl);
    }

    function test_autoswarm_topup() public {
        uint8 depth = 20;
        uint256 ttl = 10 weeks;
        uint256 ttlPlus = 1 weeks;

        bytes32 batchId = _buy(ttl, depth);
        _topUp(batchId, ttlPlus);

        assert(postageStamp.remainingBalance(batchId) == (ttl + ttlPlus));
    }

    function test_autoswarm_increase() public {
        uint8 depth = 20;
        uint8 depthPlus = 4;
        uint256 ttl = 10 weeks;

        bytes32 batchId = _buy(ttl, depth);
        uint256 remainingBalance = postageStamp.remainingBalance(batchId);

        postageStamp.increaseDepth(batchId, depth + depthPlus);

        assert(postageStamp.remainingBalance(batchId) == remainingBalance / (1 << depthPlus));
    }

    // function test_autoswarm_buy_f(uint256 ttl, uint8 depth) public {
    //     vm.assume(depth < 128);
    //     vm.assume(minDepth < depth);
    //     vm.assume(ttl <= type(uint128).max);
    //     vm.assume(0 < ttl);

    //     deal(address(bzzToken), address(autoSwarm), ttl << depth);
    //     autoSwarm.stampsBuy(ttl, depth);

    //     assert(true);
    // }
}
