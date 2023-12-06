import { BUCKET_SIZE } from '../constants/constants';
import { utilsNBalToTtl } from './utils';

// const batchBzzToNBal = (bzz: bigint, depth: bigint): bigint => {
// 	if (depth <= BUCKET_DEPTH) return 0n;

// 	return bzz / 2n ** BigInt(depth - BUCKET_DEPTH);
// };

const stampBzzToNBal = (bzz: bigint | undefined, size: number | undefined): bigint | undefined => {
	if (bzz === undefined || size === undefined) return undefined;
	if (size === 0) return 0n;

	return (bzz * BUCKET_SIZE) / BigInt(size);
};

const stampNBalToBzz = (nBal: bigint | undefined, size: number | undefined): bigint | undefined => {
	if (nBal === undefined || size === undefined) return undefined;

	return (nBal * BigInt(size)) / BUCKET_SIZE;
};

const stampBzzToTtl = (
	bzz: bigint | undefined,
	size: number | undefined,
	lastPrice: bigint | undefined
): bigint | undefined => utilsNBalToTtl(stampBzzToNBal(bzz, size), lastPrice);

export { stampNBalToBzz, stampBzzToNBal, stampBzzToTtl };
