import {
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID,
	SWARM_GATEWAY,
	ZERO_BYTES32
} from '../constants/constants';
import { localConfigGet } from '../constants/local';
import { fetchUrlOk } from './fetch';

const _Uint8ArrayToBinary = (u8Array: Uint8Array): string => {
	let bin = '';
	for (let i = 0; i < u8Array.length; i++) bin += String.fromCharCode(u8Array[i]);
	return bin;
};

// TOO BUGGY
const fetchBzzMultipartTooBuggy = async (urls: (string | undefined)[]): Promise<string> => {
	const boundary = `AUTOSWARM${Math.random().toString().substr(8)}`;
	const swarmApiUrl = localConfigGet('api') || SWARM_DEFAULT_API;
	const batchId = (localConfigGet('batchId') || SWARM_DEFAULT_BATCHID).replace(/^0x/, '');
	if (batchId === ZERO_BYTES32) throw new Error('No BatchId defined!');

	let body = '';

	for (let index = 0; index < urls.length; index++) {
		const url = urls[index];
		console.log('fetchBzzMultipart ~ url:', url);
		if (!(url && fetchUrlOk(url))) throw new Error('Bad URL');

		const blob = await (await fetch(url)).blob();
		const uint8Array = new Uint8Array(await blob.arrayBuffer());
		const binary = _Uint8ArrayToBinary(uint8Array);

		body += `--${boundary}\r\n`;
		body += `Content-Disposition: form-data; name="part${index}"\r\n`;
		body += `Content-Type: ${blob.type}\r\n`;
		body += `Content-Length: ${blob.size}\r\n`;
		body += '\r\n';
		body += binary;
		body += '\r\n';
	}
	body += `--${boundary}--`;
	console.log('fetchBzzMultipart', body.length, '\n', body);

	const headers = new Headers();
	headers.append('Content-Type', `multipart/form-data; boundary=${boundary}`);
	headers.append('swarm-postage-batch-id', batchId);
	headers.append('swarm-pin', 'true');
	headers.append('swarm-collection', 'true');

	const response = await fetch(swarmApiUrl, { method: 'POST', headers, body });

	const json = await response.json();
	if (!response.ok) {
		throw Error(`${response.statusText}\n${JSON.stringify(json, null, 2)}`);
	}

	console.log('fetchBzzMultipart', await response.json());

	return `${SWARM_GATEWAY}/${json.reference}/`;
};

export { fetchBzzMultipartTooBuggy };
