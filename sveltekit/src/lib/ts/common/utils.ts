import type { Hex } from 'viem';
import { ZERO_BYTES32 } from '../constants/constants';

const utilsIsBytes32Null = (b32: Hex | undefined): boolean => Boolean(!b32 || b32 === ZERO_BYTES32);

const utilsTruncate = (str: string | undefined, start = 45, end = 25): string | undefined => {
	if (str === undefined) return;
	if (str.length <= start + end) return str;
	return str.slice(0, start) + '...' + str.slice(str.length - end);
};

const utilsDivUp = (a: bigint | number, b: bigint | number): bigint => {
	return BigInt(a) == 0n ? 0n : (BigInt(a) - 1n) / BigInt(b) + 1n;
};

const utilsUint8ArrayToHex = (bytes: Uint8Array): Hex => {
	const hexByte = (n: number) => n.toString(16).padStart(2, '0');
	const hex = Array.from(bytes, hexByte).join('') as Hex;

	return `0x${hex}` as Hex;
};

export { utilsDivUp, utilsIsBytes32Null, utilsTruncate, utilsUint8ArrayToHex };
