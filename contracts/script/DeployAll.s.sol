// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DeployNFTCollection} from "@autoswarm/script/deploy/00_DeployNFTCollection.s.sol";
import {DeployBzzToken} from "@autoswarm/script/deploy/01_DeployBzzToken.s.sol";
import {DeployPostageStamp} from "@autoswarm/script/deploy/02_DeployPostageStamp.s.sol";
import {DeployERC6551Registry} from "@autoswarm/script/deploy/03_DeployERC6551Registry.s.sol";
import {DeployAutoSwarmAccount} from "@autoswarm/script/deploy/04_DeployAutoSwarmAccount.s.sol";
import {DeployAutoSwarmMarket} from "@autoswarm/script/deploy/05_DeployAutoSwarmMarket.s.sol";

contract DeployAll is
    DeployNFTCollection,
    DeployBzzToken,
    DeployPostageStamp,
    DeployERC6551Registry,
    DeployAutoSwarmAccount,
    DeployAutoSwarmMarket
{
    function run()
        public
        override(DeployNFTCollection, DeployBzzToken, DeployPostageStamp, DeployERC6551Registry, DeployAutoSwarmAccount, DeployAutoSwarmMarket)
    {
        deploy("NFTCollection", false);
        deploy("BzzToken", false);
        deploy("PostageStamp", false);
        deploy("ERC6551Registry", false);
        deploy("AutoSwarmAccount");
        deploy("AutoSwarmMarket");
    }
}
