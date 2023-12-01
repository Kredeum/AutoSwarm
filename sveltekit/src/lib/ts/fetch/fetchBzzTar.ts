import type { Hex } from 'viem';
import { makeTar, type Collection } from '$lib/ts/swarm/tar';

import { SWARM_DEFAULT_API, SWARM_DEFAULT_BATCHID } from '../constants/constants';
import { localConfigGet } from '../common/local';
import { fetchAltUrl } from './fetchAlt';

import { utilsIsBytes32Null } from '../common/utils';
import { urlToUrl } from '../common/url';
import { fetchSuccess, fetchUrl } from './fetch';

const fetchBzzTar = async (
	urls: (URL | string | undefined)[]
): Promise<[Hex, string[], number[]]> => {
	// console.log('fetchBzzTar ~ fetchBzzTar:', urls);

	const swarmApiUrl = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (utilsIsBytes32Null(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const collection: Collection = [];
	for (let index = 0; index < urls.length; index++) {
		const url = urlToUrl(urls[index]);

		// const contentType = await fetchContentType(url);
		// console.log('fetchBzzTar part', index, contentType);
		// const [type, subtype] = contentType?.split('/') || [];

		const urlAlt = await fetchAltUrl(url);
		if (!urlAlt) throw new Error(`fetchBzzPost: Bad URL ${url}`);

		const response = await fetchUrl(urlAlt);
		if (!response) throw new Error(`fetchBzzPost: Bad URL ${urlAlt}`);

		const blob = await response.blob();
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
			// path = `part${index}.${type}.${subtype}`;
			path = `part${index}`;
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
	if (!fetchSuccess(response.status)) throw Error(`fetchBzzTar: ${response.status}`);
	const json = await response.json();

	const paths = collection.map((item) => `${swarmApiUrl}/${json.reference}/${item.path}`);
	const sizes = collection.map((item) => item.data.length);

	return [`0x${json.reference}`, paths, sizes];
};

export { fetchBzzTar };
