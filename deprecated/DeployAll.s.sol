// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployNFTCollection} from "./deploy/00_DeployNFTCollection.s.sol";
import {DeployBzzToken} from "./deploy/01_DeployBzzToken.s.sol";
import {DeployERC6551Registry} from "./deploy/02_DeployERC6551Registry.s.sol";
import {DeploySimpleERC6551Account} from "./deploy/03_DeploySimpleERC6551Account.s.sol";
import {DeployPostageStamp} from "./deploy/04_DeployPostageStamp.s.sol";
import {DeployAutoSwarm} from "./deploy/05_DeployAutoSwarm.s.sol";

contract DeployAll is
    DeployBzzToken,
    DeployNFTCollection,
    DeployERC6551Registry,
    DeploySimpleERC6551Account,
    DeployPostageStamp,
    DeployAutoSwarm
{
    function run()
        public
        override(
            DeployBzzToken,
            DeployNFTCollection,
            DeployERC6551Registry,
            DeploySimpleERC6551Account,
            DeployPostageStamp,
            DeployAutoSwarm
        )
    {
        logCallers("DeployAll callers");

        deploy("BzzToken", false);
        deploy("NFTCollection", false);
        deploy("ERC6551Registry");
        deploy("SimpleERC6551Account");
        deploy("PostageStamp", false);
        deploy("AutoSwarm");

        writeAddresses();
    }
}
