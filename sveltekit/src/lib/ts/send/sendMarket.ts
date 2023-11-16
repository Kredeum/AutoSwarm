import 'viem/window';
import type { Address } from 'viem';
import { autoSwarmMarketAbi } from '$lib/ts/constants/abis';
import { sendWallet } from './send';
import { jsonGetField } from '../constants/json';

const sendMarketNewBatch = async (chainId: number) => {
	const [publicClient, walletClient, walletAddress] = await sendWallet(chainId);

	const autoSwarmMarket = (await jsonGetField(chainId, 'AutoSwarmMarket')) as Address;

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: autoSwarmMarket,
		abi: autoSwarmMarketAbi,
		functionName: 'newBatch'
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export { sendMarketNewBatch };
