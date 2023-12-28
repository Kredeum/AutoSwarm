// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "./interfaces/IERC20.sol";
import {IERC173} from "./interfaces/IERC173.sol";
import {IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {IAutoSwarmAccount} from "./interfaces/IAutoSwarmAccount.sol";
import {ERC6551Account} from "@erc6551/examples/simple/ERC6551Account.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmAccount is IAutoSwarmAccount, ERC6551Account {
    bytes32 public swarmHash;
    uint256 public swarmSize;
    bytes32 public stampId;

    uint256 private constant _ERC6551_TBA_SIZE = 173;
    address private _autoSwarmMarket; // only implementation can set this

    modifier onlyMarketOwner() {
        require(msg.sender == marketOwner(), "Not BZZ admin");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Not owner");
        _;
    }

    constructor(address autoSwarmMarket_) {
        _setAutoSwarmMarket(autoSwarmMarket_);
    }

    function setAutoSwarmMarket(address autoSwarmMarket_) external override(IAutoSwarmAccount) onlyMarketOwner {
        _setAutoSwarmMarket(autoSwarmMarket_);
    }

    function createStamp(bytes32 swarmHash_, uint256 swarmSize_, uint256 bzzAmount_)
        external
        override(IAutoSwarmAccount)
        returns (bytes32)
    {
        require(stampId == bytes32(0), "Stamp already set");
        require(swarmSize_ != 0, "Bad Swarm Size");
        require(swarmHash_ != bytes32(0), "Bad Swarm Hash");

        swarmHash = swarmHash_;
        swarmSize = swarmSize_;
        _bzzApproveMore(bzzAmount_);
        stampId = IAutoSwarmMarket(autoSwarmMarket()).createStamp(swarmHash_, swarmSize_, bzzAmount_);

        return stampId;
    }

    function updateStamp(bytes32 swarmHash_, uint256 swarmSize_) external override(IAutoSwarmAccount) onlyMarketOwner {
        swarmHash = swarmHash_;
        swarmSize = swarmSize_;
        IAutoSwarmMarket(autoSwarmMarket()).updateStamp(stampId, swarmHash_, swarmSize_);
    }

    function topUp(uint256 bzzAmount) external override(IAutoSwarmAccount) {
        _bzzApproveMore(bzzAmount);
        IAutoSwarmMarket(autoSwarmMarket()).topUpStamp(stampId, bzzAmount);
    }

    function withdraw(address tok) external override(IAutoSwarmAccount) {
        if (tok == address(0)) {
            (bool success,) = owner().call{value: address(this).balance}("");
            require(success, "Withdraw failed!");
        } else {
            IERC20(tok).transfer(owner(), IERC20(tok).balanceOf(address(this)));
        }
    }

    function getTopUpYearPrice() external view override(IAutoSwarmAccount) returns (uint256) {
        return IAutoSwarmMarket(autoSwarmMarket()).getStampPriceOneYear(swarmSize);
    }

    function owner() public view override(ERC6551Account) returns (address) {
        address superOwner = super.owner();

        return (superOwner == address(0)) ? marketOwner() : superOwner;
    }

    function implementation() public view returns (address addr) {
        if (address(this).code.length != _ERC6551_TBA_SIZE) return address(0);

        addr = address(uint160(uint256(bytes32(address(this).code)) >> 16));
    }

    function autoSwarmMarket() public view override(IAutoSwarmAccount) returns (address) {
        return _autoSwarmMarket == address(0) ? IAutoSwarmAccount(implementation()).autoSwarmMarket() : _autoSwarmMarket;
    }

    function marketOwner() public view override(IAutoSwarmAccount) returns (address) {
        return IERC173(autoSwarmMarket()).owner();
    }

    function _bzzApproveMore(uint256 bzzAmount) internal {
        uint256 bzzAmountToApprove = _getBzzAllowance() + bzzAmount;
        require(bzzAmountToApprove <= _getBzzBalance(), "Not enough BZZ balance");

        _bzzToken().approve(autoSwarmMarket(), bzzAmountToApprove);
    }

    function _bzzToken() internal view returns (IERC20) {
        return IAutoSwarmMarket(autoSwarmMarket()).bzzToken();
    }

    function _getBzzBalance() internal view returns (uint256) {
        return _bzzToken().balanceOf(address(this));
    }

    function _getBzzAllowance() internal view returns (uint256) {
        return _bzzToken().allowance(address(this), autoSwarmMarket());
    }

    function _setAutoSwarmMarket(address autoSwarmMarket_) private {
        require(autoSwarmMarket_ != address(0), "Bad AutoSwarm Market");

        _autoSwarmMarket = autoSwarmMarket_;
    }
}
