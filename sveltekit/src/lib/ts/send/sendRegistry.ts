import 'viem/window';
import type { Address } from 'viem';
import { erc6551RegistryAbi } from '$lib/ts/constants/abis';
import { callIsContract } from '$lib/ts/call/call';
import { SALT } from '../constants/constants';
import { addressesGetField } from '../common/addresses';
import { sendWallet } from './send';
import { callRegistryAccount } from '../call/callRegistry';

const sendRegistryCreateAccount = async (
	tbaChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<Address> => {
	const tba = await callRegistryAccount(tbaChainId, nftChainId, nftCollection, nftTokenId);

	if (await callIsContract(tbaChainId, tba)) return tba;

	const erc6551Registry = (await addressesGetField(tbaChainId, 'ERC6551Registry')) as Address;
	const autoSwarmAccount = (await addressesGetField(tbaChainId, 'AutoSwarmAccount')) as Address;

	const [publicClient, walletClient, walletAddress] = await sendWallet(tbaChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: erc6551Registry,
		abi: erc6551RegistryAbi,
		functionName: 'createAccount',
		args: [autoSwarmAccount, SALT, BigInt(nftChainId), nftCollection, nftTokenId]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash: hash });

	if (!(await callIsContract(tbaChainId, tba)))
		throw new Error('sendRegistryCreateAccount: Create failed');

	return tba;
};

// const bzzHash = ZERO_BYTES32;
// const bzzSize = 0n;
// const bzzAmount = 0n;
// const data = encodeFunctionData({
//   abi: autoSwarmAccountAbi,
//   functionName: 'initialize',
//   args: [json.PostageStamp as Address, bzzHash as Hex, bzzSize, bzzAmount]
// });

export { sendRegistryCreateAccount };
