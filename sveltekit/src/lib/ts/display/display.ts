import { formatUnits, isAddress, type Address, type Hex } from 'viem';
import {
	UNDEFINED_ADDRESS,
	UNDEFINED_DATA,
	DIVISION_BY_ZERO,
	ONE_WEEK,
	ONE_DAY,
	ONE_HOUR,
	ONE_MONTH,
	ONE_YEAR,
	BZZ_DECIMALS,
	BUCKET_DEPTH
} from '$lib/ts/constants/constants';
import { utilsNBalToBzz, utilsNBalToTtl } from '../swarm/utils';
import { batchSizeBatch } from '../swarm/batch';
import { utilsIsNullBytes32, utilsTruncate } from '../common/utils';
import { bzz, bzz0, bzzTrim } from '../swarm/bzz';
import { beeApiBzz, beeGatewayBzz } from '../swarm/bee';

///////////////////////////////////////////////////////////////////////////////////////////////////
// DISPLAY : offline functions returns [html] string to display
///////////////////////////////////////////////////////////////////////////////////////////////////

const displayDate = (timestamp: bigint | number | undefined): string => {
	if (timestamp === undefined) return UNDEFINED_DATA;

	return new Date(Number(timestamp) * 1000).toLocaleDateString();
};

const displayAddress = (addr: Address | undefined): string => {
	if (addr === undefined) return UNDEFINED_ADDRESS;

	return addr;
};

const displayTbaDisplayed = (deployed: boolean | undefined): string => {
	if (deployed === undefined) return UNDEFINED_DATA;

	return deployed ? 'deployed' : 'not deployed';
};

const displayTxt = (data: string | number | bigint | undefined): string => {
	if (data === undefined) return UNDEFINED_DATA;

	return String(data);
};

const displayTtl = (balance: bigint | undefined, lastPrice: bigint | undefined): string => {
	if (balance === undefined || lastPrice === undefined) return UNDEFINED_DATA;
	if (lastPrice == 0n) return DIVISION_BY_ZERO;

	return displayDuration(utilsNBalToTtl(balance, lastPrice));
};

const displayBatchDepthWithSize = (depth: number | undefined): string => {
	if (depth === undefined) return UNDEFINED_DATA;
	if (!(depth && depth > BUCKET_DEPTH)) return `${depth} invalid`;

	return `depth ${depth} (${displayBatchSize(depth)})`;
};

const displayBatchSize = (depth: number | undefined): string => displaySize(batchSizeBatch(depth));

const displaySize = (size: bigint | number | undefined, toFixed: number = 3): string => {
	if (size === undefined) return UNDEFINED_DATA;

	if (size < 1024) return `${size} bytes`;

	const kbytes = Number(size) / 1024;
	if (kbytes < 1024) return `${kbytes.toFixed(toFixed)} Kb`;

	const mbytes = Number(size) / 1024 ** 2;
	if (mbytes < 1024) return `${mbytes.toFixed(toFixed)} Mb`;

	const gbytes = Number(size) / 1024 ** 3;
	return `${gbytes.toFixed(toFixed)} Gb`;
};

const displayDuration = (seconds: bigint | number | undefined): string => {
	if (seconds === undefined) return `${UNDEFINED_DATA} days`;

	const hours = Number(seconds) / ONE_HOUR;
	if (hours < 24) return `${Number(hours).toFixed(2)} hour${hours >= 1.01 ? 's' : ''}`;

	const days = Number(seconds) / ONE_DAY;
	if (days < 60) return `${Number(days).toFixed(2)} day${days >= 1.01 ? 's' : ''}`;

	const weeks = Number(seconds) / ONE_WEEK;
	if (weeks < 12) return `${Number(weeks).toFixed(2)} week${weeks >= 1.01 ? 's' : ''}`;

	const months = Number(seconds) / ONE_MONTH;
	if (days < 365) return `${Number(months).toFixed(2)} month${months >= 1.01 ? 's' : ''}`;

	const years = Number(seconds) / ONE_YEAR;

	const duration = `${Number(years).toFixed(2)} year${years >= 1.01 ? 's' : ''}`;
	// console.log('duration:', duration);
	return duration;
};

const displayBzzFromNBal = (balance: bigint | undefined, depth: number | undefined): string => {
	if (balance === undefined || depth === undefined) return UNDEFINED_DATA;

	return displayBalance(utilsNBalToBzz(balance, depth), BZZ_DECIMALS);
};

const displayBzzURI = (str: Hex | string | undefined, path?: string): string => {
	// console.log('displayBzzURI', str, bzzTrim(str));
	const hash = bzzTrim(str);
	if (utilsIsNullBytes32(bzz0(hash) as Hex)) return UNDEFINED_DATA;

	const hashPath = path ? `${hash}/${path}` : hash;
	const url = `${beeApiBzz()}/${hashPath}`;

	return `<a href="${url}" target="_blank">${utilsTruncate(bzz(hashPath))}</a>`;
};

const displayBzzURL = (str: Hex | string | undefined, path?: string): string => {
	const hash = bzzTrim(str);
	if (utilsIsNullBytes32(bzz0(hash) as Hex)) return UNDEFINED_DATA;
	// console.log('displayBzzURL ', hash, path);

	const hashPath = path ? `${hash}/${path}` : hash;
	const url = `${beeGatewayBzz()}/${hashPath}`;

	return `<a href="${url}" target="_blank">${utilsTruncate(url)}</a>`;
};

const displayBalance = (
	balance: bigint | undefined,
	decimals: number = 18,
	toFixed: number = 3
): string => {
	if (balance === undefined) return UNDEFINED_DATA;

	const str = Number(formatUnits(balance, Number(decimals)));

	return str.toFixed(toFixed);
};

const displayLink = (url: URL | string | undefined): string =>
	url === undefined ? '' : `<a href="${url}" target="_blank">${utilsTruncate(url.toString())}</a>`;

const displayNftLink = (
	chainId: number | undefined,
	collection: string | undefined,
	tokenId: bigint | undefined
): string => {
	if (!(chainId && chainId > 0 && collection && isAddress(collection) && tokenId && tokenId >= 0))
		return UNDEFINED_DATA;

	const url = `https://app.kredeum.com/#/${chainId}/${collection}/${tokenId}`;
	return `<a href="${url}" target="_blank">#${tokenId}</a>`;
};

const displaySizeBytes = (size: bigint | number | undefined): string =>
	`${size?.toString() || UNDEFINED_DATA} bytes`;

const displayPerCent = (a: bigint | number | undefined, b: bigint | number | undefined) => {
	if (a === undefined || b === undefined) return UNDEFINED_DATA;
	if (b === 0n) return DIVISION_BY_ZERO;

	return `${((Number(a) / Number(b)) * 100).toFixed(2)} %`;
};

export {
	displayTxt,
	displayTtl,
	displayLink,
	displayNftLink,
	displayPerCent,
	displayBalance,
	displayAddress,
	displayDuration,
	displayTbaDisplayed,
	displayBzzURL,
	displayBzzURI,
	displaySize,
	displaySizeBytes,
	displayDate,
	displayBatchSize,
	displayBatchDepthWithSize,
	displayBzzFromNBal
};
