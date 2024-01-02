// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AutoSwarmAccount} from "../AutoSwarmAccount.sol";
import {AutoSwarmMarket} from "../AutoSwarmMarket.sol";

interface IAutoSwarmAccount {
    event SetAutoSwarmMarket(address indexed);
    event CreateStamp(bytes32 indexed, bytes32 indexed, uint256 indexed, uint256);
    event UpdateStamp(bytes32 indexed, bytes32 indexed, uint256 indexed);
    event TopUp(bytes32 indexed, uint256 indexed);
    event Withdraw(address indexed, uint256 indexed);

    error StampExists();
    error NotTba();
    error NotOwner();
    error NotMarketOwner();
    error SwarmSizeZero();
    error SwarmHashNull();
    error AutoSwarmMarketNull();
    error NotEnoughBalance(uint256, uint256);
    error AmountZero();

    function isTba() external view returns (bool);
    function swarmSize() external view returns (uint256);
    function swarmHash() external view returns (bytes32);
    function stampId() external view returns (bytes32);
    function getOneYearPrice() external view returns (uint256);
    function getMarketOwner() external view returns (address);
    function getBzzToken() external view returns (IERC20);
    function getImplementation() external view returns (AutoSwarmAccount);
    function getAutoSwarmMarket() external view returns (AutoSwarmMarket);

    function setAutoSwarmMarket(AutoSwarmMarket) external;
    function createStamp(bytes32, uint256, uint256) external returns (bytes32);
    function updateStamp(bytes32, uint256) external;
    function topUp(uint256) external;
    function withdraw(address) external returns (uint256);
}
