<script lang="ts">
	import {
		BATCH_DEPTH,
		BATCH_SIZE,
		BATCH_TTL,
		CHUNK_SIZE,
		STAMP_PRICE,
		STAMP_SIZE,
		STAMP_TTL
	} from '$lib/ts/constants/constants';
	import { displayBalance, displayDuration, displaySize } from '$lib/ts/display/display';

	///////////////////////////// Details Addresses ///////////////////////////////////////
	// <DetailsConstants />
	/////////////////////////////////////////////////////////////////////////////////////
</script>

<p>
	Constants | Batch Size = Chunk Size * Depth / TTL
	<span>
		{displaySize(BATCH_SIZE, 2)} =
		{CHUNK_SIZE} bytes * 2<sup>{BATCH_DEPTH}</sup> /
		{displayDuration(BATCH_TTL)}
	</span>
</p>
<p>
	Constants | Stamp Price per Unit / TTL
	<span>
    {displayBalance(STAMP_PRICE, 16, 4)} BZZ per {displaySize(STAMP_SIZE, 0)} /
		{displayDuration(STAMP_TTL)}
	</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
