import 'viem/window';
import type { Address } from 'viem';
import { autoSwarmMarketAbi } from '$lib/ts/constants/abis';
import { sendWallet } from './send';
import { addressesGetField } from '../common/addresses';

const sendMarketNewBatch = async (bzzChainId: number, bzzAmount: bigint) => {
	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const autoSwarmMarket = (await addressesGetField(bzzChainId, 'AutoSwarmMarket')) as Address;
	const swarmNode = (await addressesGetField(bzzChainId, 'SwarmNode')) as Address;

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: autoSwarmMarket,
		abi: autoSwarmMarketAbi,
		functionName: 'newBatch',
		args: [swarmNode, bzzAmount]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export { sendMarketNewBatch };
