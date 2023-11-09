import { formatUnits, type Chain, isAddress, type Address } from 'viem';
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
} from '$lib/ts/constants';
import { utilsNBalToBzz, utilsNBalToTtl } from './utils';
import { batchSizeBatch } from './batch';
import { chainGet } from './chains';

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

const displaySize = (size: bigint | number | undefined): string => {
	if (size === undefined) return UNDEFINED_DATA;

	if (size < 1024) return `${size} B`;

	const kbytes = Number(size) / 1024;
	if (kbytes < 1024) return `${size} KB`;

	const mbytes = Number(size) / 1024 ** 2;
	if (mbytes < 1024) return `${mbytes} MB`;

	const gbytes = Number(size) / 1024 ** 3;
	return `${gbytes} GB`;
};

const displayDuration = (seconds: bigint | number | undefined): string => {
	if (seconds === undefined) return `${UNDEFINED_DATA} weeks`;

	const hours = Number(seconds) / ONE_HOUR;
	if (hours < 24) return `${Number(hours).toFixed(2)} hour${hours > 1 ? 's' : ''}`;

	const days = Number(seconds) / ONE_DAY;
	if (days < 7) return `${Number(days).toFixed(2)} day${days > 1 ? 's' : ''}`;

	const weeks = Number(seconds) / ONE_WEEK;
	if (weeks < 5) return `${Number(weeks).toFixed(2)} week${weeks > 1 ? 's' : ''}`;

	const months = Number(seconds) / ONE_MONTH;
	if (days < 365) return `${Number(months).toFixed(2)} month${months > 1 ? 's' : ''}`;

	const years = Number(seconds) / ONE_YEAR;

	const ret = `${Number(years).toFixed(2)} year${years > 1 ? 's' : ''}`;
	console.log('ret:', ret);
	return ret;
};

const displayExplorerLink = (chainId: number, addr?: string): string => {
	const chain = chainGet(chainId);
	const explorer =
		chain?.blockExplorers?.etherscan?.url || chain?.blockExplorers?.default?.url || '';

	return addr && isAddress(addr)
		? `<a href="${explorer}/address/${addr}" target="_blank">${addr}</a>`
		: `<a href="${explorer}" target="_blank">${chainId}</a>`;
};

const displayBzzFromNBal = (balance: bigint | undefined, depth: number | undefined): string => {
	if (balance === undefined || depth === undefined) return UNDEFINED_DATA;

	return displayBalance(utilsNBalToBzz(balance, depth), BZZ_DECIMALS);
};

const displayBalance = (
	balance: bigint | undefined,
	decimals: number = 18,
	toFixed: number = 3
): string => {
	if (balance === undefined) return UNDEFINED_DATA;

	const str = Number(formatUnits(balance, Number(decimals)));

	return str.toFixed(Number(toFixed));
};

const displayNftLink = (chainId: number, collection: string, tokenId: bigint): string => {
	if (!isAddress(collection)) return UNDEFINED_DATA;

	const url = `https://app.kredeum.com/#/${chainId}/${collection}/${tokenId}`;
	return `<a href="${url}" target="_blank"> #${tokenId}</a>`;
};

export {
	displayTxt,
	displayTtl,
	displayNftLink,
	displayBalance,
	displayAddress,
	displayDuration,
	displayTbaDisplayed,
	displaySize,
	displayDate,
	displayBatchSize,
	displayBatchDepthWithSize,
	displayExplorerLink,
	displayBzzFromNBal
};
