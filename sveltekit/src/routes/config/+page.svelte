<script lang="ts">
	import { localConfigGet } from '$lib/ts/constants/local';

	$: swarmApi = localConfigGet('api');
	$: batchId = localConfigGet('batchId');
</script>

<h2>Config</h2>

<p>
	{swarmApi}
</p>
<p>
	{batchId}
</p>
