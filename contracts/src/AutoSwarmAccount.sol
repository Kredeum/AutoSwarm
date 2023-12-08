// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {ERC6551Account} from "@erc6551/examples/simple/ERC6551Account.sol";
import {IAutoSwarmAccount, IAutoSwarmMarket, IERC20} from "./interfaces/IAutoSwarmAccount.sol";

// import {console} from "forge-std/console.sol";

contract AutoSwarmAccount is IAutoSwarmAccount, ERC6551Account {
    bytes32 public bzzHash;
    uint256 public bzzSize;
    bytes32 public stampId;
    address public initializer;

    IAutoSwarmMarket internal _autoSwarmMarket;
    IERC20 internal _bzzToken;

    modifier onlyOwner() {
        require(msg.sender == owner() || msg.sender == initializer, "Not owner");
        _;
    }

    modifier onlyWhenInitialized() {
        require(address(_autoSwarmMarket) != address(0), "Not initialized");
        _;
    }

    function initialize(address autoSwarmMarket_, bytes32 bzzHash_, uint256 bzzSize_)
        external
        override(IAutoSwarmAccount)
    {
        require(address(_autoSwarmMarket) == address(0), "Already initialized");

        require(autoSwarmMarket_ != address(0), "Bad AutoSwarm Market");
        require(bzzHash_ != bytes32(0), "Bad Swarm Hash");
        require(bzzSize_ != 0, "Bad Swarm Size");

        initializer = msg.sender;

        bzzHash = bzzHash_;
        bzzSize = bzzSize_;

        _autoSwarmMarket = IAutoSwarmMarket(payable(autoSwarmMarket_));
        _bzzToken = IERC20(_autoSwarmMarket.bzzToken());

        require(address(_bzzToken) != address(0), "Bad BzzToken!");

        stampId = _autoSwarmMarket.createStamp(bzzHash, bzzSize, 0);
    }

    function topUp(uint256 bzzAmount) external override(IAutoSwarmAccount) onlyWhenInitialized {
        _bzzApproveMore(bzzAmount);
        _autoSwarmMarket.topUpStamp(stampId, bzzAmount);
    }

    function withdraw(address token) external {
        if (token == address(0)) {
            (bool success,) = owner().call{value: address(this).balance}("");
            require(success, "Withdraw failed!");
        } else {
            IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
        }
    }

    function getTopUpYearPrice() external view override(IAutoSwarmAccount) onlyWhenInitialized returns (uint256) {
        return _autoSwarmMarket.getStampPriceOneYear(bzzSize);
    }

    function owner() public view override returns (address) {
        address superOwner = super.owner();
        if (superOwner == address(0)) {
            return initializer;
        } else {
            return superOwner;
        }
    }

    function _bzzApproveMore(uint256 bzzAmount) internal onlyWhenInitialized {
        uint256 bzzAmountToApprove = _getBzzAllowance() + bzzAmount;
        require(bzzAmountToApprove <= _getBzzBalance(), "Not enough Bzz balance");

        _bzzToken.approve(address(_autoSwarmMarket), bzzAmountToApprove);
    }

    function _getBzzBalance() internal view returns (uint256) {
        return _bzzToken.balanceOf(address(this));
    }

    function _getBzzAllowance() internal view returns (uint256) {
        return _bzzToken.allowance(address(this), address(_autoSwarmMarket));
    }
}
