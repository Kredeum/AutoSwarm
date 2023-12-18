import type { Hex } from 'viem';
import { makeTar, type Collection } from '$lib/ts/swarm/tar';

import {
	CONTENT,
	METADATA_JSON,
	INDEX_HTML,
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID,
  INDEX_JSON,
  METADATA
} from '../constants/constants';
import { localConfigGet } from '../common/local';
import { bzz0, bzzTrim } from '../swarm/bzz';
import { fetchBzzPost } from './fetchBzz';
import { fetchAltUrlToBlob } from '../fetch/fetchAlt';

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

	const api = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = bzzTrim(localConfigGet('batchId') || SWARM_DEFAULT_BATCHID);
	if (!bzz0(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const metadataBlob = await fetchAltUrlToBlob(urls[1]);
	const metadataData = new Uint8Array(await metadataBlob.arrayBuffer());

	const contentBlob: Blob = await fetchAltUrlToBlob(urls[0]);
	const contentData = new Uint8Array(await contentBlob.arrayBuffer());
	const [content, contentMainType] = _fetchBlobFilename(contentBlob);

	let html = '<html><body><h1>AutoSwarm</h1>';
	if (contentMainType == 'image') {
		html += `<img width="150" src="${content}"><br/><br/>`;
	}
	html += `<a href="${content}">${content}</a></li><br/><br/>`;
	html += `<a href="${METADATA_JSON}">${METADATA_JSON}</a><br/><br/></body></html>`;
	html += '</body></html>';
	const indexHtml = new TextEncoder().encode(html);

	const json = `{"${CONTENT}": "${content}", "${METADATA}": "${METADATA_JSON}"}`;
	const indexJson = new TextEncoder().encode(json);

	const collection: Collection = [];
	collection.push({ data: indexHtml, path: INDEX_HTML });
	collection.push({ data: indexJson, path: INDEX_JSON });
	collection.push({ data: metadataData, path: METADATA_JSON });
	collection.push({ data: contentData, path: content });

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
	const paths = collection.map((item) => `${api}/${bzzTrim(hash)}/${item.path}`);
	const sizes = collection.map((item) => item.data.length);

	return [hash, bodySize, paths, sizes];
};

export { fetchBzzTar };
