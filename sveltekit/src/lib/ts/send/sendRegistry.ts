import 'viem/window';
import {
	type Address,
	BaseError,
	ContractFunctionRevertedError,
	encodeFunctionData,
	type Hex
} from 'viem';
import { autoSwarmAccountAbi, erc6551RegistryAbi } from '$lib/ts/constants/abis';
import { callIsContract } from '$lib/ts/call/call';
import { SALT, ZERO_BYTES32 } from '../constants/constants';
import { utilsError } from '../swarm/utils';
import { jsonGet } from '../constants/json';
import { sendWallet } from './send';

const sendRegistryCreateAccount = async (
	chainId: number,
	collection: Address,
	tokenId: bigint,
	tba: Address
): Promise<Address> => {
	if (await callIsContract(chainId, tba)) return tba;

	const json = await jsonGet(chainId);

	const [publicClient, walletClient, walletAddress] = await sendWallet(chainId);

	try {
		const swarmHash = ZERO_BYTES32;
		const swarmSize = 0n;
		const bzzAmount = 0n;
		const data = encodeFunctionData({
			abi: autoSwarmAccountAbi,
			functionName: 'initialize',
			args: [json.PostageStamp as Address, swarmHash as Hex, swarmSize, bzzAmount]
		});

		const { request } = await publicClient.simulateContract({
			account: walletAddress,
			address: json.ERC6551Registry as Address,
			abi: erc6551RegistryAbi,
			functionName: 'createAccount',
			args: [json.AutoSwarmAccount as Address, BigInt(chainId), collection, tokenId, SALT, data]
		});
		const hash = await walletClient.writeContract(request);
		await publicClient.waitForTransactionReceipt({ hash: hash });
	} catch (err) {
		if (err instanceof BaseError) {
			const revertError = err.walk((err) => err instanceof ContractFunctionRevertedError);
			if (revertError instanceof ContractFunctionRevertedError) {
				const errorName = revertError.data?.errorName ?? '';
				console.error('sendRegistryCreateAccount ~ errorName:', errorName);
			}
		}
	}

	if (!(await callIsContract(chainId, tba))) utilsError('Create failed');

	return tba;
};

export { sendRegistryCreateAccount };
