<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	import {
		SECONDS_PER_BLOCK,
		ONE_YEAR,
		DEFAULT_PRICE,
		ONE_MONTH,
		ONE_DAY,
		SEPOLIA_RPC,
		AUTOSWARM_UNIT_PRICE,
		AUTOSWARM_PERIOD
	} from '$lib/ts/constants';
	import {
		writeStampsBuy,
		writeStampsDeposit,
		writeStampsIncreaseDepth,
		writeStampsTopUp,
		writeStampsWithdraw
	} from '$lib/ts/writeStamps.js';
	import {
		readAccount,
		readBatchLegacy,
		readBatchNew,
		readBlock,
		readBzzBalance,
		readIsContract,
		readLastPrice,
		readLastTokenId,
		readNftOwner,
		readRemainingBalance
	} from '$lib/ts/read';
	import {
		displayBalance,
		displayBatchDepthWithSize,
		displayBatchSize,
		displayBzzFromNBal,
		displayDate,
		displayDuration,
		displayExplorerLink,
		displayNftLink,
		displaySize,
		displayTbaDisplayed,
		displayTtl,
		displayTxt
	} from '$lib/ts/display';
	import { stampBzzToTtl } from '$lib/ts/stamp.js';
	import type { ChainInJson } from '$lib/ts/types.js';
	import { anvil } from '$lib/ts/anvil.js';
	import type { Address, PublicClient } from 'viem';

	export let data;

	const { json, chain } = data;

	let blockNumber: number = 0;
	let blockTimestamp: number = 0;

	let publicClient: PublicClient;

	let autoSwarmAddress: Address | undefined;
	let owner: Address | undefined;
	let nftOwner: Address | undefined;
	const nftSize = 1024 ** 2;
	let depth: number;
	let unwatch: () => void;

	let lastPrice: bigint = DEFAULT_PRICE;
	let remainingBalance: bigint | undefined;
	let normalisedBalance: bigint | undefined;
	let bzzNftBalance: bigint | undefined;
	let bzzNftOwnerBalance: bigint | undefined;
	let oneDayNBal: bigint | undefined;
	let tbaDeployed: boolean | undefined;
	let tokenId = 1n;

	const reset = () => {
		lastPrice = DEFAULT_PRICE;
		remainingBalance = undefined;
		normalisedBalance = undefined;
		bzzNftBalance = undefined;
		bzzNftOwnerBalance = undefined;
		oneDayNBal = undefined;
		autoSwarmAddress = undefined;
		owner = undefined;
		nftOwner = undefined;
		tbaDeployed = undefined;
	};

	const refreshDisplay = async () => {
		console.info('refreshDisplay');
		if (!publicClient) return;
		reset();

		const block = await readBlock(publicClient);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		tokenId = await readLastTokenId(publicClient);
		nftOwner = await readNftOwner(publicClient);
		bzzNftOwnerBalance = await readBzzBalance(publicClient, nftOwner);
		autoSwarmAddress = await readAccount(publicClient);
		bzzNftBalance = await readBzzBalance(publicClient, autoSwarmAddress);

		remainingBalance = await readRemainingBalance(publicClient);
		[owner, depth, normalisedBalance] =
			chain.id == 100 ? await readBatchLegacy(publicClient) : await readBatchNew(publicClient);

		const lastPriceRead = await readLastPrice(publicClient);
		if (lastPriceRead > 0) lastPrice = lastPriceRead;
		oneDayNBal = (lastPrice * BigInt(ONE_DAY)) / BigInt(SECONDS_PER_BLOCK);

		tbaDeployed = await readIsContract(publicClient, autoSwarmAddress as Address);
		console.log('refreshDisplay ~ tbaDeployed:', tbaDeployed);
	};

	const buy = () => writeStampsBuy(chain, publicClient).then(refreshDisplay);
	const withdraw = () => writeStampsWithdraw(chain, publicClient).then(refreshDisplay);
	const deposit = () => writeStampsDeposit(chain, publicClient).then(refreshDisplay);
	const dilute = () =>
		writeStampsIncreaseDepth(chain, publicClient, depth + 2).then(refreshDisplay);

	const topUp = (months: number) =>
		writeStampsTopUp(
			chain,
			publicClient,
			(BigInt(months * ONE_DAY) * lastPrice) / BigInt(SECONDS_PER_BLOCK)
		).then(refreshDisplay);

	const onChainChanged = (chainId: string): void => {
		let next = 'gnosis';
		if (chainId == '11155111') next = 'sepolia';
		else if (chainId == '31337') next = 'anvil';

		goto(next);
	};

	onMount(async () => {
		console.info('onMount');

		await readInit(chain);
	});
</script>

