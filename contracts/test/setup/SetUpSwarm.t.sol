// SPDX-License-Identifier: MITs
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {DeployLiteRWJson} from "@forge-deploy-lite/DeployLiteRWJson.s.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

import {DeployAll} from "@autoswarm/script/DeployAll.s.sol";

// import {console} from "forge-std/console.sol";

contract SetUpSwarm is Test, DeployAll {
    PostageStamp public postageStamp;
    IERC20 public bzzToken;
    uint8 public minDepth;
    address public admin;
    address public oracle;

    function setUpSwarm() public {
        log3(msg.sender, "MsgSender", "SetUpSwarm");
        log3(address(this), "This", "SetUpSwarm");

        admin = msg.sender;
        oracle = readAddress("PriceOracle");

        postageStamp = PostageStamp(deployPostageStamp());

        bytes32 oracleRole = postageStamp.PRICE_ORACLE_ROLE();

        if (!postageStamp.hasRole(oracleRole, oracle)) {
            vm.prank(admin);
            postageStamp.grantRole(oracleRole, oracle);
            log3(oracle, "PriceOracle", "Grant role");
        }

        bzzToken = IERC20(postageStamp.bzzToken());

        minDepth = postageStamp.minimumBucketDepth();
    }
}
