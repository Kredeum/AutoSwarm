type NftMetadata = {
	name: string;
	description: string;
	image: string;
	tokenId: string;
	address: string;
};

const SALT = 87283691n;

const ONE_HOUR = 3600;
const ONE_DAY = ONE_HOUR * 24;
const ONE_WEEK = ONE_DAY * 7;
const ONE_MONTH = ONE_DAY * 30;
const ONE_YEAR = ONE_DAY * 365;

const DEFAULT_PRICE = 24000n;
const SECONDS_PER_BLOCK = 5n;

const DIVISION_BY_ZERO = '?????';
const UNDEFINED_ADDRESS = '0x****************************************';
const UNDEFINED_DATA = '*****';

const SWARM_GATEWAY = 'https://api.gateway.ethswarm.org/bzz/';

export {
	type NftMetadata,
	SALT,
	ONE_HOUR,
	ONE_DAY,
	ONE_WEEK,
	ONE_MONTH,
	ONE_YEAR,
	DEFAULT_PRICE,
	SECONDS_PER_BLOCK,
	DIVISION_BY_ZERO,
	UNDEFINED_ADDRESS,
	UNDEFINED_DATA,
	SWARM_GATEWAY
};
