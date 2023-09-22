<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	import { gnosis, localhost, sepolia } from 'viem/chains';
	import { createPublicClient, http, type Address, type PublicClient } from 'viem';

	import { SECONDS_PER_BLOCK, ONE_YEAR, DEFAULT_PRICE, ONE_MONTH } from '$lib/ts/constants';
	import { writeDeposit, writeTopUp, writeWithdraw } from '$lib/ts/write';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBzzBalance,
		readLastPrice,
		readNftMetadata,
		readRemainingBalance
	} from '$lib/ts/read';
	import {
		displayBalance,
		displayBzzFromBalance,
		displayExplorerLink,
		displayNftLink,
		displayTtl,
		displayTxt
	} from '$lib/ts/display';
	import { autoSwarmAbi, erc6551RegistryAbi } from '$lib/ts/abis.js';

	export let data;

	$: json = data.json;
	$: network = data.network || 'gnosis';

	let blockNumber: bigint = 0n;

	type ChainInJson = typeof gnosis | typeof sepolia | typeof localhost;
	let chain: ChainInJson = gnosis;

	let publicClient: PublicClient;
	let autoSwarmAddress: Address;

	let owner: Address;
	let depth: number;

	let lastPrice: bigint = DEFAULT_PRICE;
	let remainingBalance: bigint;
	let normalisedBalance: bigint;
	let bzzNftBalance: bigint;
	let oneYearBzz: bigint;

	const refreshDisplay = async () => {
		console.info('refreshDisplay');
		if (!publicClient) return;

		remainingBalance = await readRemainingBalance(publicClient);
		autoSwarmAddress = await readAccount(publicClient);
		bzzNftBalance = await readBzzBalance(publicClient, autoSwarmAddress as Address);
		[owner, depth, normalisedBalance] =
			chain.id == 100 ? await readBatchLegacy(publicClient) : await readBatchNew(publicClient);

		const lastPriceRead = await readLastPrice(publicClient);
		if (lastPriceRead > 0) lastPrice = lastPriceRead;
		oneYearBzz = (lastPrice * BigInt(ONE_YEAR)) / SECONDS_PER_BLOCK;
	};

	const withdraw = async () => {
		console.info('withdraw');

		await writeWithdraw(chain, publicClient);
		await refreshDisplay();
	};

	const deposit = async () => {
		console.info('deposit');

		await writeDeposit(chain, publicClient);
		await refreshDisplay();
	};

	const topUp = async (months: number) => {
		console.info('topUp');

		await writeTopUp(
			chain,
			publicClient,
			(BigInt(months * ONE_MONTH) * lastPrice) / SECONDS_PER_BLOCK
		);
		await refreshDisplay();
	};

	const initChain = async (nw: string): Promise<void> => {
		console.info('initChain <-', nw);

		let transport = http();
		if (nw == 'sepolia') {
			chain = sepolia;
			transport = http('https://eth-sepolia-public.unifra.io');
		} else if (nw == 'localhost') {
			chain = localhost;
		} else {
			chain = gnosis;
		}
		publicClient = createPublicClient({ chain, transport });

		// const unwatch = publicClient.watchContractEvent({
		// 	address: json.ERC6551Registry as Address,
		// 	abi: erc6551RegistryAbi,
		// 	onLogs: (logs) => console.log(logs)
		// });

		publicClient.watchBlockNumber({
			emitOnBegin: true,
			onBlockNumber: (num: bigint) => (blockNumber = num)
		});

		await refreshDisplay();

		console.info('initChain ->', chain);
	};

	const onChainChanged = (chainId: string): void => {
		console.log('onChainChanged', chainId);

		let next = 'gnosis';
		if (chainId == '11155111') next = 'sepolia';
		else if (chainId == '1337') next = 'localhost';

		goto(next).then(() => initChain(next));
	};

	onMount(async () => {
		console.info('onMount');

		await initChain(network);
	});
</script>

<section>
	<p>
		Block  #{blockNumber}  <span>{network}</span>
	</p>
	<p>
		<button><a href="..">back</a></button> &nbsp;
		<button on:click={refreshDisplay}>refresh</button> &nbsp;
		{#if network != 'gnosis'}
			<button on:click={() => onChainChanged('100')}>go gnosis</button>
		{/if}
		{#if network != 'sepolia'}
			<button on:click={() => onChainChanged('11155111')}>go sepolia</button>
		{/if}
		<span>
			<button on:click={withdraw}>Withdraw</button> &nbsp;
			<button on:click={deposit}>Deposit</button> &nbsp;
			<button on:click={() => topUp(1)}>TopUp 1 Month</button>
			<button on:click={() => topUp(12)}>TopUp 1 Year</button>
		</span>
	</p>
	<p>
		Batch Remaining LifeSpan
		<span
			>{displayBzzFromBalance(remainingBalance, depth)} Bzz | {displayTtl(
				remainingBalance,
				lastPrice
			)}</span
		>
	</p>
	<p>
		One Year TopUp <span
			>{displayBzzFromBalance(oneYearBzz, depth)} Bzz | {displayTtl(oneYearBzz, lastPrice)}</span
		>
	</p>

	<p>
		NFT <span>{@html displayNftLink(chain, json.NFTCollection, Number(json.tokenId))}</span>
	</p>
	<p>
		NFT SmartAccount <span
			>{displayBalance(bzzNftBalance, 16, 4)} Bzz | {@html displayExplorerLink(
				chain,
				autoSwarmAddress
			)}</span
		>
	</p>
	<p>
		Batch <span
			>[{@html displayExplorerLink(chain, owner)}, {displayTxt(depth)}, {displayTxt(
				remainingBalance
			)}]</span
		>
	</p>
	<p>
		BatchId <span>{json.batchId}</span>
	</p>
	<p>
		PostageStamp <span>{@html displayExplorerLink(chain, json.PostageStamp)}</span>
	</p>
	<p>
		Price Oracle <span>{@html displayExplorerLink(chain, json.Oracle)}</span>
	</p>
	<p>
		BzzToken <span>{@html displayExplorerLink(chain, json.BzzToken)}</span>
	</p>
	<p>
		AutoSwarm implementation <span>{@html displayExplorerLink(chain, json.AutoSwarmAccount)}</span>
	</p>
	<p>
		ERC6551 Registry <span>{@html displayExplorerLink(chain, json.ERC6551Registry)}</span>
	</p>
</section>

<style>
	section {
		width: 800px;
		display: block;
		text-align: left;
	}
	section p span {
		float: right;
	}
</style>
