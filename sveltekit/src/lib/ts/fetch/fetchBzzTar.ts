import { makeTar, type Collection } from '$lib/ts/swarm/tar';
import type { Hex } from 'viem';

import {
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID,
	SWARM_GATEWAY,
	ZERO_BYTES32
} from '../constants/constants';
import { localConfigGet } from '../constants/local';
import { fetchContentType, fetchUrlOk } from './fetch';

const fetchBzzTar = async (urls: (URL | undefined)[]): Promise<[Hex, URL[]]> => {
	// console.log('fetchBzzTar ~ fetchBzzTar:', urls);

	const swarmApiUrl = localConfigGet('api') || SWARM_DEFAULT_API;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (batchId === ZERO_BYTES32) throw new Error('No BatchId defined!');

	const collection: Collection = [];
	for (let index = 0; index < urls.length; index++) {
		// console.log('fetchBzzTar ~ index:', index, urls.length);

		const url = urls[index];
		if (!(url && fetchUrlOk(url))) throw new Error(`Bad URL ${url}`);

		const contentType = await fetchContentType(url);
		const [type, subtype] = contentType?.split('/') || [];
		const blob = await (await fetch(url)).blob();
		const data = new Uint8Array(await blob.arrayBuffer());

		let path: string;
		// image
		if (index === 0) {
			if (type !== 'image') throw new Error(`Bad Image Content-Type ${contentType} for ${url}`);
			path = 'image';
		}
		// metadata
		else if (index === 1) {
			if (contentType !== 'application/json')
				throw new Error(`Bad Metadata Content-Type ${contentType} for ${url}`);
			path = 'metadata.json';
			// partName = 'metadata';
			// const json = JSON.parse(new TextDecoder().decode(data));
			// json.imageName = imageName;
			// data = new TextEncoder().encode(JSON.stringify(json));
		} else {
			path = `part${index}.${subtype}`;
		}

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

	const paths = collection.map((item) => new URL(`${swarmApiUrl}/${json.reference}/${item.path}`));

	return [`0x${json.reference}`, paths];
};

export { fetchBzzTar };
