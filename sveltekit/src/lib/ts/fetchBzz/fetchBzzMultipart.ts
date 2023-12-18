import type { Hex } from 'viem';

import {
	CONTENT,
	INDEX_HTML,
	METADATA_JSON,
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID
} from '../constants/constants';
import { localConfigGet } from '../common/local';
import { bzz0, bzzTrim } from '../swarm/bzz';
import { fetchAltUrlToBlob as fetchData } from '../fetch/fetchAlt';
import { fetchBzzPost } from './fetchBzz';

const _blobToBinary = async (blob: Blob): Promise<string> => {
	const arrayBuffer = await new Response(blob).arrayBuffer();
	const uint8Array = new Uint8Array(arrayBuffer);

	let bin = '';
	for (let i = 0; i < uint8Array.length; i++) bin += String.fromCharCode(uint8Array[i]);
	return bin;
};

const _bodyPart = async (blob: Blob, path: string, boundary: string): Promise<string> => {
	const binary = await _blobToBinary(blob);
	console.log('const_bodyPart= ~ blob.size:', blob.size);
	console.log('const_bodyPart= ~ binary.length:', binary.length);

	let body = `--${boundary}\r\n`;
	body += `Content-Disposition: form-data; name="${path}"; filename="${path}"\r\n`;
	body += `Content-Type: ${blob.type}\r\n`;
	body += `Content-Length: ${blob.size}\r\n`;
	body += '\r\n';
	body += binary;
	body += '\r\n';

	return body;
};

const makecollection = async (parts: Part[], boundary: string): Promise<string> => {
	let body = '';
	for await (const item of parts) {
		body += await _bodyPart(item.data, item.path, boundary);
	}
	body += `--${boundary}--`;
	return body;
};

type Part = {
	data: Blob;
	path: string;
};

// TOO BUGGY
const fetchBzzMultipart = async (
	urls: (string | undefined)[]
): Promise<[Hex, bigint, string[], number[]]> => {
	const boundary = `AUTOSWARM${Math.random().toString().substr(8)}`;

	const api = `${localConfigGet('api') || SWARM_DEFAULT_API}/bzz`;
	const batchId = bzzTrim(localConfigGet('batchId') || SWARM_DEFAULT_BATCHID);
	if (!bzz0(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const data = new Blob(
		[
			`<html><body><h1>AutoSwarm</h1>
      <img width="150" src="${CONTENT}"><br/><br/>
      <a href="${CONTENT}">${CONTENT}</a></li><br/><br/>
      <a href="${METADATA_JSON}">${METADATA_JSON}</a><br/><br/></body></html>`
		],
		{ type: 'text/html' }
	);

	const collection: Part[] = [];
	collection.push({ data, path: INDEX_HTML });
	collection.push({ data: await fetchData(urls[0]), path: CONTENT });
	collection.push({ data: await fetchData(urls[1]), path: METADATA_JSON });

	const body = await makecollection(collection, boundary);
	const bodySize = BigInt(body.length);
	console.log('fetchBzzMultipart', bodySize, '\n', body);

	const headers = new Headers();
	headers.append('Accept', 'application/json, text/plain, */*');
	headers.append('Content-Type', `multipart/form-data; boundary=${boundary}`);
	headers.append('Swarm-Postage-Batch-Id', batchId);
	headers.append('Swarm-Pin', 'true');
	headers.append('Swarm-Collection', 'true');
	headers.append('Swarm-Index-Document', INDEX_HTML);

	const hash = await fetchBzzPost(api, body, headers);
	console.log('fetchBzzMultipart hash:', hash);

	collection.shift();
	const paths = collection.map((item) => `${api}/${bzzTrim(hash)}/${item.path}`);
	const sizes = collection.map((item) => item.data.size);

	return [hash, bodySize, paths, sizes];
};

export { fetchBzzMultipart };
