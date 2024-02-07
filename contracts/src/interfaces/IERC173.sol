// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// https://eips.ethereum.org/EIPS/eip-173
/// @title ERC-173 Contract Ownership Standard 0x7f5828d0
interface IERC173 {
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function owner() external view returns (address);
    function transferOwnership(address _newOwner) external;
}
