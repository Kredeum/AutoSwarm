// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";
import {TestToken} from "lib/storage-incentives/src/TestToken.sol";

contract SetUpSwarm is Test, DeployLite {
    PostageStamp public postageStamp;
    IERC20 public bzzToken;
    uint8 public minDepth;
    address public admin;
    address public oracle;

    uint8 depth0 = 20;
    uint256 ttl0 = 10 weeks;
    bytes32 batchId0;
    bytes32 nonce = keccak256("SetUp Swarm");

    function setUpSwarm() public {
        admin = readAddress("Admin");

        postageStamp = PostageStamp(readAddress("PostageStamp"));
        if (address(postageStamp).code.length == 0) {
            admin = makeAddr("Admin");

            // TestToken testToken = new TestToken(); // v0.5.0
            // testToken.mint(admin, 1e36);
            TestToken testToken = new TestToken("BZZ TEST", "TBZZ", 1e36, admin);
            console.log(address(testToken), "TestToken newly deployed");

            vm.prank(admin);
            postageStamp = new PostageStamp(address(testToken), 16, admin);
            console.log(address(postageStamp), "PostageStamp newly deployed");
            console.log(admin, "Admin role defined");
        }

        oracle = readAddress("Oracle");
        if (oracle == address(0)) {
            oracle = makeAddr("Oracle");

            bytes32 oracleRole = postageStamp.PRICE_ORACLE_ROLE();

            vm.prank(admin);
            postageStamp.grantRole(oracleRole, oracle);
            console.log(oracle, "Oracle role defined");
        }

        bzzToken = IERC20(postageStamp.bzzToken());
        console.log(address(bzzToken), "BzzToken");
        minDepth = postageStamp.minimumBucketDepth();

        setUpSwarmBatchId0(address(this));
    }

    function setUpSwarmBatchId0(address stamper) public {
        deal(address(bzzToken), stamper, ttl0 << depth0);

        vm.prank(stamper);
        bzzToken.approve(address(postageStamp), ttl0 << depth0);

        vm.prank(stamper);
        postageStamp.createBatch(stamper, ttl0, depth0, minDepth, nonce, false);

        batchId0 = keccak256(abi.encode(stamper, nonce));
    }
}
