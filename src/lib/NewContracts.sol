// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {BzzToken} from "src/BzzToken.sol";
import {NFTCollection} from "src/NFTCollection.sol";
import {ERC6551Registry} from "lib/erc6551/src/ERC6551Registry.sol";
import {SimpleERC6551Account} from "lib/erc6551/src/examples/simple/SimpleERC6551Account.sol";
import {PostageStamp} from "lib/storage-incentives/src/PostageStamp.sol";
import {AutoSwarm} from "src/AutoSwarm.sol";

contract NewContracts {
    function newBzzToken() public returns (IERC20) {
        return IERC20(address(new BzzToken()));
    }

    function newNFTCollection() public returns (NFTCollection collection) {
        collection = new NFTCollection();
        collection.mint(msg.sender);
    }

    function newERC6551Registry() public returns (ERC6551Registry) {
        return new ERC6551Registry();
    }

    function newSimpleERC6551Account() public returns (SimpleERC6551Account) {
        return new SimpleERC6551Account();
    }

    function newPostageStamp(address token_, address admin_) public returns (PostageStamp) {
        return new PostageStamp(token_, 16, admin_);
    }

    function newAutoSwarm(address registry_, address implementation_, address postageStamp_)
        public
        returns (AutoSwarm)
    {
        return new AutoSwarm(registry_,payable(implementation_),payable(postageStamp_));
    }
}
