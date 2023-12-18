import type { Hex } from 'viem';
import { makeTar, type Collection } from '$lib/ts/swarm/tar';

import { INDEX_HTML, LIST_JSON } from '../constants/constants';
import { fetchBzzPost } from './fetchBzz';
import { fetchAltUrlToBlob } from '../fetch/fetchAlt';
import { bzz0, bzzTrim } from '../swarm/bzz';
import { beeBatchId, beeApiBzz, beeGatewayBzz } from '../swarm/bee';

const _fetchBlobFilename = (blob: Blob): [string, string, string] => {
	const mimeType = blob.type;
	const [type, subType] = mimeType.split('/');
	let ext = subType;
	if (type === 'text') ext = subType === 'plain' ? 'txt' : subType;

	return [`${type}.${ext}`, type, subType];
};

const fetchBzzTar = async (
	urls: (URL | string | undefined)[]
): Promise<[Hex, bigint, string[], number[]]> => {
	// console.log('fetchBzzTar ~ fetchBzzTar:', urls);

	const api = beeApiBzz();
	const batchId = beeBatchId();
	if (!bzz0(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const metadataBlob = await fetchAltUrlToBlob(urls[1]);
	const metadataData = new Uint8Array(await metadataBlob.arrayBuffer());

	const contentBlob: Blob = await fetchAltUrlToBlob(urls[0]);
	const contentData = new Uint8Array(await contentBlob.arrayBuffer());
	const [image, imageMainType] = _fetchBlobFilename(contentBlob);

	let html = '<html><body><h1>AutoSwarm</h1>';
	if (imageMainType == 'image') {
		html += `<img width="150" src="${image}"><br/><br/>`;
	}
	html += `<a href="${image}">${image}</a></li><br/><br/>`;
	html += `<a href="metadata.json">metadata.json</a><br/><br/></body></html>`;
	html += '</body></html>';
	const indexHtml = new TextEncoder().encode(html);

	const json = `{"image": "${image}", "metadata": "metadata.json"}`;
	const indexJson = new TextEncoder().encode(json);

	const collection: Collection = [];
	collection.push({ data: indexHtml, path: INDEX_HTML });
	collection.push({ data: indexJson, path: LIST_JSON });
	collection.push({ data: metadataData, path: 'metadata.json' });
	collection.push({ data: contentData, path: image });

	const body = makeTar(collection);
	const bodySize = BigInt(body.length);

	const headers = new Headers();
	headers.append('Accept', 'application/json, text/plain, */*');
	headers.append('Content-Type', 'application/x-tar');
	headers.append('Swarm-Postage-Batch-Id', batchId);
	headers.append('Swarm-Pin', 'true');
	headers.append('Swarm-Collection', 'true');
	headers.append('Swarm-Index-Document', INDEX_HTML);

	const hash = await fetchBzzPost(api, body, headers);
	console.log('fetchBzzTar hash:', hash);

	collection.shift();
	const paths = collection.map((item) => `${beeGatewayBzz()}/${bzzTrim(hash)}/${item.path}`);
	const sizes = collection.map((item) => item.data.length);

	return [hash, bodySize, paths, sizes];
};

export { fetchBzzTar };
