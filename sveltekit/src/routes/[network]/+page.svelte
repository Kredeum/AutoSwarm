<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	import { gnosis, localhost, sepolia, thunderTestnet } from 'viem/chains';
	import { createPublicClient, http, type Address, type PublicClient } from 'viem';

	import { anvil } from '$lib/ts/anvil';
	import { SECONDS_PER_BLOCK, ONE_YEAR, DEFAULT_PRICE, ONE_MONTH } from '$lib/ts/constants';
	import {
		writeStampsBuy,
		writeStampsDeposit,
		writeStampsTopUp,
		writeStampsWithdraw
	} from '$lib/ts/writeStamps.js';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBzzBalance,
		readLastPrice,
		readNftOwner,
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

	export let data;

	$: json = data.json;
	$: network = data.network || 'gnosis';

	let blockNumber: bigint = 0n;

	type ChainInJson = typeof gnosis | typeof sepolia | typeof anvil | typeof localhost;
	let chain: ChainInJson = gnosis;

	let publicClient: PublicClient;

	let autoSwarmAddress: Address | undefined;
	let owner: Address | undefined;
	let nftOwner: Address | undefined;
	let depth: number;
	let unwatch: () => void;

	let lastPrice: bigint = DEFAULT_PRICE;
	let remainingBalance: bigint | undefined;
	let normalisedBalance: bigint | undefined;
	let bzzNftBalance: bigint | undefined;
	let bzzNftOwnerBalance: bigint | undefined;
	let oneYearBzz: bigint | undefined;

	const reset = () => {
		lastPrice = DEFAULT_PRICE;
		remainingBalance = undefined;
		normalisedBalance = undefined;
		bzzNftBalance = undefined;
		bzzNftOwnerBalance = undefined;
		oneYearBzz = undefined;
		autoSwarmAddress = undefined;
		owner = undefined;
		nftOwner = undefined;
	};

	const refreshDisplay = async () => {
		console.info('refreshDisplay');
		if (!publicClient) return;
		reset();

		nftOwner = await readNftOwner(publicClient);
		bzzNftOwnerBalance = await readBzzBalance(publicClient, nftOwner);
		autoSwarmAddress = await readAccount(publicClient);
		bzzNftBalance = await readBzzBalance(publicClient, autoSwarmAddress);

		remainingBalance = await readRemainingBalance(publicClient);
		[owner, depth, normalisedBalance] =
			chain.id == 100 ? await readBatchLegacy(publicClient) : await readBatchNew(publicClient);

		const lastPriceRead = await readLastPrice(publicClient);
		if (lastPriceRead > 0) lastPrice = lastPriceRead;
		oneYearBzz = (lastPrice * BigInt(ONE_YEAR)) / SECONDS_PER_BLOCK;
	};

	const buy = () => writeStampsBuy(chain, publicClient).then(refreshDisplay);
	const withdraw = () => writeStampsWithdraw(chain, publicClient).then(refreshDisplay);
	const deposit = () => writeStampsDeposit(chain, publicClient).then(refreshDisplay);

	const topUp = (months: number) =>
		writeStampsTopUp(
			chain,
			publicClient,
			(BigInt(months * ONE_MONTH) * lastPrice) / SECONDS_PER_BLOCK
		).then(refreshDisplay);

	const initChain = async (nw: string): Promise<void> => {
		console.info('initChain <-', nw);

		let transport = http();
		if (nw == 'sepolia') {
			chain = sepolia;
			transport = http('https://eth-sepolia-public.unifra.io');
		} else if (nw == 'localhost') {
			chain = localhost;
		} else if (nw == 'anvil') {
			chain = anvil;
		} else {
			chain = gnosis;
		}
		publicClient = createPublicClient({ chain, transport });
		if (unwatch) unwatch();
		unwatch = publicClient.watchBlockNumber({
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
		else if (chainId == '31337') next = 'anvil';
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
		Block #{blockNumber} <span>{network} ({chain.id})</span>
	</p>
	<p>
		<button><a href="..">back</a></button> &nbsp;
		<button on:click={refreshDisplay}>refresh</button> &nbsp;
		<button on:click={() => onChainChanged('100')}>go gnosis</button>
		<button on:click={() => onChainChanged('11155111')}>go sepolia</button>
		<button on:click={() => onChainChanged('31337')}>go anvil</button>
		<span>
			<button on:click={withdraw}>Withdraw</button> &nbsp;
			<button on:click={deposit}>Deposit</button> &nbsp;
			<button on:click={buy}>Buy</button> &nbsp;
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
		One Year TopUp at price {lastPrice}<span
			>{displayBzzFromBalance(oneYearBzz, depth)} Bzz | {displayTtl(oneYearBzz, lastPrice)}</span
		>
	</p>

	<p>
		NFT <span
			>Token Id {@html displayNftLink(chain, json.NFTCollection, Number(json.tokenId))} &nbsp; Collection
			{@html displayExplorerLink(chain, json.NFTCollection)}</span
		>
	</p>
	<p>
		NFT Owner<span
			>{displayBalance(bzzNftOwnerBalance, 16, 4)} Bzz | {@html displayExplorerLink(
				chain,
				nftOwner
			)}</span
		>
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
		Batch Id <span>{json.batchId}</span>
	</p>
	<p>
		PostageStamp <span>{@html displayExplorerLink(chain, json.PostageStamp)}</span>
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
	<p>
		Price Oracle <span>{@html displayExplorerLink(chain, json.Oracle)}</span>
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
