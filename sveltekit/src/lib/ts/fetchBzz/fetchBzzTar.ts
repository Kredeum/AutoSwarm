import type { Hex } from 'viem';
import { makeTar, type Collection } from '$lib/ts/swarm/tar';

import { INDEX_HTML, LIST_JSON } from '../constants/constants';
import { fetchBzzPost } from './fetchBzz';
import { fetchAltUrlToBlob, fetchAltUrlToUint8Array } from '../fetch/fetchAlt';
import { bzz0 } from '../swarm/bzz';
import { beeBatchId, beeApiBzz } from '../swarm/bee';

const _fetchBlobFilename = (blob: Blob): [string, string, string] => {
	const mimeType = blob.type;
	const [type, subType] = mimeType.split('/');

	let ext = subType;
	if (type === 'text' && (!subType || subType === 'plain')) ext = 'txt';

	return [`${type}.${ext}`, type, subType];
};

const fetchBzzTar = async (urls: (URL | string | undefined)[]): Promise<[Uint8Array, string]> => {
	console.log('fetchBzzTar ~ fetchBzzTar:', urls);

	const collection: Collection = [];

	const contentBlob: Blob = await fetchAltUrlToBlob(urls[0]);
	const contentData = new Uint8Array(await contentBlob.arrayBuffer());
	const [imageName, imageMainType] = _fetchBlobFilename(contentBlob);
	collection.push({ data: contentData, path: imageName });

	const metadataData = await fetchAltUrlToUint8Array(urls[1]);
	collection.push({ data: metadataData, path: 'metadata.json' });

	let html = '<html><body><h1>AutoSwarm</h1>';
	if (imageMainType == 'image') {
		html += `<img width="150" src="${imageName}"><br/><br/>`;
	}
	html += `<a href="${imageName}">${imageName}</a></li><br/><br/>`;
	html += `<a href="metadata.json">metadata.json</a><br/><br/></body></html>`;
	html += '</body></html>';
	const indexHtml = new TextEncoder().encode(html);
	collection.push({ data: indexHtml, path: INDEX_HTML });

	const json = `{"image": "${imageName}", "metadata": "metadata.json"}`;
	const listJson = new TextEncoder().encode(json);
	collection.push({ data: listJson, path: LIST_JSON });

	return [makeTar(collection), imageName];
};

const fetchBzzTarPost = async (body: Uint8Array | undefined): Promise<Hex> => {
	if (!body) throw new Error('fetchBzzTarPost: No body defined!');

	console.log('fetchBzzTarPost ~ body.length', body.length);

	const api = beeApiBzz();
	const batchId = beeBatchId();
	if (!bzz0(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const headers = new Headers();
	headers.append('Accept', 'application/json, text/plain, */*');
	headers.append('Content-Type', 'application/x-tar');
	headers.append('Swarm-Postage-Batch-Id', batchId);
	headers.append('Swarm-Pin', 'true');
	headers.append('Swarm-Collection', 'true');
	headers.append('Swarm-Index-Document', INDEX_HTML);

	const hash = await fetchBzzPost(api, body, headers);
	console.log('fetchBzzTarPost hash:', hash);

	return hash;
};

export { fetchBzzTar, fetchBzzTarPost };
