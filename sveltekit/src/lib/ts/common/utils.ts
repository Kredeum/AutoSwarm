import type { Hex } from 'viem';
import { ZERO_BYTES32 } from '../constants/constants';

import { alertMessage } from '$lib/ts/stores/alerts';

const utilsError = (label: string, err?: unknown) => {
	const message = `${label} : ${err}`;
	console.error(message);
	// alert(message);
	alertMessage.set({ status: 'error', message });
};

const utilsIsBytes32Null = (b32: Hex | undefined): boolean => Boolean(!b32 || b32 === ZERO_BYTES32);

const utilsTruncate = (str: string | undefined, start: number, end: number): string | undefined => {
	if (str === undefined) return;
	if (str.length <= start + end) return str;
	return str.slice(0, start) + '...' + str.slice(str.length - end);
};

const utilsDivUp = (a: bigint | number, b: bigint | number): bigint => {
	return BigInt(a) == 0n ? 0n : (BigInt(a) - 1n) / BigInt(b) + 1n;
};

export { utilsError, utilsDivUp, utilsIsBytes32Null, utilsTruncate };
