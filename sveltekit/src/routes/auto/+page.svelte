<script lang="ts">
	import {
		createPublicClient,
		http,
		getContract,
		parseAbi,
		type Hex,
		type Address,
		formatUnits
	} from 'viem';
	import { gnosis, sepolia } from 'viem/chains';
	import { onMount } from 'svelte';
	import jsonFile from '../../../../addresses.json';

	const chain = gnosis;
	const json = jsonFile[chain.id];
	const publicClient = createPublicClient({
		chain,
		transport: http()
	});

	const postageStamp = getContract({
		address: json.PostageStamp as Address,
		abi: parseAbi([
			'function remainingBalance(bytes32) external view returns(uint256)',
			'function batches(bytes32) external view returns(address,uint8,bool,uint256)'
		]),
		publicClient
	});

	let blockNumber: bigint = 0n;
	let bal: bigint;
	let balj: number;

	let owner: Address;
	let depth: number;
	let immutable: boolean;
	let rBal: bigint;
	let rBalj: number;
	let bzz0: bigint;
	let bzzAmount0: string;
	let bzz: bigint;
	let bzzAmount: string;
	const lastPrice = 24000;
	const oneDay = 24 * 3600;
	const dv = BigInt(lastPrice * oneDay);

	onMount(async () => {
		publicClient.watchBlockNumber({
			emitOnBegin: true,
			onBlockNumber: (num) => (blockNumber = num)
		});

		[owner, depth, immutable, rBal] = await postageStamp.read.batches([json.batchId as Hex]);
		bzz = rBal * 2n ** BigInt(depth);
		bzzAmount = formatUnits(bzz, 16);

		bal = await postageStamp.read.remainingBalance([json.batchId as Hex]);
		bzz0 = bal * 2n ** BigInt(depth);
		bzzAmount0 = formatUnits(bzz0, 16);

		balj = Number(bal / dv);
		rBalj = Number(rBal / dv);
	});
</script>

<section>
	<p>
		Block {chain.network} ({chain.id}) <span> #{blockNumber}</span>
	</p>
	<p>
		PostageStamp <span>{json.PostageStamp}</span>
	</p>
	<p>
		BatchId <span>{json.batchId}</span>
	</p>
	<p>
		Batch <span>[{owner}, {depth}, {immutable}, {rBal}]</span>
	</p>
	<p>
		Batch creating Balance <span>{rBalj} jours | {bzzAmount} Bzz</span>
	</p>
	<p>
		Batch remaining Balance <span>{balj} jours | {bzzAmount0} Bzz</span>
	</p>
	<button><a href="..">Back</a></button>
</section>

<style>
	section {
		width: 800px;
		display: block;
		text-align: left;
	}
	p span {
		float: right;
	}
</style>
