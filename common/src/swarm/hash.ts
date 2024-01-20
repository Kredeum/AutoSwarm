import type { Hex } from 'viem';
import { makeChunkedFile } from '@fairdatasociety/bmt-js';
import { utilsUint8ArrayToHex } from '../common/utils';
import { readFileSync } from 'fs';

const swarmHash = (data: Uint8Array): Hex => {
	const chunkedFile = makeChunkedFile(data);

	const address = chunkedFile.address();
	const hash = utilsUint8ArrayToHex(address);

	// console.info('swarmHash:', hash);
	return hash as Hex;
};

const swarmHashFromUrl = async (url: string): Promise<Hex> => {
	const response = await fetch(url);
	const body = new Uint8Array(await response.arrayBuffer());

	return swarmHash(body);
};

const swarmHashFromString = (str: string): Hex => {
	const body = new TextEncoder().encode(str);
	// console.info('swarmHashFromString ~ body:', body);

	return swarmHash(body);
};

const swarmHashFromFile = (path: string): Hex => swarmHash(readFileSync(path));

export { swarmHash, swarmHashFromUrl, swarmHashFromString, swarmHashFromFile };
