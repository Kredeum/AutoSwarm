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
	'function lastPrice() external view returns (uint256)',
	'function topUp(bytes32,uint256) external'
]);
const erc721Abi = parseAbi([
	'function ownerOf(uint256) external view returns (address)',
	'function tokenURI(uint256) external view returns (string)'
]);
const erc6551RegistryAbi = parseAbi([
	'function account(address,uint256,address,uint256,uint256) external view returns (address)',
	'function createAccount(address,uint256,address,uint256,uint256, bytes calldata) external returns (address)'
]);
const bzzTokenAbi = parseAbi([
	'function balanceOf(address) external view returns(uint256)',
	'function approve(address,uint256) public returns (bool)',
	'function transfer(address,uint256) public returns (bool)'
]);
const autoSwarmAbi = parseAbi([
	'function initialize(address) external',
  'function stampsBuy(uint256,uint8) external returns (bytes32)',
	'function stampsTopUp(bytes32,uint256) external',
  'function stampsIncreaseDepth(bytes32,uint8) external',
	'function withdrawBzz() external'
]);

export {
	erc721Abi,
	erc6551RegistryAbi,
	postageStampAbiBatcheslegacy,
	postageStampAbi,
	bzzTokenAbi,
	autoSwarmAbi
};
