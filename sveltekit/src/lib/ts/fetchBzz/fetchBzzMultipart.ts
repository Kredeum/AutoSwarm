import type { Hex } from 'viem';

import { INDEX_HTML } from '../constants/constants';
import { bzz0, bzzTrim } from '../swarm/bzz';
import { fetchAltUrlToBlob as fetchData } from '../fetch/fetchAlt';
import { fetchBzzPost } from './fetchBzz';
import { beeBatchId, beeApiBzz } from '../swarm/bee';

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

	const api = beeApiBzz();
	const batchId = beeBatchId();
	if (!bzz0(batchId)) throw new Error('fetchBzzTar: No BatchId defined!');

	const collection: Part[] = [];
	collection.push({ data: await fetchData(urls[0]), path: 'image.jpeg' });
	collection.push({ data: await fetchData(urls[1]), path: 'metadata.json' });

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
