// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {DeployLite} from "@forge-deploy-lite/DeployLite.s.sol";
import {ReadWriteJson} from "@forge-deploy-lite/ReadWriteJson.s.sol";
import {PostageStamp} from "@storage-incentives/PostageStamp.sol";

import {DeployAll} from "@autoswarm/script/DeployAll.s.sol";
import {AutoSwarmMarket} from "@autoswarm/src/AutoSwarmMarket.sol";
import {SetUpAutoSwarmAccount} from "@autoswarm/test/SetUpAutoSwarmAccount.t.sol";

contract SetUpAutoSwarmMarket is SetUpAutoSwarmAccount {
    AutoSwarmMarket public autoSwarmMarket;
    uint256 initYear;
    uint256 initTtl;
    uint8 initDepth;

    function setUpAutoSwarmMarket() public {
        autoSwarmMarket = AutoSwarmMarket(deploy("AutoSwarmMarket"));

        initYear = autoSwarmMarket.FIRST_YEAR();
        initTtl = autoSwarmMarket.INITIAL_TTL();
        initDepth = autoSwarmMarket.INITIAL_DEPTH();

        deal(address(bzzToken), address(autoSwarmMarket), initTtl << initDepth);

        vm.prank(deployer);
        autoSwarmMarket.buyBatch(initYear);
    }
}
