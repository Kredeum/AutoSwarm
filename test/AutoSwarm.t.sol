// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {AutoSwarm} from "src/AutoSwarm.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";

contract AutoSwarmTest is Test, ReadWriteJson {
    AutoSwarm autoSwarm;
    PostageStamp postageStamp;
    IERC20 bzzToken;
    uint8 minDepth;

    function setUp() public {
        postageStamp = PostageStamp(readAddress("PostageStamp"));
        bzzToken = IERC20(readAddress("BzzToken"));

        autoSwarm = new AutoSwarm(address(postageStamp));
        // autoSwarm = AutoSwarm(readAddress("AutoSwarm"));

        uint256 postageStampCodeLength = address(autoSwarm).code.length;
        uint256 bzzTokenCodeLength = address(bzzToken).code.length;
        uint256 autoSwarmCodeLength = address(autoSwarm).code.length;

        if (postageStampCodeLength == 0 || bzzTokenCodeLength == 0 || autoSwarmCodeLength == 0) {
            console.log("postageStamp:", address(postageStamp), postageStampCodeLength);
            console.log("bzzToken:", address(bzzToken), bzzTokenCodeLength);
            console.log("autoSwarm:", address(autoSwarm), autoSwarmCodeLength);
            revert("BAD NETWORK or ADDRESSES: no autoSwarm or bzzToken");
        }

        minDepth = postageStamp.minimumBucketDepth();
    }

    function test_autoswarm_OK() public pure {
        assert(true);
    }

    function _buy(uint256 ttl, uint8 depth) internal returns (bytes32) {
        deal(address(bzzToken), address(autoSwarm), ttl << depth);
        return autoSwarm.stampsBuy(ttl, depth);
    }

    function _topUp(bytes32 batchId, uint256 ttl) internal {
        (, uint8 depth,,) = postageStamp.batches(batchId);
        deal(address(bzzToken), address(autoSwarm), ttl << depth);
        autoSwarm.stampsTopUp(batchId, ttl);
    }

    function test_autoswarm_buy() public {
        uint256 ttl = 10 weeks;
        bytes32 batchId = _buy(ttl, 20);

        assert(postageStamp.remainingBalance(batchId) == ttl);
    }

    function test_autoswarm_remaining() public {
        uint8 depth = 20;
        uint256 ttl = 10 weeks;

        uint256 lastPrice = postageStamp.lastPrice();

        vm.prank(readAddress("Oracle"));
        postageStamp.setPrice(lastPrice);

        bytes32 batchId = _buy(ttl, depth);

        vm.roll(postageStamp.lastUpdatedBlock() + 10);
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

        autoSwarm.stampsIncrease(batchId, depth + depthPlus);

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
