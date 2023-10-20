import { batchBzzToNBal } from './batch';
import { BUCKET_DEPTH, BUCKET_SIZE } from './constants';
import { utilsNBalToTtl } from './utils';

// const batchBzzToNBal = (bzz: bigint, depth: bigint): bigint => {
// 	if (depth <= BUCKET_DEPTH) return 0n;

// 	return bzz / 2n ** BigInt(depth - BUCKET_DEPTH);
// };

const stampBzzToNBal = (bzz: bigint, size: number): bigint => {
	if (size === 0) return 0n;

	return (bzz * BigInt(BUCKET_SIZE)) / BigInt(size);
};

const stampNBalToBzz = (nBal: bigint, size: number): bigint =>
	(nBal * BigInt(size)) / BigInt(BUCKET_SIZE);

const stampBzzToTtl = (bzz: bigint, size: number, lastPrice: bigint): bigint =>
	utilsNBalToTtl(stampBzzToNBal(bzz, size), lastPrice);

export { stampNBalToBzz, stampBzzToNBal, stampBzzToTtl };
