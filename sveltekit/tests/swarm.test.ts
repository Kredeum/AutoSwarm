import { expect, test } from 'vitest';

import { makeChunkedFile } from '@fairdatasociety/bmt-js';
import { utilsUint8ArrayToHex } from '$lib/ts/common/utils';
import {
	swarmHash,
	swarmHashFromFile,
	swarmHashFromString,
	swarmHashFromUrl
} from '$lib/ts/swarm/hash';

import { fetchBeePost, fetchBeePostFromUrl } from '$lib/ts/fetchBee/fetchBee';
import { bzzTrim } from '$lib/ts/swarm/bzz';
import { beeApiBzz } from '$lib/ts/swarm/bee';

const batchId = '0xe583912358f3d0842db20bc79799df53d5a6db843560d1a1148bc422b42cd59b';

const chunkedFileAddress = (payload: Uint8Array) =>
	utilsUint8ArrayToHex(makeChunkedFile(payload).address());

const str0 = '012';
const str0Hash = '0xa0f1f2342dd5b99f6d8375729c6196a72e31d603f5fcbeef0d6d01f7e15a1a69';
const str1 = 'Bonjour';
const str1Hash = '0xa89ee6a679816ce6fc1780ac68218a08d1f54fd5fb8483ca3c40566a098fbfdd';
const str2 = 'Déjà Noël!';
const str2Hash = '0xc372e502d3ac3eeee5b1c4f31ecf9220bb36bf92b091d5f6464ab4627d774512';

const file0 = 'tests/files/text0.txt';
const file0Hash = str0Hash;
const file1 = 'tests/files/text1.txt';
const file1Hash = str1Hash;
const file2 = 'tests/files/text2.txt';
const file2Hash = str2Hash;

const payload0 = new Uint8Array([0x30, 0x31, 0x32]);
const payload0Hash = '0xa0f1f2342dd5b99f6d8375729c6196a72e31d603f5fcbeef0d6d01f7e15a1a69';
const payload1 = new Uint8Array([123, 12]);
const payload1Hash = '0x34b612da65eadd4f9a2e462e55e7912884059f4d1ccde7ce8b7fe78f27dd1093';
const payload2 = new Uint8Array([2, 22, 21, 8, 2, 0]);
const payload2Hash = '0xa51e2a3702959ac71a1e9603b6d50862691400a911fc2743d6264a40358125e4';

const url0 =
	'https://api.gateway.ethswarm.org/bzz/f0ca4cdae4d82ba29eb669eff6ee21e514637ebf19926856d98585073c8319ab/metadata.json';
const url1 =
	'https://api.gateway.ethswarm.org/bzz/f0ca4cdae4d82ba29eb669eff6ee21e514637ebf19926856d98585073c8319ab/image.jpeg';
const url2 =
	'https://api.gateway.ethswarm.org/bzz/441a8e4274f10eabcc213613cfbd7fbfd81ad3c5c7a8c054d7690531abb3d9ab';
const url0Hash = '0x7ff0ce3f685bf5ca624fe098968cfe7201b8de474e6019aa73f2118c0e95c7cd';
const url1Hash = '0xb4f5882f3d3854f61852e53a5cbbbee8d4b5887f1d8207e3f8996f15ecfefa23';
const url2Hash = '0x047a5c638f7717b3583b34a98d93eb87c3c79e7b6d0a92d6d3a8756d1976c3cc';

test('OK', () => expect(true).toBe(true));

// CHUNKED FILE ADDRESS
test('chunkedFile.address', () => expect(chunkedFileAddress(payload0)).toBe(payload0Hash));
test('chunkedFile.address', () => expect(chunkedFileAddress(payload1)).toBe(payload1Hash));
test('chunkedFile.address', () => expect(chunkedFileAddress(payload2)).toBe(payload2Hash));

// SWARM HASH
test('swarmHash (payload0)', () => expect(swarmHash(payload0)).toBe(payload0Hash));
test('swarmHash (payload1)', () => expect(swarmHash(payload1)).toBe(payload1Hash));
test('swarmHash (payload2)', () => expect(swarmHash(payload2)).toBe(payload2Hash));

// SWARM HASH FROM URL
test('swarmHashFromUrl (url0)', async () => expect(await swarmHashFromUrl(url0)).toBe(url0Hash));
test('swarmHashFromUrl (url1)', async () => expect(await swarmHashFromUrl(url1)).toBe(url1Hash));
test('swarmHashFromUrl (url2)', async () => expect(await swarmHashFromUrl(url2)).toBe(url2Hash));

// SWARM HASH FROM STRING
test('swarmHashFromString (str0)', () => expect(swarmHashFromString(str0)).toBe(str0Hash));
test('swarmHashFromString (str1)', () => expect(swarmHashFromString(str1)).toBe(str1Hash));
test('swarmHashFromString (str2)', () => expect(swarmHashFromString(str2)).toBe(str2Hash));

// SWARM HASH FROM FILE
test('swarmHashFromFile (file0)', async () => expect(swarmHashFromFile(file0)).toBe(file0Hash));
test('swarmHashFromFile (file1)', async () => expect(swarmHashFromFile(file1)).toBe(file1Hash));
test('swarmHashFromFile (file2)', async () => expect(swarmHashFromFile(file2)).toBe(file2Hash));

test('fetchBeePostFromUrl', async () => {
	const url =
		'https://api.gateway.ethswarm.org/bzz/441a8e4274f10eabcc213613cfbd7fbfd81ad3c5c7a8c054d7690531abb3d9ab';
	const hash = await fetchBeePostFromUrl(url, batchId);
	console.log('test ~ hash:', hash);
	const url2 =
		'https://api.gateway.ethswarm.org/bzz/f030cdf841cc74990513fcc422fbbc292288d2e6efc1eb1865f32df4bdda9bc7';
	const hash2 = await fetchBeePostFromUrl(url2, batchId);
	const hash3 = await swarmHashFromUrl(url2);

	console.log('test ~ hash2:', hash2);
	console.log('test ~ hash3:', hash3);
});

test.only('fetchBeePostFromUrl blob or not', async () => {
	const body = new Blob(['012']);
	const headers = new Headers();
	headers.append('Swarm-Postage-Batch-Id', bzzTrim(batchId));
	headers.append('Content-Type', 'text/plain');

	const hash = await fetchBeePost(beeApiBzz(), body, headers);
	console.log('test ~ hash:', hash);
});
