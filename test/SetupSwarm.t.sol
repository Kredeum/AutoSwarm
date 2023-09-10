// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.s.sol";
import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";

import {NewContracts} from "src/lib/NewContracts.sol";
import {DeployAll} from "script/DeployAll.s.sol";

contract SetUpSwarm is Test, DeployAll {
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
        console.log(msg.sender, "SetUpSwarm   msg.sender");
        console.log(address(this), "SetUpSwarm   this");

        admin = getAddress("Admin");
        postageStamp = PostageStamp(deploy("PostageStamp"));

        oracle = readAddress("Oracle");
        if (oracle == address(0)) {
            oracle = makeAddr("Oracle");

            bytes32 oracleRole = postageStamp.PRICE_ORACLE_ROLE();

            vm.prank(admin);
            postageStamp.grantRole(oracleRole, oracle);
            console.log(oracle, "New role     Oracle");
        }

        bzzToken = IERC20(postageStamp.bzzToken());
        minDepth = postageStamp.minimumBucketDepth();

        batchId0 = setUpSwarmBatchId(address(this));
    }

    function setUpSwarmBatchId(address stamper) public returns (bytes32) {
        deal(address(bzzToken), stamper, ttl0 << depth0);

        vm.prank(stamper);
        bzzToken.approve(address(postageStamp), ttl0 << depth0);

        vm.prank(stamper);
        postageStamp.createBatch(stamper, ttl0, depth0, minDepth, nonce, false);

        return keccak256(abi.encode(stamper, nonce));
    }
}
