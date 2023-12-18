import { zeroAddress, type Address } from 'viem';
import { erc20Abi } from '$lib/ts/constants/abis';
import { addressesGet } from '../common/addresses';
import { sendWallet } from './send';

const sendBzzApprove = async (bzzChainId: number, bzzAmount: bigint) => {
	// console.info('sendBzzApprove', bzzChainId,  bzzAmount);
	const json = await addressesGet(bzzChainId);

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

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

const sendBzzTransfer = async (
	bzzChainId: number,
	to: Address | undefined,
	bzzAmount: bigint | undefined
) => {
	console.info('sendBzzTransfer', bzzChainId, to, bzzAmount);

	if (bzzAmount === undefined) throw new Error('Transfer amount undefined');
	if (to === undefined || to === zeroAddress || bzzAmount === undefined)
		throw new Error('Bad address');
	const json = await addressesGet(bzzChainId);

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

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
