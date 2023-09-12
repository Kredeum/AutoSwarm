// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.s.sol";
import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.s.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";

import {DeployAll} from "script/DeployAll.s.sol";

contract SetUpSwarm is Test, DeployAll {
    PostageStamp public postageStamp;
    IERC20 public bzzToken;
    uint8 public minDepth;
    address public admin;
    address public oracle;

    function setUpSwarm() public {
        log3(msg.sender, "MsgSender", "SetUpSwarm");
        log3(address(this), "This", "SetUpSwarm");

        admin = getAddress("Admin");
        oracle = getAddress("Oracle");

        postageStamp = PostageStamp(deploy("PostageStamp", false));

        bytes32 oracleRole = postageStamp.PRICE_ORACLE_ROLE();

        if (!postageStamp.hasRole(oracleRole, oracle)) {
            vm.prank(admin);
            postageStamp.grantRole(oracleRole, oracle);
            log3(oracle, "Oracle", "Grant role");
        }

        bzzToken = IERC20(postageStamp.bzzToken());
        minDepth = postageStamp.minimumBucketDepth();

        // batchId0 = setUpSwarmBatchId(address(this));
    }
}
