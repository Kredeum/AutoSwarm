const ZERO_BYTES32 = '0x0000000000000000000000000000000000000000000000000000000000000000';
const SALT = '0x0000012312321300000000000000000000000000000000000293008712982323';

const METADATA_JSON = 'metadata.json';
const IMAGE_JPEG = 'image.jpeg';

const SWARM_DEFAULT_API = 'http://127.0.0.1:1633';
const SWARM_DEFAULT_BATCHID = ZERO_BYTES32;

const SWARM_GATEWAY = 'https://api.gateway.ethswarm.org/bzz';
const IPFS_GATEWAY = 'https://ipfs.io/ipfs';
const ARWEAVE_GATEWAY = 'https://arweave.net';

const BZZ_DECIMALS = 16;

const ONE_HOUR = 3600;
const ONE_DAY = ONE_HOUR * 24;
const ONE_WEEK = ONE_DAY * 7;
const ONE_MONTH = ONE_DAY * 30;
const ONE_YEAR = ONE_DAY * 365;

const CHUNK_PRICE_DEFAULT = 24000n;
const SECONDS_PER_BLOCK = 5;

const CHUNK_SIZE = 2n ** 12n; // 4096 bytes / 4 Kb
const BUCKET_DEPTH = 16;

const STAMP_TTL = ONE_YEAR;
const STAMP_SIZE = 1024n ** 1n; // 1 Ko for TESTS
const STAMP_PRICE = 10n ** 12n; // 0.001 Bzz
// const STAMP_SIZE = 1024n ** 2n; // 1 Mo
// const STAMP_PRICE = 10n ** 15n; // 0.1 Bzz

const BATCH_TTL = ONE_MONTH; // 30 days
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
	SWARM_DEFAULT_API,
	SWARM_DEFAULT_BATCHID,
	SWARM_GATEWAY,
	IPFS_GATEWAY,
	ARWEAVE_GATEWAY,
	STAMP_TTL,
	STAMP_SIZE,
	STAMP_PRICE,
	BATCH_TTL,
	BATCH_DEPTH,
	BATCH_SIZE,
	METADATA_JSON,
	IMAGE_JPEG
};
