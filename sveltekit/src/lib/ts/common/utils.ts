import type { Hex } from 'viem';
import { ZERO_BYTES32 } from '../constants/constants';

const utilsError = (label: string, err?: unknown) => {
	const message = `${label} : ${err}`;
	console.error(message);
	// alert(message);
};

const utilsIsBytes32Null = (b32: Hex | string | undefined): boolean =>
	Boolean(!b32 || b32 === ZERO_BYTES32);

export { utilsError, utilsIsBytes32Null };
