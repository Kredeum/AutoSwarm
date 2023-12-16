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
import { fetchUrl } from './fetch';
import { bzz0, bzzTrim } from '../swarm/bzz';
import { fetchBzzPost } from './fetchBzz';

const _fetchDataFromUrl = async (url: URL | string | undefined): Promise<Uint8Array> => {
	const urlAlt = await fetchAltUrl(url);
	if (!urlAlt) throw new Error(`fetchBzzTar: Bad URL ${url}`);

	const response = await fetchUrl(urlAlt);
	if (!response) throw new Error(`fetchBzzTar: Bad URL ${urlAlt}`);

	const blob = await response.blob();
	return new Uint8Array(await blob.arrayBuffer());
};

const fetchBzzTar = async (
	urls: (URL | string | undefined)[]
): Promise<[Hex, bigint, string[], number[]]> => {
	// console.log('fetchBzzTar ~ fetchBzzTar:', urls);

	const api = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = bzzTrim(localConfigGet('batchId') || SWARM_DEFAULT_BATCHID);
	if (!bzz0(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const collection: Collection = [];

	const data = new TextEncoder().encode(`<html><body><h1>AutoSwarm</h1>
    <img width="150" src="${IMAGE_JPEG}" alt="${IMAGE_JPEG}"><br/><br/>
    <a href="${IMAGE_JPEG}">${IMAGE_JPEG}</a></li><br/><br/>
    <a href="${METADATA_JSON}">${METADATA_JSON}</a><br/><br/></body></html>`);

	collection.push({ data, path: 'index.html' });
	collection.push({ data: await _fetchDataFromUrl(urls[0]), path: IMAGE_JPEG });
	collection.push({ data: await _fetchDataFromUrl(urls[1]), path: METADATA_JSON });

	const body = makeTar(collection);
	const bodySize = BigInt(body.length);

	const headers = new Headers();
	headers.append('Accept', 'application/json, text/plain, */*');
	headers.append('Content-Type', 'application/x-tar');
	headers.append('Swarm-Postage-Batch-Id', batchId);
	headers.append('Swarm-Pin', 'true');
	headers.append('Swarm-Collection', 'true');
	headers.append('Swarm-Index-Document', 'index.html');

	const hash = await fetchBzzPost(api, body, headers);
	console.log('fetchBzzTar hash:', hash);

	const paths = collection.map((item) => `${api}/${bzzTrim(hash)}/${item.path}`);
	const sizes = collection.map((item) => item.data.length);

	return [hash, bodySize, paths, sizes];
};

export { fetchBzzTar };
