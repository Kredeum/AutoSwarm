import type { Hex } from 'viem';
import { makeTar, type Collection } from '$lib/ts/swarm/tar';

import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID, ZERO_BYTES32 } from '../constants/constants';
import { localConfigGet } from '../common/local';
import { fetchAltUrl, fetchContentType, fetchUrlOk } from './fetch';

const fetchBzzTar = async (urls: (URL | string | undefined)[]): Promise<[Hex, string[]]> => {
	// console.log('fetchBzzTar ~ fetchBzzTar:', urls);

	const swarmApiUrl = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (!(batchId && batchId !== ZERO_BYTES32)) throw new Error('fetchBzzTar: No BatchId defined!');

	const collection: Collection = [];
	for (let index = 0; index < urls.length; index++) {
		const _url = urls[index];
		if (!(_url && fetchUrlOk(_url))) throw new Error(`fetchBzzTar: Bad URL ${_url}`);
		const url = new URL(_url);

		const contentType = await fetchContentType(url);
		console.log('fetchBzzTar part', index, contentType);
		const [type, subtype] = contentType?.split('/') || [];

		const urlAlt = await fetchAltUrl(url);
		if (!urlAlt) throw new Error(`fetchBzzPost: Bad URL ${url}`);

		const blob = await (await fetch(urlAlt)).blob();
		const data = new Uint8Array(await blob.arrayBuffer());

		let path: string;
		// image
		if (index === 0) {
			// if (type !== 'image') throw new Error(`fetchBzzTar: Bad Image Content-Type ${contentType} for ${url}`);
			path = 'image';
		}
		// metadata
		else if (index === 1) {
			// if (!(contentType?.startsWith('application/json') || contentType?.startsWith('text/plain')))
			// 	throw new Error(`fetchBzzTar: Bad Metadata Content-Type ${contentType} for ${url}`);
			path = 'metadata.json';
			// partName = 'metadata';
			// const json = JSON.parse(new TextDecoder().decode(data));
			// json.imageName = imageName;
			// data = new TextEncoder().encode(JSON.stringify(json));
		} else {
			path = `part${index}.${type}.${subtype}`;
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

	const paths = collection.map((item) => `${swarmApiUrl}/${json.reference}/${item.path}`);

	return [`0x${json.reference}`, paths];
};

export { fetchBzzTar };
