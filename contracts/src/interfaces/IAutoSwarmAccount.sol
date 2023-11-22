// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "./IERC20.sol";
import {IAutoSwarmMarket} from "./IAutoSwarmMarket.sol";

interface IAutoSwarmAccount {
    function initialize(address, bytes32, uint256) external;

    function swarmHash() external returns (bytes32);
    function swarmSize() external returns (uint256);

    function topUp(uint256) external;

    function getTopUpYearPrice() external view returns (uint256);
}
