import { type Address, zeroAddress, type Hex } from 'viem';
import { autoSwarmAccountAbi } from '$lib/ts/constants/abis';
import { sendWallet } from './send';
import { utilsError } from '../swarm/utils';
import { jsonGetField } from '../constants/json';

const sendTbaInitialize = async (
	chainId: number,
	tba: Address | undefined,
	bzzHash: Hex | undefined,
	bzzAmount: bigint
) => {
	if (!(chainId > 0)) throw Error('Bad chain!');
	if (!tba) throw Error('No TBA!');
	if (!bzzHash) throw Error('No SwarmHash!');
	console.log('sendTbaInitialize:', chainId, tba, bzzHash, bzzAmount);

	const [publicClient, walletClient, walletAddress] = await sendWallet(chainId);

	const autoSwarmMarket = jsonGetField(chainId, 'AutoSwarmMarket') as Address;

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'initialize',
		args: [autoSwarmMarket, bzzHash, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaTopUp = async (chainId: number, tba: Address | undefined, bzzAmount: bigint) => {
	if (!(chainId > 0)) throw Error('Bad chain!');
	if (!tba) throw Error('Bad TBA!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(chainId);

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

const sendTbaWithdraw = async (chainId: number, tba: Address, token = zeroAddress) => {
	if (!(chainId > 0 && tba)) utilsError('sendTbaWithdraw: No tba');

	const [publicClient, walletClient, walletAddress] = await sendWallet(chainId);

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
