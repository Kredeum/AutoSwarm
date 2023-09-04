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
    }

    function test_autoswarm_OK() public pure {
        assert(true);
    }

    function test_autoswarm_buy() public {
        uint256 ttl = 10 weeks;
        uint8 depth = 20;
        uint256 bzzAmount = ttl * (1 << depth);

        deal(address(bzzToken), address(autoSwarm), bzzAmount);

        bytes32 batchId = autoSwarm.stampsCreate(ttl, depth);
        // console.logBytes32(batchId);

        uint256 bzzRemaining = postageStamp.remainingBalance(batchId);
        console.log("test_autoswarm_buy ~ balance:", bzzRemaining);

        assert(bzzRemaining > 0);
    }
}
