// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC6551Account} from "@erc6551/examples/simple/ERC6551Account.sol";
import {IAutoSwarmAccount, IAutoSwarmMarket, IERC20} from "./interfaces/IAutoSwarmAccount.sol";

import {console} from "forge-std/console.sol";

contract AutoSwarmAccount is IAutoSwarmAccount, ERC6551Account {
    bytes32 public swarmHash;
    uint256 public swarmSize;
    bytes32 public myStampId;

    IAutoSwarmMarket internal _autoSwarmMarket;
    IERC20 internal _bzzToken;

    modifier onlyOwner() {
        require(msg.sender == owner(), "Not owner");
        _;
    }

    modifier onlyWhenInitialized() {
        require(address(_autoSwarmMarket) != address(0), "Not initialized");
        _;
    }

    function initialize(address autoSwarmMarket_, bytes32 swarmHash_, uint256 swarmSize_, uint256 bzzAmount)
        external
        override(IAutoSwarmAccount)
    {
        require(address(_autoSwarmMarket) == address(0), "Already initialized");

        require(autoSwarmMarket_ != address(0), "Bad AutoSwarm Market");
        require(swarmHash_ != bytes32(0), "Bad Swarm hash");
        require(swarmSize_ > 0, "Bad Swarm size");

        swarmHash = swarmHash_;
        swarmSize = swarmSize_;

        _autoSwarmMarket = IAutoSwarmMarket(payable(autoSwarmMarket_));
        _bzzToken = IERC20(_autoSwarmMarket.bzzToken());

        require(address(_bzzToken) != address(0), "Bad BzzToken");

        bzzApproveMore(bzzAmount);
        myStampId = _autoSwarmMarket.createStamp(swarmHash, swarmSize, bzzAmount);
    }

    function bzzApproveMore(uint256 bzzAmount) public onlyWhenInitialized {
        uint256 bzzAmountToApprove = getBzzAllowance() + bzzAmount;
        require(bzzAmountToApprove <= getBzzBalance(), "Not enough Bzz balance");

        _bzzToken.approve(address(_autoSwarmMarket), bzzAmountToApprove);
    }

    function topUp(uint256 bzzAmount) public override(IAutoSwarmAccount) onlyWhenInitialized {
        bzzApproveMore(bzzAmount);
        _autoSwarmMarket.topUpStamp(myStampId, bzzAmount);
    }

    function getTopUpYearPrice() public view override(IAutoSwarmAccount) onlyWhenInitialized returns (uint256) {
        return _autoSwarmMarket.getStampPriceOneYear(swarmSize);
    }

    function getBzzBalance() public view override(IAutoSwarmAccount) returns (uint256) {
        return _bzzToken.balanceOf(address(this));
    }

    function getBzzAllowance() public view override(IAutoSwarmAccount) returns (uint256) {
        return _bzzToken.allowance(address(this), address(_autoSwarmMarket));
    }
}
