import type { Hex } from 'viem';
import { ZERO_BYTES32 } from '../constants/constants';

const utilsError = (label: string, err?: unknown) => {
	const message = `${label} : ${err}`;
	console.error(message);
	// alert(message);
};

const utilsIsBytes32Null = (b32: Hex | string | undefined): boolean =>
	Boolean(!b32 || b32 === ZERO_BYTES32);

const utilsTruncate = (str: string | undefined, start: number, end : number): string | undefined => {
  if (str === undefined) return;
  if (str.length <= start + end) return str;
  return str.slice(0, start) + '...' + str.slice(str.length - end);
};

export { utilsError, utilsIsBytes32Null, utilsTruncate };
