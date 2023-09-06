// SPDX-License-Identifier: MITs
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {ReadWriteJson} from "lib/forge-deploy-lite/script/ReadWriteJson.sol";
import {DeployLite} from "lib/forge-deploy-lite/script/DeployLite.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {AutoSwarm} from "src/AutoSwarm.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";
import {TestToken} from "lib/storage-incentives/src/TestToken.sol";

contract SetupSwarmTest is Test, DeployLite {
    AutoSwarm public autoSwarm;
    PostageStamp public postageStamp;
    IERC20 public bzzToken;
    uint8 public minDepth;
    address public admin;
    address public oracle;

    function setUp() public {
        admin = readAddress("Admin");

        postageStamp = PostageStamp(readAddress("PostageStamp"));
        if (address(postageStamp).code.length == 0) {
            admin = makeAddr("Admin");

            // TestToken testToken = new TestToken(); // v0.5.0
            // testToken.mint(admin, 1e36);
            TestToken testToken = new TestToken("BZZ TEST", "TBZZ", 1e36, admin);

            vm.prank(admin);
            postageStamp = new PostageStamp(address(testToken), 16, admin);
        }

        oracle = readAddress("Oracle");
        if (oracle == address(0)) {
            oracle = makeAddr("Oracle");

            bytes32 oracleRole = postageStamp.PRICE_ORACLE_ROLE();

            vm.prank(admin);
            postageStamp.grantRole(oracleRole, oracle);
        }

        autoSwarm = AutoSwarm(readAddress("AutoSwarm"));
        if (address(autoSwarm).code.length == 0) {
            autoSwarm = new AutoSwarm(address(postageStamp));
        }

        bzzToken = IERC20(postageStamp.bzzToken());
        minDepth = postageStamp.minimumBucketDepth();
    }

    function test_setup() public view {
        bytes memory codeToDeploy;

        (,, codeToDeploy) = isDeployed("PostageStamp");
        require(keccak256(codeToDeploy) == keccak256(address(postageStamp).code), "PostageStamp code differs");

        (,, codeToDeploy) = isDeployed("AutoSwarm");
        require(keccak256(codeToDeploy) == keccak256(address(autoSwarm).code), "AutoSwarm code differs");

        (,, codeToDeploy) = isDeployed("TestToken");
        require(keccak256(codeToDeploy) == keccak256(address(bzzToken).code), "BzzToken code differs");

        require(postageStamp.bzzToken() == address(bzzToken), "BzzToken not linked by PostageStamp");
        require(bzzToken.totalSupply() > 0, "BzzToken totalSupply is zero");
        require(minDepth >= 16, "MinDepth must be more than 16");

        require(postageStamp.hasRole(postageStamp.PRICE_ORACLE_ROLE(), oracle), "Oracle has not Oracle_Role");
        require(postageStamp.hasRole(postageStamp.DEFAULT_ADMIN_ROLE(), admin), "Admin has not Admin_Role");
    }
}
