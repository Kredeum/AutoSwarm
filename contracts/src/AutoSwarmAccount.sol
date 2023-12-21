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

    modifier onlyBzzAdmin() {
        require(msg.sender == bzzAdmin(), "Not BZZ admin");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "Not owner");
        _;
    }

    constructor(address autoSwarmMarket_) {
        _setAutoSwarmMarket(autoSwarmMarket_);
    }

    function setAutoSwarmMarket(address autoSwarmMarket_) external onlyBzzAdmin {
        _setAutoSwarmMarket(autoSwarmMarket_);
    }

    function setAutoSwarmStamp(uint256 swarmSize_, bytes32 swarmHash_, uint256 bzzAmount_) external onlyBzzAdmin {
        _setAutoSwarm(swarmSize_, swarmHash_);
        stampId = IAutoSwarmMarket(autoSwarmMarket()).createStamp(swarmHash_, swarmSize_, bzzAmount_);
    }

    function setAutoSwarm(uint256 swarmSize_, bytes32 swarmHash_) external {
        require(stampId == bytes32(0), "Stamp already set");
        _setAutoSwarm(swarmSize_, swarmHash_);
    }

    function topUp(uint256 bzzAmount) external override(IAutoSwarmAccount) {
        _bzzApproveMore(bzzAmount);
        IAutoSwarmMarket(autoSwarmMarket()).topUpStamp(stampId, bzzAmount);
    }

    function withdraw(address tok) external {
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

    function owner() public view override returns (address) {
        address superOwner = super.owner();

        return (superOwner == address(0)) ? bzzAdmin() : superOwner;
    }

    function implementation() public view returns (address addr) {
        if (address(this).code.length != _ERC6551_TBA_SIZE) return address(0);

        addr = address(uint160(uint256(bytes32(address(this).code)) >> 16));
    }

    function autoSwarmMarket() public view returns (address) {
        return _autoSwarmMarket == address(0) ? IAutoSwarmAccount(implementation()).autoSwarmMarket() : _autoSwarmMarket;
    }

    function bzzAdmin() public view returns (address) {
        return IERC173(autoSwarmMarket()).owner();
    }

    function _setAutoSwarm(uint256 swarmSize_, bytes32 swarmHash_) internal {
        require(swarmSize_ != 0, "Bad Swarm Size");
        require(swarmHash_ != bytes32(0), "Bad Swarm Hash");

        swarmSize = swarmSize_;
        swarmHash = swarmHash_;
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
