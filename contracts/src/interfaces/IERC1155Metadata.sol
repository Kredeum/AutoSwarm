// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// https://eips.ethereum.org/EIPS/eip-1155
/// @title ERC-1155 Metadata Option 0x0e89341c
interface IERC1155Metadata {
    function uri(uint256) external view returns (string memory);
}
