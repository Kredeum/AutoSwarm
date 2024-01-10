import type { Address, Hex } from 'viem';
import { postageStampAbi } from '$lib/ts/constants/abis';
import { sendWallet } from './send';
import { addressesGetField } from '../common/addresses';
import { BUCKET_DEPTH } from '../constants/constants';

const sendPostageCreateBatch = async (
	bzzChainId: number,
	owner: Address,
	initialBalancePerChunk: bigint,
	depth: number,
	nonce: Hex
) => {
	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const postageStamp = addressesGetField(bzzChainId, 'PostageStamp');

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: postageStamp,
		abi: postageStampAbi,
		functionName: 'createBatch',
		args: [owner, initialBalancePerChunk, depth, BUCKET_DEPTH, nonce, false]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export { sendPostageCreateBatch };
