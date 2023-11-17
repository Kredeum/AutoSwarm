import type { Address } from 'viem';
import { erc20Abi } from '$lib/ts/constants/abis';
import { jsonGet } from '../constants/json';
import { sendWallet } from './send';

const sendBzzApprove = async (chainId: number, bzzAmount: bigint) => {
	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await sendWallet(chainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: json.BzzToken as Address,
		abi: erc20Abi,
		functionName: 'approve',
		args: [json.PostageStamp as Address, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendBzzTransfer = async (chainId: number, to: Address, bzzAmount: bigint) => {
	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await sendWallet(chainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: json.BzzToken as Address,
		abi: erc20Abi,
		functionName: 'transfer',
		args: [to as Address, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export { sendBzzApprove, sendBzzTransfer };
