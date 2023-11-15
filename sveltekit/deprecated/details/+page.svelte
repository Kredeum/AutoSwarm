<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';

	import {
		SECONDS_PER_BLOCK,
		ONE_YEAR,
		DEFAULT_PRICE,
		ONE_MONTH,
		ONE_DAY,
		SEPOLIA_RPC,
		AUTOSWARM_UNIT,
		AUTOSWARM_UNIT_PRICE,
		AUTOSWARM_PERIOD
	} from '$lib/ts/constants/constants.js';
	import {
		writeStampsBuy,
		writeStampsDeposit,
		writeStampsIncreaseDepth,
		writeStampsTopUp,
		writeStampsWithdraw
	} from '$lib/ts/onchain/writeStamps.js';
	import {
		readPostageBatchesLegacy,
		readPostageBatches,
		readBlock,
		readBzzBalance,
		readIsContract,
		readPostageLastPrice,
		readPostageRemainingBalance
	} from '$lib/ts/onchain/read.js';
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
	} from '$lib/ts/display/display.js';
	import { stampBzzToTtl } from '$lib/ts/swarm/stamp.js';
	import type { Address } from 'viem';
	import { writeWalletAddress } from '$lib/ts/onchain/write.js';
	import { readNftOwner, readNftTBAccount } from '$lib/ts/onchain/readNft.js';
	import { bzzChainId } from '$lib/ts/swarm/bzz.js';

	export let data../../src/routes/[chainId]/[collection]/[tokenId]/details/$types.js;
	const { json, chain } = data;

	// NFT reference
	const nftChainId = Number($page.params.chainId);
	const collection = $page.params.collection as Address;
	const tokenId = BigInt($page.params.tokenId);

	let blockTimestamp: number = 0;
	let blockNumber: number = 0;

	let nftOwner: Address | undefined;

	let walletAddress: Address | undefined;
	let walletBalance: bigint | undefined;

	let autoSwarmAddress: Address | undefined;
	let autoSwarmBalance: bigint | undefined;

	let lastPrice: bigint | undefined;
	let duration: number | undefined;
	let until: number | undefined;

	let owner: Address | undefined;
	let depth: number;

	let remainingBalance: bigint | undefined;
	let normalisedBalance: bigint | undefined;
	let oneDayNBal: bigint | undefined;
	let tbaDeployed: boolean | undefined;

	const reset = () => {
		remainingBalance = undefined;
		normalisedBalance = undefined;
		autoSwarmBalance = undefined;
		oneDayNBal = undefined;
		autoSwarmAddress = undefined;
		owner = undefined;
		nftOwner = undefined;
		tbaDeployed = undefined;
	};

	const refreshDisplay = async () => {
		console.info('refreshDisplay');
		if (!chain) return;
		reset();

		const block = await readBlock(chain.id);
		blockTimestamp = Number(block.timestamp) || 0;
		blockNumber = Number(block.number) || 0;

		nftOwner = await readNftOwner(nftChainId, collection, tokenId);

		walletAddress = await writeWalletAddress();
		walletBalance = await readBzzBalance($bzzChainId, walletAddress);

		autoSwarmAddress = await readNftTBAccount(nftChainId, collection, tokenId);
		autoSwarmBalance = await readBzzBalance($bzzChainId, autoSwarmAddress);
		lastPrice = (await readPostageLastPrice($bzzChainId)) || DEFAULT_PRICE;

		if (autoSwarmBalance !== undefined && lastPrice > 0n) {
			duration = Number((autoSwarmBalance * BigInt(ONE_YEAR)) / AUTOSWARM_UNIT_PRICE);
			until = blockTimestamp + duration;
		}

		remainingBalance = await readPostageRemainingBalance($bzzChainId);
		[owner, depth, normalisedBalance] =
			chain.id == 100 ? await readPostageBatchesLegacy($bzzChainId) : await readPostageBatches($bzzChainId);

		oneDayNBal = (lastPrice * BigInt(ONE_DAY)) / BigInt(SECONDS_PER_BLOCK);

		tbaDeployed = await readIsContract(chain.id, autoSwarmAddress as Address);
	};

	const buy = () =>
		autoSwarmAddress && writeStampsBuy($bzzChainId, autoSwarmAddress).then(refreshDisplay);
	const withdraw = () =>
		autoSwarmAddress && writeStampsWithdraw($bzzChainId, autoSwarmAddress).then(refreshDisplay);
	const deposit = () =>
		autoSwarmAddress && writeStampsDeposit($bzzChainId, autoSwarmAddress).then(refreshDisplay);
	const dilute = () =>
		autoSwarmAddress &&
		writeStampsIncreaseDepth($bzzChainId, autoSwarmAddress, depth + 2).then(refreshDisplay);

	const topUp = (months: number) =>
		autoSwarmAddress &&
		writeStampsTopUp(
			$bzzChainId,
			autoSwarmAddress,
			(BigInt(months * ONE_DAY) * (lastPrice || 0n)) / BigInt(SECONDS_PER_BLOCK)
		).then(refreshDisplay);

	const onChainChanged = ($bzzChainId: string): void => {
		let next = 'gnosis';
		if ($bzzChainId == '11155111') next = 'sepolia';
		else if ($bzzChainId == '31337') next = 'anvil';

		goto(next);
	};

	onMount(async () => {
		console.info('onMount');

		refreshDisplay();
	});
