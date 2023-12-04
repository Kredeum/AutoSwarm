import { type Address, zeroAddress, type Hex } from 'viem';
import { autoSwarmAccountAbi } from '$lib/ts/constants/abis';
import { sendWallet } from './send';
import { utilsError } from '../common/utils';
import { jsonGetField } from '../common/json';

const sendTbaInitialize = async (
	bzzChainId: number,
	tba: Address | undefined,
	bzzHash: Hex | undefined,
	bzzSize: bigint | undefined
) => {
	// console.info("sendTbaInitialize:", bzzChainId, tba, bzzHash);

	if (!(bzzChainId > 0)) throw Error('Bad chain!');
	if (!tba) throw Error('No TBA!');
	if (!bzzHash) throw Error('No Swarm Hash!');
	if (!bzzSize) throw Error('No Swarm Size!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const autoSwarmMarket = jsonGetField(bzzChainId, 'AutoSwarmMarket') as Address;

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'initialize',
		args: [autoSwarmMarket, bzzHash, bzzSize]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaTopUp = async (bzzChainId: number, tba: Address | undefined, bzzAmount: bigint) => {
	if (!(bzzChainId > 0)) throw Error('Bad chain!');
	if (!tba) throw Error('Bad TBA!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'topUp',
		args: [bzzAmount]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaWithdraw = async (bzzChainId: number, tba: Address, token = zeroAddress) => {
	if (!(bzzChainId > 0 && tba)) utilsError('sendTbaWithdraw: No tba');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'withdraw',
		args: [token]
	});
	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

export { sendTbaTopUp, sendTbaWithdraw, sendTbaInitialize };
