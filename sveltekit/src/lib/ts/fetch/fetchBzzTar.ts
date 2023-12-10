import type { Hex } from 'viem';
import { makeTar, type Collection } from '$lib/ts/swarm/tar';

import {
	IMAGE_JPEG,
	METADATA_JSON,
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID
} from '../constants/constants';
import { localConfigGet } from '../common/local';
import { fetchAltUrl } from './fetchAlt';
import { urlToUrl } from '../common/url';
import { fetchUrl } from '../fetch/fetch';
import { bzz0, bzzTrim } from '../swarm/bzz';
import { fetchBzzPost } from './fetchBzz';

const fetchBzzTar = async (
	urls: (URL | string | undefined)[]
): Promise<[Hex, bigint, string[], number[]]> => {
	// console.log('fetchBzzTar ~ fetchBzzTar:', urls);

	const api = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = bzzTrim(localConfigGet('batchId') || SWARM_DEFAULT_BATCHID);
	if (!bzz0(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const collection: Collection = [];
	for (let index = 0; index < urls.length; index++) {
		const url = urlToUrl(urls[index]);

		// const contentType = await fetchContentType(url);
		// console.log('fetchBzzTar part', index, contentType);
		// const [type, subtype] = contentType?.split('/') || [];

		const urlAlt = await fetchAltUrl(url);
		if (!urlAlt) throw new Error(`fetchBzzTar: Bad URL ${url}`);

		const response = await fetchUrl(urlAlt);
		if (!response) throw new Error(`fetchBzzTar: Bad URL ${urlAlt}`);

		const blob = await response.blob();
		const data = new Uint8Array(await blob.arrayBuffer());

		let path: string;
		// image
		if (index === 0) {
			// if (type !== 'image') throw new Error(`fetchBzzTar: Bad Image Content-Type ${contentType} for ${url}`);
			path = IMAGE_JPEG;
		}
		// metadata
		else if (index === 1) {
			// if (!(contentType?.startsWith('application/json') || contentType?.startsWith('text/plain')))
			// 	throw new Error(`fetchBzzTar: Bad Metadata Content-Type ${contentType} for ${url}`);
			path = METADATA_JSON;
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
	const bodySize = BigInt(body.length);

	const headers = new Headers();
	headers.append('Content-Type', 'application/x-tar');
	headers.append('Swarm-Postage-Batch-Id', batchId);
	headers.append('Swarm-Pin', 'true');
	headers.append('Swarm-Collection', 'true');

	const hash = await fetchBzzPost(api, body, headers);
	console.log('fetchBzzTar hash:', hash);

	const paths = collection.map((item) => `${api}/${bzzTrim(hash)}/${item.path}`);
	const sizes = collection.map((item) => item.data.length);

	return [hash, bodySize, paths, sizes];
};

export { fetchBzzTar };
