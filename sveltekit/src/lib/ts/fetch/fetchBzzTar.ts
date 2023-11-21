import { makeTar, type Collection } from '$lib/ts/swarm/tar';

import {
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID,
	SWARM_GATEWAY,
	ZERO_BYTES32
} from '../constants/constants';
import { localConfigGet } from '../constants/local';
import { fetchUrlOk } from './fetch';

const fetchBzzTar = async (urls: (string | undefined)[]): Promise<string[]> => {
	const swarmApiUrl = localConfigGet('api') || SWARM_DEFAULT_API;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (batchId === ZERO_BYTES32) throw new Error('No BatchId defined!');

	const collection: Collection = [];

	for (let index = 0; index < urls.length; index++) {
		const url = urls[index];
		if (!(url && fetchUrlOk(url))) throw new Error(`Bad Url ${url}`);

		const blob = await (await fetch(url)).blob();
		const data = new Uint8Array(await blob.arrayBuffer());
		const path = index === 0 ? 'metadata.json' : index === 1 ? 'content' : `part${index}`;

		collection.push({ data, path });
	}
	const body = makeTar(collection);

	const headers = new Headers();
	headers.append('Content-Type', 'application/x-tar');
	headers.append('swarm-postage-batch-id', batchId);
	headers.append('swarm-pin', 'true');
	headers.append('swarm-collection', 'true');

	const response = await fetch(swarmApiUrl, { method: 'POST', headers, body });

	const json = await response.json();
	if (!response.ok) {
		throw Error(`${response.statusText}\n${JSON.stringify(json, null, 2)}`);
	}

	const paths = collection.map((item) => `${SWARM_GATEWAY}/${json.reference}/${item.path}`);

  console.log('fetchBzzTar ~ reference:', json.reference);
	console.log('fetchBzzTar ~ metadata.json:', paths[0]);
	console.log('fetchBzzTar ~ content:', paths[1]);
	return paths;
};

export { fetchBzzTar };
