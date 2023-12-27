import { keccak256, toHex } from 'viem';

const SALT = keccak256(toHex('AutoSwarm v0.0.3'));

const ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000';

const INDEX_HTML = 'autoswarm.html';
const LIST_JSON = 'list.json';

const BZZ_CHAIN_ID_DEFAULT = '100';

const BEE_API_DEFAULT = 'http://127.0.0.1:1633';
const BEE_BATCHID_DEFAULT = ZERO_BYTES32;
const BEE_GATEWAY_DEFAULT = 'http://127.0.0.1:1633';
// const BEE_GATEWAY_DEFAULT = 'https://api.gateway.ethswarm.org/bzz';

const IPFS_GATEWAY_DEFAULT = 'https://ipfs.io/ipfs';
const ARWEAVE_GATEWAY_DEFAULT = 'https://arweave.net';

const BZZ_DECIMALS = 16;

const ONE_HOUR = 3600;
const ONE_DAY = ONE_HOUR * 24;
const ONE_WEEK = ONE_DAY * 7;
const ONE_MONTH = ONE_DAY * 30;
const ONE_YEAR = ONE_DAY * 365;

const SECONDS_PER_BLOCK = 5;
const CHUNK_PRICE_DEFAULT = 24000n;

const CHUNK_SIZE = 2n ** 12n; // 4096 bytes / 4 Kb
const BUCKET_DEPTH = 16;


const STAMP_TTL = ONE_YEAR;


// TESTS //////////////////////////////////////////////////////
// const BATCH_TTL = 30 * ONE_HOUR; // 30 hours for TEST
// const STAMP_SIZE = 1024n ** 1n; // 1 Ko for TEST
// const STAMP_PRICE = 10n ** 12n; // 0.0001 BZZ for TEST

// PROD //////////////////////////////////////////////////////
const BATCH_TTL = ONE_MONTH; // 30 days
const STAMP_SIZE = 1024n ** 2n; // 100 Ko for PROD
const STAMP_PRICE = 10n ** 15n; // 0.01 BZZ for PROD

const BATCH_DEPTH = 23; // 2**23
const BATCH_SIZE = CHUNK_SIZE * 2n ** BigInt(BATCH_DEPTH); // 32 Go

const DIVISION_BY_ZERO = '?????';
const UNDEFINED_ADDRESS = '0x****************************************';
const UNDEFINED_DATA = '*****';

export {
	SALT,
	ONE_HOUR,
	ONE_DAY,
	ONE_WEEK,
	ONE_MONTH,
	ONE_YEAR,
	BUCKET_DEPTH,
	CHUNK_SIZE,
	BZZ_DECIMALS,
	CHUNK_PRICE_DEFAULT,
	SECONDS_PER_BLOCK,
	DIVISION_BY_ZERO,
	UNDEFINED_ADDRESS,
	UNDEFINED_DATA,
	ZERO_BYTES32,
	BEE_API_DEFAULT,
	BEE_BATCHID_DEFAULT,
	BEE_GATEWAY_DEFAULT,
	IPFS_GATEWAY_DEFAULT,
	ARWEAVE_GATEWAY_DEFAULT,
	STAMP_TTL,
	STAMP_SIZE,
	STAMP_PRICE,
	BATCH_TTL,
	BATCH_DEPTH,
	BATCH_SIZE,
	INDEX_HTML,
	LIST_JSON,
	BZZ_CHAIN_ID_DEFAULT
};
