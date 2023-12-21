import { test } from 'vitest';
import { initManifestNode, Utils } from 'mantaray-js';

test('mantaray', async () => {
	const node = initManifestNode();

	const address1 = Utils.gen32Bytes();
	console.log('test.only ~ address1:', address1);

	const path1 = new TextEncoder().encode('path/1');
	console.log('test.only ~ path1:', path1);

	node.addFork(path1, address1);
});
