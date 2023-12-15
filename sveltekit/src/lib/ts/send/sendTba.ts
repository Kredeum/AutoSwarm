import { type Address, zeroAddress, type Hex } from 'viem';
import { autoSwarmAccountAbi } from '$lib/ts/constants/abis';
import { sendWallet } from './send';

const sendTbaSetAutoSwarm = async (
	bzzChainId: number,
	tba: Address | undefined,
	bzzHash: Hex | undefined,
	bzzSize: bigint | undefined
) => {
	console.info('sendTbaSetAutoSwarm:', bzzChainId, tba, bzzHash, bzzSize);

	if (!(bzzChainId > 0)) throw new Error('Bad chain!');
	if (!tba) throw new Error('No TBA!');
	if (!bzzHash) throw new Error('No Swarm Hash!');
	if (!bzzSize) throw new Error('No Swarm Size!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'setAutoSwarm',
		args: [bzzHash, bzzSize]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaSetAutoSwarmStamp = async (
	bzzChainId: number,
	tba: Address | undefined,
	bzzHash: Hex | undefined,
	bzzSize: bigint | undefined,
	bzzAmount: bigint | undefined
) => {
	console.info('sendTbaSetAutoSwarm:', bzzChainId, tba, bzzHash, bzzSize, bzzAmount);

	if (!(bzzChainId > 0)) throw new Error('Bad chain!');
	if (!tba) throw new Error('No TBA!');
	if (!bzzHash) throw new Error('No Swarm Hash!');
	if (!bzzSize) throw new Error('No Swarm Size!');
	if (!bzzAmount) throw new Error('No BZZ!');

	const [publicClient, walletClient, walletAddress] = await sendWallet(bzzChainId);

	const { request } = await publicClient.simulateContract({
		account: walletAddress,
		address: tba,
		abi: autoSwarmAccountAbi,
		functionName: 'setAutoSwarmStamp',
		args: [bzzHash, bzzSize, bzzAmount]
	});

	const hash = await walletClient.writeContract(request);
	await publicClient.waitForTransactionReceipt({ hash });
};

const sendTbaTopUp = async (bzzChainId: number, tba: Address | undefined, bzzAmount: bigint) => {
	if (!(bzzChainId > 0)) throw new Error('Bad chain!');
	if (!tba) throw new Error('Bad TBA!');

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
	if (!(bzzChainId > 0 && tba)) throw new Error('sendTbaWithdraw: No tba');

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

export { sendTbaTopUp, sendTbaWithdraw, sendTbaSetAutoSwarm, sendTbaSetAutoSwarmStamp };
