<script lang="ts">
	import { createPublicClient, http } from 'viem';
	import { gnosis, sepolia } from 'viem/chains';

	let blockNumber: bigint = 0n;

	const client = createPublicClient({
		chain: gnosis,
		transport: http()
	});

	client.watchBlockNumber({
		emitOnBegin: true,
		onBlockNumber: (num) => (blockNumber = num)
	});
</script>

<div class="user-config">
	<div class="provisory">
		<button><a href="..">Back</a></button>
	</div>
</div>

<section>Block number: {blockNumber}</section>
