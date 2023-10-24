type NftMetadata = {
	name: string;
	description: string;
	image: string;
	tokenId: string;
	address: string;
};

const SWARM_GATEWAY = 'https://api.gateway.ethswarm.org/bzz/';

const SEPOLIA_RPC = 'https://ethereum-sepolia.publicnode.com';
// const SEPOLIA_RPC = "https://rpc.ankr.com/eth_sepolia";
// const SEPOLIA_RPC = "https://rpc.sepolia.org";

const SALT = 87283691n;

const BZZ_DECIMALS = 16;

const ONE_HOUR = 3600;
const ONE_DAY = ONE_HOUR * 24;
const ONE_WEEK = ONE_DAY * 7;
const ONE_MONTH = ONE_DAY * 30;
const ONE_YEAR = ONE_DAY * 365;

const AUTOSWARM_PERIOD = ONE_YEAR; // 1 year
const AUTOSWARM_UNIT = 1024 ** 2; // 1 Mo
const AUTOSWARM_UNIT_PRICE = 10n ** 15n; // 0.1 Bzz

const BUCKET_DEPTH = 16;
const BUCKET_SIZE = 4096;

const DEFAULT_PRICE = 24000n;
const SECONDS_PER_BLOCK = 5;

const DIVISION_BY_ZERO = '?????';
const UNDEFINED_ADDRESS = '0x****************************************';
const UNDEFINED_DATA = '*****';

export {
	type NftMetadata,
	SALT,
	ONE_HOUR,
	ONE_DAY,
	ONE_WEEK,
	ONE_MONTH,
	ONE_YEAR,
	BUCKET_DEPTH,
	BUCKET_SIZE,
	BZZ_DECIMALS,
	DEFAULT_PRICE,
	SECONDS_PER_BLOCK,
	DIVISION_BY_ZERO,
	UNDEFINED_ADDRESS,
	UNDEFINED_DATA,
	SWARM_GATEWAY,
	SEPOLIA_RPC,
	AUTOSWARM_PERIOD,
	AUTOSWARM_UNIT,
	AUTOSWARM_UNIT_PRICE
};
