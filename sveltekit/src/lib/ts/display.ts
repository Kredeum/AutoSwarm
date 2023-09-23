import { formatUnits, type Chain, isAddress } from 'viem';
import {
	UNDEFINED_ADDRESS,
	UNDEFINED_DATA,
	DIVISION_BY_ZERO,
	SECONDS_PER_BLOCK,
	ONE_WEEK,
	ONE_DAY,
	ONE_HOUR,
	ONE_MONTH,
	ONE_YEAR
} from '$lib/ts/constants';

///////////////////////////////////////////////////////////////////////////////////////////////////
// DISPLAY : offline functions returns [html] string to display
///////////////////////////////////////////////////////////////////////////////////////////////////

const displayAddress = (addr: string): string => {
	if (!isAddress(addr)) return UNDEFINED_ADDRESS;

	return addr;
};

const displayTxt = (data: string | number | bigint | undefined): string => {
	if (data === undefined) return UNDEFINED_DATA;

	return String(data);
};

const displayTtl = (balance: bigint | undefined, lastPrice: bigint | undefined): string => {
	if (balance === undefined || lastPrice === undefined) return UNDEFINED_DATA;
	if (lastPrice == 0n) return DIVISION_BY_ZERO;

	return displayDuration((balance * SECONDS_PER_BLOCK) / lastPrice);
};

const displayDuration = (seconds: bigint | undefined): string => {
	if (seconds === undefined) return `${UNDEFINED_DATA} weeks`;

	const hours = Number(seconds) / ONE_HOUR;
	const days = Number(seconds) / ONE_DAY;
	const weeks = Number(seconds) / ONE_WEEK;
	const months = Number(seconds) / ONE_MONTH;
	const years = Number(seconds) / ONE_YEAR;

	const ret =
		hours < 24
			? `${hours.toFixed(2)} hour${hours > 1 ? 's' : ''}`
			: days < 7
			? `${days.toFixed(2)} day${days > 1 ? 's' : ''}`
			: weeks < 5
			? `${weeks.toFixed(2)} week${weeks > 1 ? 's' : ''}`
			: days < 365
			? `${months.toFixed(2)} month${months > 1 ? 's' : ''}`
			: `${years.toFixed(2)} year${years > 1 ? 's' : ''}`;

	return ret;
};

const displayExplorerLink = (chain: Chain, addr: string | undefined): string => {
	if (addr === undefined || !isAddress(addr)) return UNDEFINED_ADDRESS;

	const explorer =
		chain?.blockExplorers?.etherscan?.url || chain?.blockExplorers?.default?.url || '';

	return `<a href="${explorer}/address/${addr}" target="_blank">${addr}</a>`;
};

const displayBzzFromBalance = (balance: bigint | undefined, depth: number | undefined): string => {
	if (balance === undefined || depth === undefined) return UNDEFINED_DATA;

	return displayBalance(balance * 2n ** BigInt(depth), 16);
};

const displayBalance = (
	balance: bigint | undefined,
	decimals: number = 18,
	toFixed: number = 3
): string => {
	if (balance === undefined) return UNDEFINED_DATA;

	const str = formatUnits(balance, decimals);

	return Number(str).toFixed(toFixed);
};

const displayNftLink = (chain: Chain, collection: string, tokenId: number): string => {
	if (!isAddress(collection)) return UNDEFINED_DATA;

	const url = `https://app.kredeum.com/#/${chain.id}/${collection}/${tokenId}`;
	return `<a href="${url}" target="_blank"> #${tokenId}</a>`;
};

export {
	displayTxt,
	displayTtl,
	displayNftLink,
	displayBalance,
	displayAddress,
	displayDuration,
	displayExplorerLink,
	displayBzzFromBalance
};