</script>

<section>
	<p>
		{chain.name} network (#{chain.id})
		<span>{displayDate(blockTimestamp)} | block #{blockNumber}</span>
	</p>
	<p>AutoSwarm Price<span>{displayBalance(AUTOSWARM_UNIT_PRICE, 16)} Bzz / Year * Mb</span></p>
	<p>
		<button><a href=".">back</a></button> &nbsp;
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
			>{displaySize(AUTOSWARM_UNIT)} |
			{@html displayExplorerLink($bzzChainId)} /
			{@html displayExplorerLink($bzzChainId, collection)} /
			{@html displayNftLink($bzzChainId, collection, tokenId)}
		</span>
	</p>
	<p>
		NFT Owner<span> {@html displayExplorerLink($bzzChainId, nftOwner)}</span>
	</p>
	<p>
		NFT AutoSwarm TBA ({displayTbaDisplayed(tbaDeployed)})
		<span
			>{displayBalance(autoSwarmBalance, 16, 4)} Bzz | {@html displayExplorerLink(
				$bzzChainId,
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
					((autoSwarmBalance || 0n) * BigInt(AUTOSWARM_PERIOD)) / BigInt(AUTOSWARM_UNIT_PRICE)
			)}</span
		>
	</p>
	<p>Stamp Ttl</p>
	<p>Current Stamp</p>
	<p>
		TBA Ttl
		<span
			>{displayBalance(autoSwarmBalance, 16, 4)} Bzz => {displayDuration(
				stampBzzToTtl(autoSwarmBalance, AUTOSWARM_UNIT, lastPrice)
			)}</span
		>
	</p>
	<hr />
	<p>LastPrice (1 Plur = 1e-16 Bzz) <span>{lastPrice} Plur/block</span></p>

	<p>
		Batch <span
			>[{@html displayExplorerLink($bzzChainId, owner)}, {displayTxt(depth)}, {displayTxt(
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
		BzzToken <span>{@html displayExplorerLink($bzzChainId, json.BzzToken)}</span>
	</p>
	<p>
		PostageStamp <span>{@html displayExplorerLink($bzzChainId, json.PostageStamp)}</span>
	</p>
	<p>
		Price Oracle <span>{@html displayExplorerLink($bzzChainId, json.Oracle)}</span>
	</p>
	<p>
		ERC6551 Registry <span>{@html displayExplorerLink($bzzChainId, json.ERC6551Registry)}</span>
	</p>
	<p>
		AutoSwarm implementation <span
			>{@html displayExplorerLink($bzzChainId, json.AutoSwarmAccount)}</span
		>
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