<section>
	<p>
		{chain.name} network (chainId #{chain.id})
		<span>{displayDate(blockTimestamp)} | block #{blockNumber}</span>
	</p>
	<p>AutoSwarm Price<span>{displayBalance(AUTOSWARM_UNIT_PRICE, 16)} Bzz / Mo</span></p>
	<p>
		<button><a href="/">back</a></button> &nbsp;
		<button on:click={refreshDisplay}>refresh</button> &nbsp;
		<span>
			<button on:click={() => onChainChanged('100')}>go gnosis</button>
			<button on:click={() => onChainChanged('11155111')}>go sepolia</button>
			<button on:click={() => onChainChanged('31337')}>go anvil</button>
		</span>
	</p>
	<hr />
	<p>
		NFT <span
			>{displaySize(nftSize)} |
			{@html displayExplorerLink(chain)} /
			{@html displayExplorerLink(chain, json.NFTCollection)} /
			{@html displayNftLink(chain, json.NFTCollection, tokenId)}
		</span>
	</p>
	<p>
		NFT Owner<span> {@html displayExplorerLink(chain, nftOwner)}</span>
	</p>
	<p>
		NFT AutoSwarm TBA ({displayTbaDisplayed(tbaDeployed)})
		<span
			>{displayBalance(bzzNftBalance, 16, 4)} Bzz | {@html displayExplorerLink(
				chain,
				autoSwarmAddress
			)}</span
		>
	</p>
	<p>
		<button on:click={withdraw}>TBA Withdraw</button> &nbsp;
		<button on:click={deposit}>TBA Deposit</button> &nbsp;
		<span>
			<button>TBA TopUp 1 Week</button>
			<button>TBA TopUp 1 Month</button>
			<button>TBA TopUp 1 Year</button>
		</span>
	</p>
	<hr />

	<p>
		Expiration Date
		<span
			>{displayDate(
				BigInt(blockTimestamp) +
					((bzzNftBalance || 0n) * BigInt(AUTOSWARM_PERIOD)) / BigInt(AUTOSWARM_UNIT_PRICE)
			)}</span
		>
	</p>
	<p>Stamp Ttl</p>
	<p>Current Stamp</p>
	<p>
		TBA Ttl
		<span
			>{displayBalance(bzzNftBalance, 16, 4)} Bzz => {displayDuration(
				stampBzzToTtl(bzzNftBalance || 0n, nftSize, lastPrice)
			)}</span
		>
	</p>
	<hr />
	<p>LastPrice (1 Plur = 1e-16 Bzz) <span>{lastPrice} Plur/block</span></p>

	<p>
		Batch <span
			>[{@html displayExplorerLink(chain, owner)}, {displayTxt(depth)}, {displayTxt(
				remainingBalance
			)}, {displayTxt(normalisedBalance)}]</span
		>
	</p>
	<p>
		Batch Id <span
			>{json.batchId}
			| {displayBatchSize(depth)}</span
		>
	</p>
	<p>
		Batch Remaining Ttl
		<span
			>{displayBzzFromNBal(remainingBalance, depth)} Bzz =>
			{displayTtl(remainingBalance, lastPrice)}</span
		>
	</p>
	<p>
		Batch TopUp of One Year at price {lastPrice}<span
			>{displayBzzFromNBal(oneDayNBal && oneDayNBal * 365n, depth)} Bzz => {displayTtl(
				oneDayNBal && oneDayNBal * 365n,
				lastPrice
			)}</span
		>
	</p>
	<p>
		<button on:click={dilute}>Batch Dilute</button> &nbsp;
		<button on:click={buy}>Batch Buy</button> &nbsp;
		<span>
			<button
				title="Cost {displayBzzFromNBal(oneDayNBal && oneDayNBal * 7n, depth)} Bzz"
				on:click={() => topUp(7)}>Batch TopUp 1 Week</button
			>
			<button
				title="Cost {displayBzzFromNBal(oneDayNBal && oneDayNBal * 30n, depth)} Bzz"
				on:click={() => topUp(30)}>Batch TopUp 1 Month</button
			>
			<button
				title="Cost {displayBzzFromNBal(oneDayNBal && oneDayNBal * 365n, depth)} Bzz"
				on:click={() => topUp(365)}>Batch TopUp 1 Year</button
			>
		</span>
	</p>
	<hr />
	<p>
		BzzToken <span>{@html displayExplorerLink(chain, json.BzzToken)}</span>
	</p>
	<p>
		PostageStamp <span>{@html displayExplorerLink(chain, json.PostageStamp)}</span>
	</p>
	<p>
		Price Oracle <span>{@html displayExplorerLink(chain, json.Oracle)}</span>
	</p>
	<p>
		ERC6551 Registry <span>{@html displayExplorerLink(chain, json.ERC6551Registry)}</span>
	</p>
	<p>
		AutoSwarm implementation <span>{@html displayExplorerLink(chain, json.AutoSwarmAccount)}</span>
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
