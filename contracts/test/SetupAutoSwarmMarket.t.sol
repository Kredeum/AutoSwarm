// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {DeployLite} from "forge-deploy-lite/script/DeployLite.s.sol";
import {ReadWriteJson} from "forge-deploy-lite/script/ReadWriteJson.s.sol";
import {PostageStamp} from "storage-incentives/PostageStamp.sol";

import {DeployAll} from "@autoswarm/script/DeployAll.s.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {SetUpAutoSwarmAccount} from "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract SetUpAutoSwarmMarket is SetUpAutoSwarmAccount {
    AutoSwarmMarket public autoSwarmMarket;

    function setUpAutoSwarmMarket() public {
        console.log("setUpAutoSwarmMarket");
        autoSwarmMarket = AutoSwarmMarket(deploy("AutoSwarmMarket"));
        console.log("setUpAutoSwarmMarket ~ autoSwarmMarket:", address(autoSwarmMarket));
    }

    function setUp() public override(SetUpAutoSwarmAccount) {
        super.setUp();
        setUpAutoSwarmMarket();
    }
}
