// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC6551Registry} from "@erc6551/ERC6551Registry.sol";
import {AutoSwarmAccount} from "@autoswarm/src/AutoSwarmAccount.sol";
import {PostageStamp} from "@storage-incentives/PostageStamp.sol";
// import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";

import {console} from "forge-std/console.sol";

contract AutoSwarmHelper {
    struct Config {
        address owner;
        address registry;
        address implementation;
        address postageStamp;
    }

    function getConfigSlot(bytes32 slot) internal pure returns (Config storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    // bytes32(uint256(keccak256("AUTOSWARM_HELPER")) - 1));
    bytes32 private constant _AUTOSWARM_HELPER_SLOT = 0x6f941490d2819c2355cdebcdde9a60879d6d1c985ea58dd227c467fcb99feb3c;

    uint256 internal constant _SALT = 101;
    uint256 internal constant _MIN_DEPTH = 16;
    bool internal constant _IMMUTABLE = true;

    function setConfig(Config calldata config) external {
        Config storage cfg = getConfigSlot(_AUTOSWARM_HELPER_SLOT);

        if (cfg.owner == address(0)) cfg.owner = config.owner;
        else require(cfg.owner == msg.sender, "Unauthorized");

        cfg.registry = config.registry;
        cfg.implementation = config.implementation;
        cfg.postageStamp = config.postageStamp;
    }

    function getConfig() public pure returns (Config memory) {
        Config memory cfg = getConfigSlot(_AUTOSWARM_HELPER_SLOT);

        return cfg;
    }

    function getAccount(uint256 chainId, address collection, uint256 tokenId) public view returns (address tba) {
        Config memory cfg = getConfig();

        tba = ERC6551Registry(cfg.registry).account(cfg.implementation, chainId, collection, tokenId, _SALT);
    }

    function getAccountOrCreate(uint256 chainId, address collection, uint256 tokenId) public returns (address tba) {
        Config memory cfg = getConfig();

        tba = getAccount(chainId, collection, tokenId);
        if (tba.code.length == 0) {
            bytes memory data = abi.encodeWithSignature("initialize()");
            ERC6551Registry(cfg.registry).createAccount(cfg.implementation, chainId, collection, tokenId, _SALT, data);
        }
    }

    function approveBzz(address tba, address to, uint256 amount) public {
        console.log(msg.sender, "approveBzz ~ msg.sender");
        Config memory cfg = getConfig();
        console.log(cfg.owner, "approveBzz ~ cfg.owner");
        console.log(cfg.registry, "approveBzz ~ cfg.registry");
        console.log(cfg.implementation, "approveBzz ~ cfg.implementation");
        console.log(cfg.postageStamp, "approveBzz ~ cfg.postageStamp");

        address bzzToken = PostageStamp(cfg.postageStamp).bzzToken();

        // bzzToken.approve(postageStamp, amount);
        _execute(tba, bzzToken, abi.encodeWithSignature("approve(address,uint256)", cfg.postageStamp, amount));
    }

    function _execute(address tba, address to, bytes memory data) internal {
        console.log(tba, "_execute ~ tba:", tba.code.length);

        // AutoSwarmAccount(payable(tba)).execute(to, 0, data, 0);
        (bool success,) =
            tba.delegatecall(abi.encodeWithSignature("execute(address,uint256,bytes,uint256)", to, 0, data, 0));
        require(success, "delegatecall failed");
    }
}
