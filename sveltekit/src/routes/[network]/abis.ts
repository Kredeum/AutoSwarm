import { parseAbi } from 'viem';

///////////////////////////////////////////////////////////////////////////////////////////////////
// ABIS : interfaces to onchain functions
///////////////////////////////////////////////////////////////////////////////////////////////////

const postageStampAbiBatcheslegacy = parseAbi([
	'function batches(bytes32) external view returns(address,uint8,bool,uint256)'
]);
const postageStampAbi = parseAbi([
	'function remainingBalance(bytes32) external view returns(uint256)',
	'function batches(bytes32) external view returns(address,uint8,uint8,bool,uint256,uint256)',
	'function topUp(bytes32,uint256) external'
]);
const registryAbi = parseAbi([
	'function account(address,uint256,address,uint256,uint256) external view returns (address)',
	'function createAccount(address,uint256,address,uint256,uint256, bytes calldata) external returns (address)'
]);
const bzzTokenAbi = parseAbi([
	'function balanceOf(address) external view returns(uint256)',
	'function approve(address,uint256) public returns (bool)'
]);
const autoSwarmAbi = parseAbi(['function stampsTopUp(bytes32,uint256) external']);

export { registryAbi, postageStampAbiBatcheslegacy, postageStampAbi, bzzTokenAbi, autoSwarmAbi };
