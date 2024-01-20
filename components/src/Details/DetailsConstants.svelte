<script lang="ts">
	import {
		BATCH_DEPTH,
		BATCH_SIZE,
		BATCH_TTL,
		BUCKET_DEPTH,
		CHUNK_SIZE,
		STAMP_PRICE,
		STAMP_SIZE,
		STAMP_TTL
	} from '@autoswarm/common/src/constants/constants';
	import {
		displayBalance,
		displayDuration,
		displaySize,
		displaySizeBytes
	} from '@autoswarm/common/src/display/display';

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
<p>
	Constants | Bucket Depth
	<span>
		2<sup>{BUCKET_DEPTH}</sup> /
		{displaySize(2 ** BUCKET_DEPTH)} /
		{displaySizeBytes(2 ** BUCKET_DEPTH)}
	</span>
</p>

<style>
	p span {
		float: right;
		font-family: Monaco;
	}
</style>
