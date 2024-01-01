// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IAutoSwarmMarket} from "./interfaces/IAutoSwarmMarket.sol";
import {IAutoSwarmAccount} from "./interfaces/IAutoSwarmAccount.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import {ERC6551Account} from "@erc6551/examples/simple/ERC6551Account.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmAccount is IAutoSwarmAccount, ERC6551Account {
    bytes32 public swarmHash;
    uint256 public swarmSize;
    bytes32 public stampId;

    uint256 private constant _ERC6551_TBA_SIZE = 173;
    address private _autoSwarmMarket; // only getImplementation can set this

    modifier onlyMarketOwner() {
        require(msg.sender == getMarketOwner(), "Not BZZ admin");
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
        require(swarmHash_ != bytes32(0), "Bad Swarm Hash");
        require(swarmSize_ != 0, "Bad Swarm Size");

        swarmHash = swarmHash_;
        swarmSize = swarmSize_;
        _bzzApproveMore(bzzAmount_);
        stampId = IAutoSwarmMarket(getAutoSwarmMarket()).createStamp(swarmHash_, swarmSize_, bzzAmount_);

        emit CreateStamp(stampId, swarmHash_, swarmSize_, bzzAmount_);
        return stampId;
    }

    function updateStamp(bytes32 swarmHash_, uint256 swarmSize_) external override(IAutoSwarmAccount) onlyMarketOwner {
        swarmHash = swarmHash_;
        swarmSize = swarmSize_;

        emit UpdateStamp(stampId, swarmHash, swarmSize_);
        IAutoSwarmMarket(getAutoSwarmMarket()).updateStamp(stampId, swarmHash_, swarmSize_);
    }

    function topUp(uint256 bzzAmount) external override(IAutoSwarmAccount) {
        _bzzApproveMore(bzzAmount);

        emit TopUp(stampId, bzzAmount);
        IAutoSwarmMarket(getAutoSwarmMarket()).topUpStamp(stampId, bzzAmount);
    }

    function withdraw(address token) external override(IAutoSwarmAccount) returns (uint256 amount) {
        if (token == address(0)) {
            amount = address(this).balance;
            Address.sendValue(payable(owner()), amount);
        } else {
            amount = IERC20(token).balanceOf(address(this));
            SafeERC20.safeTransfer(IERC20(token), owner(), amount);
        }
        emit Withdraw(token, amount);
    }

    function getTopUpYearPrice() external view override(IAutoSwarmAccount) returns (uint256) {
        return IAutoSwarmMarket(getAutoSwarmMarket()).getStampPriceOneYear(swarmSize);
    }

    function owner() public view override(ERC6551Account) returns (address) {
        address superOwner = super.owner();

        return (superOwner == address(0)) ? getMarketOwner() : superOwner;
    }

    function getImplementation() public view returns (address addr) {
        if (address(this).code.length != _ERC6551_TBA_SIZE) return address(0);

        addr = address(uint160(uint256(bytes32(address(this).code)) >> 16));
    }

    function getAutoSwarmMarket() public view override(IAutoSwarmAccount) returns (address) {
        return _autoSwarmMarket == address(0)
            ? IAutoSwarmAccount(getImplementation()).getAutoSwarmMarket()
            : _autoSwarmMarket;
    }

    function getMarketOwner() public view override(IAutoSwarmAccount) returns (address) {
        return ERC6551Account(payable(getAutoSwarmMarket())).owner();
    }

    function _bzzApproveMore(uint256 bzzAmount) internal {
        uint256 bzzAmountToApprove = _getBzzAllowance() + bzzAmount;
        require(bzzAmountToApprove <= _getBzzBalance(), "Not enough BZZ balance");

        _bzzToken().approve(getAutoSwarmMarket(), bzzAmountToApprove);
    }

    function _bzzToken() internal view returns (IERC20) {
        return IAutoSwarmMarket(getAutoSwarmMarket()).bzzToken();
    }

    function _getBzzBalance() internal view returns (uint256) {
        return _bzzToken().balanceOf(address(this));
    }

    function _getBzzAllowance() internal view returns (uint256) {
        return _bzzToken().allowance(address(this), getAutoSwarmMarket());
    }

    function _setAutoSwarmMarket(address autoSwarmMarket) private {
        require(autoSwarmMarket != address(0), "Bad AutoSwarm Market");

        _autoSwarmMarket = autoSwarmMarket;

        emit AutoSwarmMarket(autoSwarmMarket);
    }
}
