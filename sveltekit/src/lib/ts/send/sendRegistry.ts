import 'viem/window';
import type { Address } from 'viem';
import { erc6551RegistryAbi } from '$lib/ts/constants/abis';
import { callIsContract } from '$lib/ts/call/call';
import { SALT } from '../constants/constants';
import { utilsError } from '../common/utils';
import { jsonGetField } from '../common/json';
import { sendWallet } from './send';
import { callRegistryAccount } from '../call/callRegistry';

const sendRegistryCreateAccount = async (
	bzzChainId: number,
	nftChainId: number,
	nftCollection: Address,
	nftTokenId: bigint
): Promise<Address> => {
	const tba = await callRegistryAccount(bzzChainId, nftChainId, nftCollection, nftTokenId);

	if (await callIsContract(bzzChainId, tba)) return tba;

	const erc6551Registry = (await jsonGetField(bzzChainId, 'ERC6551Registry')) as Address;
	const autoSwarmAccount = (await jsonGetField(bzzChainId, 'AutoSwarmAccount')) as Address;

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: erc6551Registry,
		abi: erc6551RegistryAbi,
		functionName: 'createAccount',
		args: [autoSwarmAccount, SALT, BigInt(nftChainId), nftCollection, nftTokenId]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash: hash });

	if (!(await callIsContract(bzzChainId, tba)))
		utilsError('sendRegistryCreateAccount: Create failed');

	return tba;
};

// const bzzHash = ZERO_BYTES32;
// const swarmSize = 0n;
// const bzzAmount = 0n;
// const data = encodeFunctionData({
//   abi: autoSwarmAccountAbi,
//   functionName: 'initialize',
//   args: [json.PostageStamp as Address, bzzHash as Hex, swarmSize, bzzAmount]
// });

export { sendRegistryCreateAccount };
